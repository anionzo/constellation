-- Migration 07: Fix Storage Buckets & Policies
-- Dialect: PostgreSQL 15 (Supabase Self-Hosted Stack)

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('avatars', 'avatars', true),
  ('quire-moments', 'quire-moments', true),
  ('dream-attachments', 'dream-attachments', false)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

DROP POLICY IF EXISTS "Public Access Objects" ON storage.objects;
CREATE POLICY "Public Access Objects" ON storage.objects FOR ALL USING (true);

DROP POLICY IF EXISTS "Public Access Buckets" ON storage.buckets;
CREATE POLICY "Public Access Buckets" ON storage.buckets FOR ALL USING (true);
