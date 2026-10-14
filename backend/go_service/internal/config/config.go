package config

import (
	"os"
)

// Config holds runtime configuration loaded from environment variables.
type Config struct {
	Port         string
	DatabaseURL  string
	JWTSecret    string
	SupabaseURL  string
	SupabaseKey  string
	StorageBucket string
}

// LoadConfig parses environment variables and provides safe local defaults.
func LoadConfig() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}

	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@db:5432/postgres?sslmode=disable"
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		// Default dev secret aligned with Supabase Docker .env.example
		jwtSecret = "super-secret-jwt-token-with-at-least-32-characters-long"
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	if supabaseURL == "" {
		supabaseURL = "http://kong:8000"
	}

	supabaseKey := os.Getenv("SUPABASE_KEY")
	if supabaseKey == "" {
		supabaseKey = "service_role"
	}

	storageBucket := os.Getenv("STORAGE_BUCKET")
	if storageBucket == "" {
		storageBucket = "quire-moments"
	}

	return &Config{
		Port:          port,
		DatabaseURL:   dbURL,
		JWTSecret:     jwtSecret,
		SupabaseURL:   supabaseURL,
		SupabaseKey:   supabaseKey,
		StorageBucket: storageBucket,
	}
}
