package middleware

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

type contextKey string

const (
	// UserIDKey is the context key for extracted authenticated user ID (UUID).
	UserIDKey contextKey = "userId"
	// UserEmailKey is the context key for extracted user email.
	UserEmailKey contextKey = "userEmail"
	// TokenJTIKey is the context key for extracted JWT ID (JTI).
	TokenJTIKey contextKey = "tokenJti"
)

// TokenRevocationChecker checks whether a token JTI has been revoked.
type TokenRevocationChecker func(ctx context.Context, jti string) bool

// AuthMiddleware creates an HTTP middleware verifying Supabase GoTrue JWT tokens.
// It parses the Bearer token, checks HMAC-SHA256 signature using jwtSecret,
// verifies against token revocation list, and injects user identity into context.
func AuthMiddleware(jwtSecret string, isRevoked TokenRevocationChecker) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				writeJSONError(w, http.StatusUnauthorized, "Missing Authorization header")
				return
			}

			parts := strings.SplitN(authHeader, " ", 2)
			if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
				writeJSONError(w, http.StatusUnauthorized, "Malformed Authorization header; expected Bearer <token>")
				return
			}

			tokenString := parts[1]

			token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
				if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
				}
				return []byte(jwtSecret), nil
			})

			if err != nil || !token.Valid {
				writeJSONError(w, http.StatusUnauthorized, "Invalid or expired JWT token")
				return
			}

			claims, ok := token.Claims.(jwt.MapClaims)
			if !ok {
				writeJSONError(w, http.StatusUnauthorized, "Unable to extract claims from JWT token")
				return
			}

			// Sub claim represents Supabase auth.users UUID
			sub, ok := claims["sub"].(string)
			if !ok || sub == "" {
				writeJSONError(w, http.StatusUnauthorized, "JWT token missing valid 'sub' subject claim")
				return
			}
			email, _ := claims["email"].(string)
			jti, _ := claims["jti"].(string)

			// Verify token is not in revocation blacklist
			if jti != "" && isRevoked != nil {
				if isRevoked(r.Context(), jti) {
					writeJSONError(w, http.StatusUnauthorized, "Phiên đăng nhập đã kết thúc hoặc token đã bị thu hồi")
					return
				}
			}

			// Store user identity and token JTI in context
			ctx := context.WithValue(r.Context(), UserIDKey, sub)
			ctx = context.WithValue(ctx, UserEmailKey, email)
			ctx = context.WithValue(ctx, TokenJTIKey, jti)

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// GetTokenJTI extracts the JWT JTI from context.
func GetTokenJTI(ctx context.Context) string {
	val, _ := ctx.Value(TokenJTIKey).(string)
	return val
}

// GetUserID extracts the authenticated user ID from context.
func GetUserID(ctx context.Context) (string, bool) {
	val, ok := ctx.Value(UserIDKey).(string)
	return val, ok && val != ""
}

// writeJSONError serializes an HTTP error response in JSON format.
func writeJSONError(w http.ResponseWriter, statusCode int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(map[string]string{
		"error": message,
	})
}
