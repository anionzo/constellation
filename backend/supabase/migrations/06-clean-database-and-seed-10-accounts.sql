-- Migration 06: Clean Database & Seed 10 Production-Ready Accounts with Bcrypt Passwords
-- Dialect: PostgreSQL 15 (Supabase Self-Hosted Stack)

-- 1. Wipe all existing junk/test data cleanly (Cascading delete)
TRUNCATE TABLE public.chat_messages CASCADE;
TRUNCATE TABLE public.saved_items CASCADE;
TRUNCATE TABLE public.circle_requests CASCADE;
TRUNCATE TABLE public.circle_invites CASCADE;
TRUNCATE TABLE public.circle_members CASCADE;
TRUNCATE TABLE public.moments CASCADE;
TRUNCATE TABLE public.articles CASCADE;
TRUNCATE TABLE public.user_refresh_tokens CASCADE;
TRUNCATE TABLE public.revoked_access_tokens CASCADE;
TRUNCATE TABLE public.article_topics CASCADE;

-- Delete all users in auth.users (cascades to public.profiles via foreign key)
DELETE FROM auth.users;

-- 2. Seed 10 Production-Ready Registered Accounts
-- All accounts share the secure password: "password123"
-- Bcrypt Hash (Cost 10): $2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu

-- 1. Mai Trần (Lisbon)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'mai@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Mai Trần"}'::jsonb);

UPDATE public.profiles
SET username = '@mai.tran', bio = 'Nhiếp ảnh gia đường phố · Lisbon', city = 'Lisbon'
WHERE id = '11111111-1111-1111-1111-111111111111';

-- 2. Minh Tuấn (Kyoto)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'tuan@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Minh Tuấn"}'::jsonb);

UPDATE public.profiles
SET username = '@tuan.coffee', bio = 'Thưởng thức cà phê & đọc sách', city = 'Kyoto'
WHERE id = '22222222-2222-2222-2222-222222222222';

-- 3. Lan Linh (Đà Lạt)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'linh@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Lan Linh"}'::jsonb);

UPDATE public.profiles
SET username = '@linh.art', bio = 'Nghệ nhân gốm mộc & hoa dại', city = 'Đà Lạt'
WHERE id = '33333333-3333-3333-3333-333333333333';

-- 4. Văn An (Sài Gòn)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('44444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'an@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Văn An"}'::jsonb);

UPDATE public.profiles
SET username = '@an.architect', bio = 'Kiến trúc sư cảnh quan nhiệt đới', city = 'Sài Gòn'
WHERE id = '44444444-4444-4444-4444-444444444444';

-- 5. Thu Hà (Hà Nội)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('55555555-5555-5555-5555-555555555555', '00000000-0000-0000-0000-000000000000', 'ha@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Thu Hà"}'::jsonb);

UPDATE public.profiles
SET username = '@ha.travel', bio = 'Tản bộ qua những ngõ vắng', city = 'Hà Nội'
WHERE id = '55555555-5555-5555-5555-555555555555';

-- 6. Đăng Khoa (Copenhagen)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('66666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-000000000000', 'khoa@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Đăng Khoa"}'::jsonb);

UPDATE public.profiles
SET username = '@khoa.design', bio = 'Thiết kế tối giản Bắc Âu', city = 'Copenhagen'
WHERE id = '66666666-6666-6666-6666-666666666666';

-- 7. Huyền Trang (Hội An)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('77777777-7777-7777-7777-777777777777', '00000000-0000-0000-0000-000000000000', 'trang@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Huyền Trang"}'::jsonb);

UPDATE public.profiles
SET username = '@trang.book', bio = 'Biên tập viên sách văn học', city = 'Hội An'
WHERE id = '77777777-7777-7777-7777-777777777777';

-- 8. Hoàng Duy (Lisbon)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('88888888-8888-8888-8888-888888888888', '00000000-0000-0000-0000-000000000000', 'duy@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Hoàng Duy"}'::jsonb);

UPDATE public.profiles
SET username = '@duy.photo', bio = 'Chụp film 35mm & kiến trúc cổ', city = 'Lisbon'
WHERE id = '88888888-8888-8888-8888-888888888888';

-- 9. Gia Bảo (Tokyo)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('99999999-9999-9999-9999-999999999999', '00000000-0000-0000-0000-000000000000', 'bao@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Gia Bảo"}'::jsonb);

UPDATE public.profiles
SET username = '@bao.journal', bio = 'Ký họa đô thị & trà chiều', city = 'Tokyo'
WHERE id = '99999999-9999-9999-9999-999999999999';

-- 10. Như Quỳnh (Sa Pa)
INSERT INTO auth.users (id, instance_id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '00000000-0000-0000-0000-000000000000', 'quynh@quire.app', '$2b$10$I/bK9vmv46vjdpQIfdOA9OFQsLRYnGf7HEjyBIHVOIjwJ57RoNbLu', now(), 'authenticated', 'authenticated', '{"display_name":"Như Quỳnh"}'::jsonb);

UPDATE public.profiles
SET username = '@quynh.flora', bio = 'Vườn ươm thực vật & lối sống chậm', city = 'Sa Pa'
WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

-- 3. Seed Dynamic Topics & Hashtags
INSERT INTO public.article_topics (name, display_tag, usage_count)
VALUES
  ('noithat', '#noithat', 15),
  ('kientruc', '#kientruc', 12),
  ('vanhoa', '#vanhoa', 10),
  ('thietke', '#thietke', 9),
  ('caphesang', '#caphesang', 8),
  ('nhipcham', '#nhipcham', 7),
  ('lisbon', '#lisbon', 6),
  ('kyoto', '#kyoto', 5),
  ('nhavuon', '#nhavuon', 4);

-- 4. Seed Editorial Articles with Dynamic Hashtags
INSERT INTO public.articles (id, author_id, title, excerpt, full_content, category, cover_image_path, read_time_minutes, is_public, likes_count)
VALUES
  (
    'e1111111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    'Nghệ thuật của gạch men azulejo ở Lisbon',
    'Mặt tiền azulejo không đơn thuần là trang trí. Đó là tấm lưới giải quyết vi khí hậu và kể lại ký ức đô thị qua hàng thế kỷ.',
    'Mặt tiền azulejo không đơn thuần là trang trí. Đó là tấm lưới giải quyết vi khí hậu và kể lại ký ức đô thị qua hàng thế kỷ.\n\nKhi tản bộ qua những con dốc lát đá hoa cương ở Alfama hay Chiado, bạn sẽ nhận ra ánh nắng phản chiếu dịu nhẹ trên lớp men gốm xanh lam và vàng đất. Lớp gốm này đóng vai trò như một màng ngăn nhiệt tự nhiên: giữ cho các bức tường đá mát rượi vào buổi trưa hè oi ả và phản xạ bớt gió ẩm từ cửa sông Tagus thổi vào mùa đông.\n\nNhưng điều kỳ diệu hơn cả là sự yên tĩnh mà chúng mang lại cho cảnh quan thị giác. Thay vì những tấm biển quảng cáo rực rỡ hay màu sơn công nghiệp chói gắt, từng phiến gạch men thủ công mang vết rạn tinh tế của thời gian.',
    '#kientruc',
    'https://picsum.photos/seed/lisbon/800/500',
    7,
    true,
    34
  ),
  (
    'e2222222-2222-2222-2222-222222222222',
    '22222222-2222-2222-2222-222222222222',
    'Những thư viện im lặng ở cố đô Kyoto',
    'Giữa lòng cố đô náo nhiệt, có những căn phòng gỗ tối màu mang mùi hương của giấy cũ và tiếng lá xào xạc ngoài vườn thiền.',
    'Giữa lòng cố đô náo nhiệt, có những căn phòng gỗ tối màu mang mùi hương của giấy cũ và tiếng lá xào xạc ngoài vườn thiền. Nơi đây người ta đến không phải để vội vã lướt qua những trang sách điện tử, mà để lắng nghe sự tĩnh lặng tuyệt đối.\n\nKhông có tiếng chuông thông báo, không có ánh sáng xanh nhấp nháy. Chỉ có những nan trượt shoji bằng giấy washi mỏng manh, lọc ánh nắng trưa thành một vệt sáng mềm mại trên sàn chiếu tatami.',
    '#vanhoa',
    'https://picsum.photos/seed/kyoto/800/500',
    5,
    true,
    28
  ),
  (
    'e3333333-3333-3333-3333-333333333333',
    '66666666-6666-6666-6666-666666666666',
    'Triết lý thiết kế tối giản Bắc Âu và nhịp sống chậm',
    'Vẻ đẹp không nằm ở sự phô trương của hình khối hay chi tiết cầu kỳ, mà hiện diện ở khoảng trống và cách ánh sáng tự nhiên len lỏi.',
    'Vẻ đẹp không nằm ở sự phô trương của hình khối hay chi tiết cầu kỳ, mà hiện diện ở khoảng trống và cách ánh sáng tự nhiên len lỏi vào căn nhà trong những ngày mùa đông dài.\n\nĐồ nội thất gỗ sồi mộc mạc, đường nét vuông vức, bàn ghế tối giản không có chi tiết thừa. Từng góc nhỏ trong ngôi nhà đều thở cùng nhịp điệu của người sống trong đó.',
    '#noithat',
    'https://picsum.photos/seed/nordic/800/500',
    6,
    true,
    42
  ),
  (
    'e4444444-4444-4444-4444-444444444444',
    '44444444-4444-4444-4444-444444444444',
    'Không gian sân vườn nhiệt đới giữa lòng phố thị',
    'Đưa thiên nhiên trở lại nếp nhà qua những khoảng đệm xanh mướt của lá chuối cảnh, dương xỉ và hồ cá nhỏ.',
    'Đưa thiên nhiên trở lại nếp nhà qua những khoảng đệm xanh mướt của lá chuối cảnh, dương xỉ và hồ cá nhỏ.\n\nMột ngôi nhà nhiệt đới đúng nghĩa không cần phải cô lập với thế giới bên ngoài bằng kính cách âm dày đặc. Thay vào đó, lam gỗ xoay chuyển theo hướng gió và bóng râm của giàn cây leo giúp điều hòa nhiệt độ tự nhiên.',
    '#nhavuon',
    'https://picsum.photos/seed/garden/800/500',
    4,
    true,
    19
  );

-- 5. Seed Real Moments
INSERT INTO public.moments (id, sender_id, circle_id, image_path, caption, likes_count, is_archived, created_at)
VALUES
  ('ba111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'circle_1', 'https://picsum.photos/seed/lisbon_sunset/800/800', 'Buổi chiều nắng nhẹ trên hiên nhà Alfama.', 8, false, now() - interval '1 hour'),
  ('ba222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'circle_1', 'https://picsum.photos/seed/kyoto_coffee/800/800', 'Ghé quán cà phê quen bên rặng tre, đọc xong chương cuối cuốn tiểu thuyết.', 6, false, now() - interval '3 hours'),
  ('ba333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'circle_1', 'https://picsum.photos/seed/dalat_clay/800/800', 'Mẻ gốm mộc vừa ra lò sáng nay, màu men tro tự nhiên rất đỗi mộc mạc.', 11, false, now() - interval '6 hours'),
  ('ba444444-4444-4444-4444-444444444444', '44444444-4444-4444-4444-444444444444', 'circle_1', 'https://picsum.photos/seed/saigon_terrace/800/800', 'Mảng xanh ban công mới trồng thêm mấy nhánh dương xỉ rừng.', 5, false, now() - interval '1 day'),
  ('ba555555-5555-5555-5555-555555555555', '55555555-5555-5555-5555-555555555555', 'circle_1', 'https://picsum.photos/seed/hanoi_street/800/800', 'Hà Nội sớm mùa thu, mùi hoa sữa thoang thoảng góc phố nhỏ.', 9, false, now() - interval '2 days');
VALUES
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'active'),
  ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', 'active'),
  ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'active'),
  ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', 'active'),
  ('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '66666666-6666-6666-6666-666666666666', 'active'),
  ('66666666-6666-6666-6666-666666666666', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '77777777-7777-7777-7777-777777777777', 'active'),
  ('77777777-7777-7777-7777-777777777777', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '88888888-8888-8888-8888-888888888888', 'active'),
  ('88888888-8888-8888-8888-888888888888', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', '99999999-9999-9999-9999-999999999999', 'active'),
  ('99999999-9999-9999-9999-999999999999', '22222222-2222-2222-2222-222222222222', 'active'),
  ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'active'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'active');

-- 7. Seed Real 1-on-1 Messages between Mai và Tuấn
INSERT INTO public.chat_messages (id, sender_id, recipient_id, message_text, sent_at)
VALUES
  ('c1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Chào Tuấn! Cậu xem bức ảnh tớ vừa chụp ở góc phố cổ Lisbon chưa?', now() - interval '45 minutes'),
  ('c2222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Tớ xem rồi, ánh nắng xiên qua hiên nhà men gốm đẹp lắm!', now() - interval '30 minutes'),
  ('c3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Cuối tuần nếu rảnh tản bộ tiếp nhé, tớ mới tìm thấy một quán cà phê sách rất yên tĩnh.', now() - interval '10 minutes');

-- 8. Seed Saved Items (Minh Tuấn đã lưu bài gạch men azulejo)
INSERT INTO public.saved_items (user_id, target_type, target_id)
VALUES
  ('22222222-2222-2222-2222-222222222222', 'article', 'e1111111-1111-1111-1111-111111111111')
ON CONFLICT (user_id, target_type, target_id) DO NOTHING;
