package middleware

import (
	"net/http"

	"github.com/go-chi/cors"
)

// CorsMiddleware returns configured CORS handling for local web and mobile clients.
func CorsMiddleware() func(http.Handler) http.Handler {
	return cors.Handler(cors.Options{
		AllowedOrigins:   []string{"http://localhost:*", "http://127.0.0.1:*", "https://*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link", "X-Cursor"},
		AllowCredentials: true,
		MaxAge:           300, // 5 minutes
	})
}
