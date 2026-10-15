-- Migration 04: Seed Real Database Records & Unconstrained Circle Members
-- Dialect: PostgreSQL 15 (Supabase Self-Hosted Stack)

-- 1. Create circle_members table if not exists (for direct peer-to-peer circle friendships)
CREATE TABLE IF NOT EXISTS public.circle_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status VARCHAR(16) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, friend_id)
);

ALTER TABLE public.circle_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public circle members read" ON public.circle_members;
CREATE POLICY "Public circle members read" ON public.circle_members FOR ALL USING (true);

-- 2. Seed realistic members into auth.users and public.profiles
-- Mai
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'mai@quire.app', '$2a$10$xyz', now(), 'authenticated', 'authenticated', '{"display_name":"Mai"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

UPDATE public.profiles
SET username = '@mai.tran', bio = 'Nhiếp ảnh gia nghiệp dư · Lisbon', city = 'Lisbon'
WHERE id = '11111111-1111-1111-1111-111111111111';

-- Tuấn
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'tuan@quire.app', '$2a$10$xyz', now(), 'authenticated', 'authenticated', '{"display_name":"Tuấn"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

UPDATE public.profiles
SET username = '@tuan.coffee', bio = 'Đọc sách bên tách cà phê sáng', city = 'Kyoto'
WHERE id = '22222222-2222-2222-2222-222222222222';

-- Linh
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'linh@quire.app', '$2a$10$xyz', now(), 'authenticated', 'authenticated', '{"display_name":"Linh"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

UPDATE public.profiles
SET username = '@linh.art', bio = 'Gốm thủ công & hoa dại', city = 'Đà Lạt'
WHERE id = '33333333-3333-3333-3333-333333333333';

-- An
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('44444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'an@quire.app', '$2a$10$xyz', now(), 'authenticated', 'authenticated', '{"display_name":"An"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

UPDATE public.profiles
SET username = '@an.architect', bio = 'Kiến trúc sư cảnh quan nhiệt đới', city = 'Sài Gòn'
WHERE id = '44444444-4444-4444-4444-444444444444';

-- Hà
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('55555555-5555-5555-5555-555555555555', '00000000-0000-0000-0000-000000000000', 'ha@quire.app', '$2a$10$xyz', now(), 'authenticated', 'authenticated', '{"display_name":"Hà"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

UPDATE public.profiles
SET username = '@ha.travel', bio = 'Tản bộ qua các ngõ vắng', city = 'Hà Nội'
WHERE id = '55555555-5555-5555-5555-555555555555';

-- 3. Seed real moments into public.moments
INSERT INTO public.moments (id, sender_id, circle_id, image_path, caption, likes_count, is_archived, created_at)
VALUES
  ('a1111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'circle_1', 'https://picsum.photos/seed/grass/800/800', 'Buổi chiều nắng nhẹ trên hiên nhà cũ.', 5, false, now() - interval '2 hours'),
  ('a2222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'circle_1', 'https://picsum.photos/seed/coffee/800/800', 'Ghé quán cà phê quen, đọc xong chương cuối cuốn tiểu thuyết.', 3, false, now() - interval '5 hours'),
  ('a3333333-cccc-cccc-cccc-cccccccccccc', '33333333-3333-3333-3333-333333333333', 'circle_1', 'https://picsum.photos/seed/window/800/800', 'Cơn mưa rào đầu mùa nhìn qua khung cửa sổ tầng áp mái.', 7, false, now() - interval '1 day'),
  ('a4444444-dddd-dddd-dddd-dddddddddddd', '44444444-4444-4444-4444-444444444444', 'circle_1', 'https://picsum.photos/seed/plants/800/800', 'Khu vườn ban công mới trồng thêm mấy nhánh dương xỉ.', 4, false, now() - interval '2 days')
ON CONFLICT (id) DO NOTHING;

-- 4. Connect user minhtuan to all friends
INSERT INTO public.circle_members (user_id, friend_id, status)
VALUES
  ('ac36250b-a3d7-47dc-b1e8-b839cf71f9cc', '11111111-1111-1111-1111-111111111111', 'active'),
  ('ac36250b-a3d7-47dc-b1e8-b839cf71f9cc', '22222222-2222-2222-2222-222222222222', 'active'),
  ('ac36250b-a3d7-47dc-b1e8-b839cf71f9cc', '33333333-3333-3333-3333-333333333333', 'active'),
  ('ac36250b-a3d7-47dc-b1e8-b839cf71f9cc', '44444444-4444-4444-4444-444444444444', 'active'),
  ('ac36250b-a3d7-47dc-b1e8-b839cf71f9cc', '55555555-5555-5555-5555-555555555555', 'active')
ON CONFLICT (user_id, friend_id) DO NOTHING;
