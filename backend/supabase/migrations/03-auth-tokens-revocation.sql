-- Migration 03: Refresh Tokens, Revocation & Session Security
-- Dialect: PostgreSQL 15 (Supabase Self-Hosted Stack)

-- 1. Refresh Tokens table
CREATE TABLE IF NOT EXISTS public.user_refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    is_revoked BOOLEAN NOT NULL DEFAULT false,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revoked_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash ON public.user_refresh_tokens (token_hash);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON public.user_refresh_tokens (user_id);

-- 2. Revoked Access Tokens (Blacklist) table
CREATE TABLE IF NOT EXISTS public.revoked_access_tokens (
    jti VARCHAR(64) PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    revoked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_revoked_tokens_user ON public.revoked_access_tokens (user_id);
CREATE INDEX IF NOT EXISTS idx_revoked_tokens_expires ON public.revoked_access_tokens (expires_at);

-- 3. RLS
ALTER TABLE public.user_refresh_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revoked_access_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only read own refresh tokens"
    ON public.user_refresh_tokens FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own refresh tokens"
    ON public.user_refresh_tokens FOR UPDATE
    USING (auth.uid() = user_id);
