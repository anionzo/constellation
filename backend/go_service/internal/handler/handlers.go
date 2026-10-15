package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"
	"github.com/go-chi/chi/v5"
	"github.com/golang-jwt/jwt/v5"

	"constellation/backend/go_service/internal/config"
	"constellation/backend/go_service/internal/domain"
	"constellation/backend/go_service/internal/middleware"
	"constellation/backend/go_service/internal/realtime"
	"constellation/backend/go_service/internal/repository"
)

// Handler coordinates business logic and HTTP routing for the Golang BFF.
type Handler struct {
	repo repository.Repository
	cfg  *config.Config
	hub  *realtime.Hub
}

// NewHandler initializes a Handler with repository, config and realtime hub.
func NewHandler(repo repository.Repository, cfg *config.Config, hub *realtime.Hub) *Handler {
	return &Handler{
		repo: repo,
		cfg:  cfg,
		hub:  hub,
	}
}

// ==========================================
// 1. Profile Handlers
// ==========================================

func (h *Handler) GetMyProfile(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	p, err := h.repo.GetProfileByID(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusNotFound, "Profile not found")
		return
	}
	writeJSON(w, http.StatusOK, p)
}

func (h *Handler) GetProfileStats(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Chưa xác thực")
		return
	}

	stats, err := h.repo.GetProfileStats(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Lỗi truy vấn thống kê hồ sơ")
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func (h *Handler) UpdateMyProfile(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	var req struct {
		DisplayName string `json:"display_name"`
		Username    string `json:"username"`
		Bio         string `json:"bio"`
		City        string `json:"city"`
		AvatarPath  string `json:"avatar_path"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request JSON payload")
		return
	}

	uname := strings.TrimSpace(req.Username)
	if uname != "" && !strings.HasPrefix(uname, "@") {
		uname = "@" + uname
	}

	p := &domain.Profile{
		ID:          userID,
		Username:    uname,
		DisplayName: req.DisplayName,
		Bio:         req.Bio,
		City:        req.City,
		AvatarPath:  req.AvatarPath,
	}

	if err := h.repo.UpdateProfile(r.Context(), p); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to update profile")
		return
	}
	writeJSON(w, http.StatusOK, p)
}

func (h *Handler) GetFriendProfile(w http.ResponseWriter, r *http.Request) {
	username := chi.URLParam(r, "username")
	if username == "" {
		writeError(w, http.StatusBadRequest, "Missing username parameter")
		return
	}

	p, err := h.repo.GetProfileByUsername(r.Context(), username)
	if err != nil {
		writeError(w, http.StatusNotFound, "Friend profile not found")
		return
	}

	friend := domain.CircleFriend{
		ID:                 p.ID,
		Name:               p.DisplayName,
		Username:           p.Username,
		Bio:                p.Bio,
		City:               p.City,
		SharedMomentsCount: 8,
		HasUnreadStory:     false,
	}
	writeJSON(w, http.StatusOK, friend)
}

// ==========================================
// 2. Circle & Invites Handlers (Unconstrained)
// ==========================================

func (h *Handler) GetFriends(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	friends, err := h.repo.GetFriends(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to retrieve friends")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"data":  friends,
		"total": len(friends),
	})
}

func (h *Handler) RemoveFriend(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	friendID := chi.URLParam(r, "friendId")
	if friendID == "" {
		writeError(w, http.StatusBadRequest, "Missing friendId")
		return
	}

	if err := h.repo.RemoveFriend(r.Context(), userID, friendID); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to remove friend")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Friend removed from circle successfully",
	})
}

func (h *Handler) AddFriend(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Chưa xác thực")
		return
	}
	var req struct {
		Username string `json:"username"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || strings.TrimSpace(req.Username) == "" {
		writeError(w, http.StatusBadRequest, "Vui lòng nhập tên tài khoản (@username)")
		return
	}

	friend, err := h.repo.AddFriendByUsername(r.Context(), userID, req.Username)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, friend)
}

func (h *Handler) GenerateInviteLink(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	code := fmt.Sprintf("QUIRE-%s-%d", strings.ToUpper(userID[:4]), time.Now().Unix()%10000)
	invite := &domain.CircleInvite{
		ID:         fmt.Sprintf("inv_%d", time.Now().UnixNano()),
		SenderID:   userID,
		InviteCode: code,
		InviteURL:  fmt.Sprintf("https://quire.app/join/%s", code),
		CreatedAt:  time.Now(),
	}

	if err := h.repo.CreateInvite(r.Context(), invite); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to generate invite")
		return
	}
	writeJSON(w, http.StatusOK, invite)
}

func (h *Handler) GetReceivedRequests(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	reqs, err := h.repo.GetReceivedRequests(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to get requests")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"data":  reqs,
		"total": len(reqs),
	})
}

func (h *Handler) AcceptRequest(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	requestID := chi.URLParam(r, "id")

	newFriend, err := h.repo.AcceptRequest(r.Context(), userID, requestID)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"message": "Friend request accepted",
		"friend":  newFriend,
	})
}

func (h *Handler) DeclineRequest(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	requestID := chi.URLParam(r, "id")

	if err := h.repo.DeclineRequest(r.Context(), userID, requestID); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Friend request declined",
	})
}

// ==========================================
// 3. Articles Handlers (Cursor Pagination & Visibility)
// ==========================================

func (h *Handler) GetArticles(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.GetUserID(r.Context())
	if userID == "" {
		authHeader := r.Header.Get("Authorization")
		if parts := strings.SplitN(authHeader, " ", 2); len(parts) == 2 && strings.EqualFold(parts[0], "Bearer") {
			if token, err := jwt.Parse(parts[1], func(t *jwt.Token) (interface{}, error) {
				return []byte(h.cfg.JWTSecret), nil
			}); err == nil && token != nil {
				if claims, ok := token.Claims.(jwt.MapClaims); ok {
					if sub, ok := claims["sub"].(string); ok {
						userID = sub
					}
				}
			}
		}
	}

	scope := r.URL.Query().Get("scope")
	topic := r.URL.Query().Get("topic")
	cursorStr := r.URL.Query().Get("cursor")
	limit := 20
	if l := r.URL.Query().Get("limit"); l != "" {
		if parsed, err := strconv.Atoi(l); err == nil && parsed > 0 && parsed <= 50 {
			limit = parsed
		}
	}

	cursorTime, cursorID, _ := domain.DecodeCursor(cursorStr)

	articles, hasMore, nextCursor, err := h.repo.GetArticles(r.Context(), userID, scope, topic, cursorTime, cursorID, limit)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to retrieve articles")
		return
	}

	writeJSON(w, http.StatusOK, domain.PaginatedResponse[domain.Article]{
		Data: articles,
		Pagination: domain.PaginationMetadata{
			HasMore:    hasMore,
			NextCursor: nextCursor,
			Limit:      limit,
		},
	})
}

func (h *Handler) GetArticleTopics(w http.ResponseWriter, r *http.Request) {
	topics, err := h.repo.GetArticleTopics(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Không thể lấy danh sách chủ đề")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"data": topics,
	})
}

func (h *Handler) PublishArticle(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	var req struct {
		Title           string `json:"title"`
		Category        string `json:"category"`
		Excerpt         string `json:"excerpt"`
		FullContent     string `json:"full_content"`
		CoverImagePath  string `json:"cover_image_path"`
		ReadTimeMinutes int    `json:"read_time_minutes"`
		IsPublic        bool   `json:"is_public"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid JSON payload")
		return
	}

	if req.Title == "" || req.FullContent == "" {
		writeError(w, http.StatusBadRequest, "Title and FullContent are required")
		return
	}

	art := &domain.Article{
		ID:              fmt.Sprintf("art_%d", time.Now().UnixNano()),
		AuthorID:        userID,
		AuthorName:      "Bạn",
		AuthorUsername:  "@ban.quire",
		Title:           req.Title,
		Category:        req.Category,
		Excerpt:         req.Excerpt,
		FullContent:     req.FullContent,
		CoverImagePath:  req.CoverImagePath,
		ReadTimeMinutes: req.ReadTimeMinutes,
		IsPublic:        req.IsPublic,
		LikesCount:      0,
		CreatedAt:       time.Now(),
	}

	if err := h.repo.PublishArticle(r.Context(), art); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to publish article")
		return
	}
	writeJSON(w, http.StatusCreated, art)
}

func (h *Handler) ToggleLikeArticle(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	articleID := chi.URLParam(r, "id")

	isLiked, likesCount, err := h.repo.ToggleLikeArticle(r.Context(), userID, articleID)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"is_liked":    isLiked,
		"likes_count": likesCount,
	})
}

func (h *Handler) BookmarkArticle(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	articleID := chi.URLParam(r, "id")

	if err := h.repo.BookmarkArticle(r.Context(), userID, articleID); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to bookmark")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "Article bookmarked"})
}

func (h *Handler) UnbookmarkArticle(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	articleID := chi.URLParam(r, "id")

	if err := h.repo.UnbookmarkArticle(r.Context(), userID, articleID); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to unbookmark")
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"message": "Article removed from bookmarks"})
}

// ==========================================
// 4. Moments Handlers (Soft-Purge & Feed)
// ==========================================

func (h *Handler) GetFeed(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.GetUserID(r.Context())
	if userID == "" {
		authHeader := r.Header.Get("Authorization")
		if parts := strings.SplitN(authHeader, " ", 2); len(parts) == 2 && strings.EqualFold(parts[0], "Bearer") {
			if token, err := jwt.Parse(parts[1], func(t *jwt.Token) (interface{}, error) {
				return []byte(h.cfg.JWTSecret), nil
			}); err == nil && token != nil {
				if claims, ok := token.Claims.(jwt.MapClaims); ok {
					if sub, ok := claims["sub"].(string); ok {
						userID = sub
					}
				}
			}
		}
	}

	circleID := r.URL.Query().Get("circle_id")
	cursorStr := r.URL.Query().Get("cursor")
	limit := 20
	if l := r.URL.Query().Get("limit"); l != "" {
		if parsed, err := strconv.Atoi(l); err == nil && parsed > 0 && parsed <= 50 {
			limit = parsed
		}
	}

	cursorTime, cursorID, _ := domain.DecodeCursor(cursorStr)

	moments, hasMore, nextCursor, err := h.repo.GetFeed(r.Context(), userID, circleID, cursorTime, cursorID, limit)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to retrieve moments feed")
		return
	}

	writeJSON(w, http.StatusOK, domain.PaginatedResponse[domain.Moment]{
		Data: moments,
		Pagination: domain.PaginationMetadata{
			HasMore:    hasMore,
			NextCursor: nextCursor,
			Limit:      limit,
		},
	})
}

func (h *Handler) PostMoment(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	var req struct {
		ImagePath                string `json:"image_path"`
		Caption                  string `json:"caption"`
		CircleID                 string `json:"circle_id"`
		AutoPurgeDurationSeconds *int   `json:"auto_purge_duration_seconds"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid JSON payload")
		return
	}

	if req.ImagePath == "" {
		writeError(w, http.StatusBadRequest, "image_path is required")
		return
	}

	mmt := &domain.Moment{
		ID:                       fmt.Sprintf("mom_%d", time.Now().UnixNano()),
		SenderID:                 userID,
		SenderName:               "Bạn",
		SenderInitials:           "B",
		CircleID:                 req.CircleID,
		ImagePath:                req.ImagePath,
		ImageURL:                 req.ImagePath,
		Caption:                  req.Caption,
		AutoPurgeDurationSeconds: req.AutoPurgeDurationSeconds,
		IsArchived:               false,
		LikesCount:               0,
		CreatedAt:                time.Now(),
	}

	if err := h.repo.PostMoment(r.Context(), mmt); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to post moment")
		return
	}
	writeJSON(w, http.StatusCreated, mmt)
}

func (h *Handler) ToggleLikeMoment(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	momentID := chi.URLParam(r, "id")

	isLiked, count, err := h.repo.ToggleLikeMoment(r.Context(), userID, momentID)
	if err != nil {
		writeError(w, http.StatusNotFound, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"is_liked":    isLiked,
		"likes_count": count,
	})
}

func (h *Handler) GetArchive(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	cursorStr := r.URL.Query().Get("cursor")
	cursorTime, cursorID, _ := domain.DecodeCursor(cursorStr)

	archived, hasMore, nextCursor, err := h.repo.GetArchive(r.Context(), userID, cursorTime, cursorID, 20)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to get archive")
		return
	}
	writeJSON(w, http.StatusOK, domain.PaginatedResponse[domain.Moment]{
		Data: archived,
		Pagination: domain.PaginationMetadata{
			HasMore:    hasMore,
			NextCursor: nextCursor,
			Limit:      20,
		},
	})
}

func (h *Handler) RestoreMoment(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	momentID := chi.URLParam(r, "id")

	if err := h.repo.RestoreMoment(r.Context(), userID, momentID); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Moment restored to circle feed successfully",
	})
}

func (h *Handler) DeleteMomentPermanently(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	momentID := chi.URLParam(r, "id")

	if err := h.repo.DeleteMomentPermanently(r.Context(), userID, momentID); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Moment permanently deleted from archive",
	})
}

// ==========================================
// 5. Contextual Chat Handlers
// ==========================================

func (h *Handler) GetInbox(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}

	items, err := h.repo.GetInbox(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to get inbox")
		return
	}
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"data":  items,
		"total": len(items),
	})
}

func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	friendID := chi.URLParam(r, "friendId")
	if friendID == "temp" || len(friendID) < 10 {
		friendID = "11111111-1111-1111-1111-111111111111"
	}
	cursorStr := r.URL.Query().Get("cursor")
	cursorTime, cursorID, _ := domain.DecodeCursor(cursorStr)

	messages, hasMore, nextCursor, err := h.repo.GetMessages(r.Context(), userID, friendID, cursorTime, cursorID, 30)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to get messages")
		return
	}
	writeJSON(w, http.StatusOK, domain.PaginatedResponse[domain.ChatMessage]{
		Data: messages,
		Pagination: domain.PaginationMetadata{
			HasMore:    hasMore,
			NextCursor: nextCursor,
			Limit:      30,
		},
	})
}

func (h *Handler) SendMessage(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Unauthorized")
		return
	}
	friendID := chi.URLParam(r, "friendId")
	if friendID == "temp" || len(friendID) < 10 {
		friendID = "11111111-1111-1111-1111-111111111111"
	}

	var req struct {
		MessageText    string  `json:"message_text"`
		ImagePath      *string `json:"image_path"`
		QuotedMomentID *string `json:"quoted_moment_id"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid JSON payload")
		return
	}

	if req.MessageText == "" && req.ImagePath == nil {
		writeError(w, http.StatusBadRequest, "Message text or image required")
		return
	}

	var preview *domain.QuotedMomentPreview
	if req.QuotedMomentID != nil {
		preview = &domain.QuotedMomentPreview{
			ID:           *req.QuotedMomentID,
			ThumbnailURL: "https://picsum.photos/seed/quote/120/120",
			Caption:      "Khoảnh khắc được trích dẫn",
			AuthorName:   "Bạn bè",
		}
	}

	msg := &domain.ChatMessage{
		ID:           fmt.Sprintf("msg_%d", time.Now().UnixNano()),
		SenderID:     userID,
		RecipientID:  friendID,
		MessageText:  req.MessageText,
		ImagePath:    req.ImagePath,
		QuotedMoment: preview,
		SentAt:       time.Now(),
	}

	if err := h.repo.SendMessage(r.Context(), msg); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to send message")
		return
	}
	// Broadcast real-time message and notification to recipient in < 5ms
	if h.hub != nil {
		h.hub.BroadcastToUser(friendID, "chat_message", msg)
		h.hub.BroadcastToUser(friendID, "notification", map[string]interface{}{
			"title":     "Tin nhắn mới",
			"body":      msg.MessageText,
			"sender_id": userID,
		})
	}
	writeJSON(w, http.StatusCreated, msg)
}

func (h *Handler) MarkChatAsRead(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Chưa xác thực")
		return
	}
	friendID := chi.URLParam(r, "friendId")
	if friendID == "" || friendID == "temp" {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
		return
	}

	_ = h.repo.MarkChatAsRead(r.Context(), userID, friendID)
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (h *Handler) GetUnreadMessageCount(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Chưa xác thực")
		return
	}

	count, err := h.repo.GetUnreadMessageCount(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Lỗi kiểm tra tin nhắn")
		return
	}
	writeJSON(w, http.StatusOK, map[string]int{"unread_count": count})
}

func (h *Handler) StreamEvents(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.GetUserID(r.Context())
	if userID == "" {
		tokenStr := r.URL.Query().Get("token")
		if tokenStr != "" {
			token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
				return []byte(h.cfg.JWTSecret), nil
			})
			if err == nil && token.Valid {
				if claims, ok := token.Claims.(jwt.MapClaims); ok {
					if sub, ok := claims["sub"].(string); ok {
						userID = sub
					}
				}
			}
		}
	}

	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	if h.hub != nil {
		h.hub.ServeSSE(w, r, userID)
	}
}

// ==========================================
// 6. System & Version Gate Handlers
// ==========================================

func (h *Handler) GetVersionGate(w http.ResponseWriter, r *http.Request) {
	platform := r.URL.Query().Get("platform")
	if platform == "" {
		platform = "web"
	}

	// Always evaluates to up-to-date in baseline service
	writeJSON(w, http.StatusOK, map[string]interface{}{
		"platform":              platform,
		"min_supported_version": "1.0.0",
		"latest_version":        "1.0.0",
		"is_maintenance_mode":   false,
		"force_update_title":    "Cập nhật ứng dụng",
		"force_update_message":  "Phiên bản mới đã sẵn sàng.",
		"update_url":            "https://app.constellation.internal",
	})
}

// ==========================================
// 6. Authentication Handlers & HttpOnly Cookies
// ==========================================

const RefreshTokenCookieName = "quire_refresh_token"

func setRefreshTokenCookie(w http.ResponseWriter, r *http.Request, refreshToken string, maxAge int) {
	isSecure := r.TLS != nil || r.Header.Get("X-Forwarded-Proto") == "https"
	http.SetCookie(w, &http.Cookie{
		Name:     RefreshTokenCookieName,
		Value:    refreshToken,
		Path:     "/",
		HttpOnly: true,
		Secure:   isSecure,
		SameSite: http.SameSiteLaxMode,
		MaxAge:   maxAge,
	})
}

func (h *Handler) HandleSignUp(w http.ResponseWriter, r *http.Request) {
	var req domain.AuthSignUpRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Dữ liệu yêu cầu không hợp lệ")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	req.Password = strings.TrimSpace(req.Password)
	if req.Email == "" || !strings.Contains(req.Email, "@") {
		writeError(w, http.StatusBadRequest, "Email không hợp lệ")
		return
	}
	if len(req.Password) < 6 {
		writeError(w, http.StatusBadRequest, "Mật khẩu phải có tối thiểu 6 ký tự")
		return
	}

	res, err := h.repo.SignUp(r.Context(), req.Email, req.Password, req.DisplayName)
	if err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	// Set HttpOnly, Secure, SameSite Cookie for web browsers
	if res.RefreshToken != "" {
		setRefreshTokenCookie(w, r, res.RefreshToken, 30*24*3600)
	}

	writeJSON(w, http.StatusCreated, res)
}

func (h *Handler) HandleLogin(w http.ResponseWriter, r *http.Request) {
	var req domain.AuthLoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Dữ liệu yêu cầu không hợp lệ")
		return
	}

	req.Email = strings.TrimSpace(req.Email)
	req.Password = strings.TrimSpace(req.Password)
	if req.Email == "" || req.Password == "" {
		writeError(w, http.StatusBadRequest, "Vui lòng nhập đầy đủ email và mật khẩu")
		return
	}

	res, err := h.repo.Login(r.Context(), req.Email, req.Password)
	if err != nil {
		writeError(w, http.StatusUnauthorized, err.Error())
		return
	}

	// Set HttpOnly, Secure, SameSite Cookie for web browsers
	if res.RefreshToken != "" {
		setRefreshTokenCookie(w, r, res.RefreshToken, 30*24*3600)
	}

	writeJSON(w, http.StatusOK, res)
}

func (h *Handler) HandleRefreshToken(w http.ResponseWriter, r *http.Request) {
	var req domain.AuthRefreshTokenRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	// If not in JSON body, automatically extract from HttpOnly Cookie
	if req.RefreshToken == "" {
		if c, err := r.Cookie(RefreshTokenCookieName); err == nil && c.Value != "" {
			req.RefreshToken = c.Value
		}
	}

	if req.RefreshToken == "" {
		writeError(w, http.StatusBadRequest, "Vui lòng cung cấp refresh token hoặc gửi kèm phiên đăng nhập hợp lệ")
		return
	}

	res, err := h.repo.RefreshToken(r.Context(), req.RefreshToken)
	if err != nil {
		// Clear invalid cookie on browser
		setRefreshTokenCookie(w, r, "", -1)
		writeError(w, http.StatusUnauthorized, err.Error())
		return
	}

	// Rotate HttpOnly cookie
	if res.RefreshToken != "" {
		setRefreshTokenCookie(w, r, res.RefreshToken, 30*24*3600)
	}

	writeJSON(w, http.StatusOK, res)
}

func (h *Handler) HandleLogout(w http.ResponseWriter, r *http.Request) {
	userID, _ := middleware.GetUserID(r.Context())
	tokenJTI := middleware.GetTokenJTI(r.Context())

	// Also extract user identity directly from Authorization header if route is public
	if userID == "" {
		authHeader := r.Header.Get("Authorization")
		if parts := strings.SplitN(authHeader, " ", 2); len(parts) == 2 && strings.EqualFold(parts[0], "Bearer") {
			if token, err := jwt.Parse(parts[1], func(t *jwt.Token) (interface{}, error) {
				return []byte(h.cfg.JWTSecret), nil
			}); err == nil && token != nil {
				if claims, ok := token.Claims.(jwt.MapClaims); ok {
					if sub, ok := claims["sub"].(string); ok {
						userID = sub
					}
					if jti, ok := claims["jti"].(string); ok {
						tokenJTI = jti
					}
				}
			}
		}
	}

	var req domain.AuthLogoutRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	// If not in JSON body, automatically extract from HttpOnly Cookie
	if req.RefreshToken == "" {
		if c, err := r.Cookie(RefreshTokenCookieName); err == nil && c.Value != "" {
			req.RefreshToken = c.Value
		}
	}

	_ = h.repo.Logout(r.Context(), userID, tokenJTI, req.RefreshToken)

	// Wipe HttpOnly cookie on browser immediately
	setRefreshTokenCookie(w, r, "", -1)

	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Đăng xuất thành công, phiên đăng nhập và Cookie đã được hủy",
	})
}

func (h *Handler) HandleLogoutAll(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Chưa xác thực")
		return
	}

	if err := h.repo.LogoutAll(r.Context(), userID); err != nil {
		writeError(w, http.StatusInternalServerError, "Lỗi khi đăng xuất tất cả thiết bị")
		return
	}

	// Wipe HttpOnly cookie on browser
	setRefreshTokenCookie(w, r, "", -1)

	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Đã thu hồi tất cả phiên đăng nhập trên toàn bộ thiết bị",
	})
}

func (h *Handler) HandleDeactivateAccount(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "Chưa xác thực")
		return
	}

	var req domain.AuthDeactivateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Password == "" {
		writeError(w, http.StatusBadRequest, "Vui lòng nhập mật khẩu để xác nhận vô hiệu hóa tài khoản")
		return
	}

	if err := h.repo.DeactivateAccount(r.Context(), userID, req.Password); err != nil {
		writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	// Wipe HttpOnly cookie on browser
	setRefreshTokenCookie(w, r, "", -1)

	writeJSON(w, http.StatusOK, map[string]string{
		"message": "Tài khoản đã được vô hiệu hóa an toàn, toàn bộ phiên đăng nhập đã bị xóa",
	})
}

// ==========================================
// JSON Response Helpers
// ==========================================

func writeJSON(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(data)
}

func writeError(w http.ResponseWriter, statusCode int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(map[string]string{
		"error": message,
	})
}
