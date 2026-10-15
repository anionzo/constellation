-- Migration 05: Dynamic Article Topics & Hashtags
-- Dialect: PostgreSQL 15 (Supabase Self-Hosted Stack)

CREATE TABLE IF NOT EXISTS public.article_topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(64) UNIQUE NOT NULL,
    display_tag VARCHAR(68) NOT NULL,
    usage_count INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_article_topics_count ON public.article_topics (usage_count DESC);

ALTER TABLE public.article_topics ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read topics" ON public.article_topics;
CREATE POLICY "Public read topics" ON public.article_topics FOR ALL USING (true);

-- Seed initial suggested hashtags
INSERT INTO public.article_topics (name, display_tag, usage_count)
VALUES
  ('noithat', '#noithat', 12),
  ('kientruc', '#kientruc', 9),
  ('vanhoa', '#vanhoa', 8),
  ('thietke', '#thietke', 7),
  ('caphesang', '#caphesang', 6),
  ('nhipcham', '#nhipcham', 5),
  ('lisbon', '#lisbon', 4),
  ('kyoto', '#kyoto', 3)
ON CONFLICT (name) DO UPDATE
SET usage_count = EXCLUDED.usage_count;
