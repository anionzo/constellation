package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"

	"constellation/backend/go_service/internal/config"
	"constellation/backend/go_service/internal/handler"
	"constellation/backend/go_service/internal/middleware"
	"constellation/backend/go_service/internal/repository"
)

func main() {
	cfg := config.LoadConfig()

	// Initialize repository: attempt PostgreSQL first, fallback to MemoryRepository gracefully
	var repo repository.Repository
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err == nil && pool.Ping(ctx) == nil {
		log.Println("[Constellation BFF] Connected successfully to PostgreSQL database pool.")
		repo = repository.NewPostgresRepository(pool, cfg.JWTSecret)
	} else {
		log.Println("[Constellation BFF] PostgreSQL unavailable, using in-memory repository baseline.")
		repo = repository.NewMemoryRepository()
	}

	h := handler.NewHandler(repo, cfg)

	r := chi.NewRouter()

	// Global Middlewares
	r.Use(chimiddleware.RequestID)
	r.Use(chimiddleware.RealIP)
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(middleware.CorsMiddleware())

	// Health check
	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]string{
			"status":  "ok",
			"service": "constellation-golang-bff",
		})
	})

	// Public System Endpoints
	r.Get("/api/v1/system/version-gate", h.GetVersionGate)

	// Public Auth Endpoints (Email & Password)
	r.Post("/api/v1/auth/signup", h.HandleSignUp)
	r.Post("/api/v1/auth/login", h.HandleLogin)

	// Protected Endpoints (Supabase JWT Verification)
	r.Group(func(protected chi.Router) {
		protected.Use(middleware.AuthMiddleware(cfg.JWTSecret))

		// Profile
		protected.Get("/api/v1/profile/me", h.GetMyProfile)
		protected.Put("/api/v1/profile/me", h.UpdateMyProfile)
		protected.Get("/api/v1/profile/{username}", h.GetFriendProfile)

		// Circle & Friends
		protected.Get("/api/v1/circle/friends", h.GetFriends)
		protected.Delete("/api/v1/circle/friends/{friendId}", h.RemoveFriend)
		protected.Post("/api/v1/circle/invites/generate", h.GenerateInviteLink)
		protected.Get("/api/v1/circle/requests/received", h.GetReceivedRequests)
		protected.Post("/api/v1/circle/requests/{id}/accept", h.AcceptRequest)
		protected.Post("/api/v1/circle/requests/{id}/decline", h.DeclineRequest)

		// Articles
		protected.Get("/api/v1/articles", h.GetArticles)
		protected.Post("/api/v1/articles", h.PublishArticle)
		protected.Post("/api/v1/articles/{id}/like", h.ToggleLikeArticle)
		protected.Post("/api/v1/articles/{id}/bookmark", h.BookmarkArticle)
		protected.Delete("/api/v1/articles/{id}/bookmark", h.UnbookmarkArticle)

		// Moments
		protected.Get("/api/v1/moments/feed", h.GetFeed)
		protected.Post("/api/v1/moments", h.PostMoment)
		protected.Post("/api/v1/moments/{id}/like", h.ToggleLikeMoment)
		protected.Get("/api/v1/moments/archive", h.GetArchive)
		protected.Post("/api/v1/moments/{id}/restore", h.RestoreMoment)
		protected.Delete("/api/v1/moments/{id}", h.DeleteMomentPermanently)

		// Contextual Chat
		protected.Get("/api/v1/chat/inbox", h.GetInbox)
		protected.Get("/api/v1/chat/{friendId}/messages", h.GetMessages)
		protected.Post("/api/v1/chat/{friendId}/messages", h.SendMessage)
	})

	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("[Constellation BFF] Starting Golang BFF Server on %s ...\n", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
