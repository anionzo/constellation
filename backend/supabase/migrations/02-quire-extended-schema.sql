-- Migration 02: Quire Extended Schema, Contextual Chat, Unconstrained Circle & Cursor Indexing
-- Dialect: PostgreSQL 15 (Supabase Self-Hosted Stack)

-- 1. Extend profiles with username, city, and bio formatting
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS username VARCHAR(32) UNIQUE,
    ADD COLUMN IF NOT EXISTS city VARCHAR(64) DEFAULT 'Lisbon';

-- Update existing profiles with default username if null
UPDATE public.profiles
SET username = LOWER(REPLACE(display_name, ' ', '.'))
WHERE username IS NULL;

-- 2. Create articles table (Magazine 2-Tier Content)
CREATE TABLE IF NOT EXISTS public.articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL DEFAULT 'Ghi chép',
    excerpt TEXT,
    full_content TEXT,
    cover_image_path TEXT,
    likes_count INT NOT NULL DEFAULT 0,
    is_public BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Create moments table (Visual Feed with Soft-Purge)
CREATE TABLE IF NOT EXISTS public.moments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    circle_id VARCHAR(64) NOT NULL DEFAULT 'circle_1',
    image_path TEXT NOT NULL,
    caption TEXT,
    likes_count INT NOT NULL DEFAULT 0,
    auto_purge_duration_seconds INT DEFAULT 2592000, -- 30 days default
    purged_at TIMESTAMPTZ,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Create circle_invites table (Personal Invite Link Generator)
CREATE TABLE IF NOT EXISTS public.circle_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    invite_code VARCHAR(64) UNIQUE NOT NULL,
    invite_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ
);

-- 5. Create circle_requests table (Received Connection Requests)
CREATE TABLE IF NOT EXISTS public.circle_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status VARCHAR(16) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(sender_id, recipient_id)
);

-- 6. Create saved_items table (Bookmarks - Bidirectional Save & Unsave)
CREATE TABLE IF NOT EXISTS public.saved_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    target_type VARCHAR(16) NOT NULL CHECK (target_type IN ('article', 'moment')),
    target_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, target_type, target_id)
);

-- 7. Create chat_messages table (1-on-1 Quiet Chat with Quoted Moments)
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    image_path TEXT,
    quoted_moment_id UUID REFERENCES public.moments(id) ON DELETE SET NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    read_at TIMESTAMPTZ
);

-- 8. Composite B-Tree Indexes for Cross-App Cursor-based Pagination
CREATE INDEX IF NOT EXISTS idx_moments_cursor
    ON public.moments (circle_id, is_archived, created_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_articles_cursor
    ON public.articles (is_public, created_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_chat_messages_cursor
    ON public.chat_messages (sender_id, recipient_id, sent_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_saved_items_cursor
    ON public.saved_items (user_id, created_at DESC, id DESC);

CREATE INDEX IF NOT EXISTS idx_circle_requests_recipient
    ON public.circle_requests (recipient_id, status, created_at DESC);

-- 9. Row Level Security (RLS) Policies
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circle_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.circle_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- articles policies
CREATE POLICY "Public articles are readable by everyone"
    ON public.articles FOR SELECT
    USING (is_public = true OR auth.uid() = author_id);

CREATE POLICY "Authors can manage their own articles"
    ON public.articles FOR ALL
    USING (auth.uid() = author_id);

-- moments policies
CREATE POLICY "Moments are visible to active users"
    ON public.moments FOR SELECT
    USING (is_archived = false OR auth.uid() = sender_id);

CREATE POLICY "Senders can manage their own moments"
    ON public.moments FOR ALL
    USING (auth.uid() = sender_id);

-- circle_invites policies
CREATE POLICY "Users can create their own invites"
    ON public.circle_invites FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can view their own invites"
    ON public.circle_invites FOR SELECT
    USING (auth.uid() = sender_id);

-- circle_requests policies
CREATE POLICY "Users can send circle requests"
    ON public.circle_requests FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

CREATE POLICY "Users can view incoming and outgoing requests"
    ON public.circle_requests FOR SELECT
    USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE POLICY "Recipients can update request status"
    ON public.circle_requests FOR UPDATE
    USING (auth.uid() = recipient_id);

-- saved_items policies
CREATE POLICY "Users manage their own saved items"
    ON public.saved_items FOR ALL
    USING (auth.uid() = user_id);

-- chat_messages policies
CREATE POLICY "Sender or recipient can view chat messages"
    ON public.chat_messages FOR SELECT
    USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

CREATE POLICY "Users can send messages"
    ON public.chat_messages FOR INSERT
    WITH CHECK (auth.uid() = sender_id);
