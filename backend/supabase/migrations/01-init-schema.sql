-- =============================================================================
-- Constellation Backend Architecture: Consolidated PostgreSQL Migration (01)
-- Target: Supabase Self-Hosted (PostgreSQL 15+)
-- =============================================================================

-- 0. INITIALIZE SUPABASE ROLES & SCHEMAS
DO $$
DECLARE
    pg_pw text;
BEGIN
    SELECT rolpassword INTO pg_pw FROM pg_authid WHERE rolname = 'postgres';

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_admin') THEN
        CREATE ROLE supabase_admin WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS;
    ELSE
        ALTER ROLE supabase_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'anon') THEN
        CREATE ROLE anon NOLOGIN NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticated') THEN
        CREATE ROLE authenticated NOLOGIN NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'service_role') THEN
        CREATE ROLE service_role NOLOGIN NOINHERIT BYPASSRLS;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_auth_admin') THEN
        CREATE ROLE supabase_auth_admin WITH LOGIN NOINHERIT CREATEROLE;
    ELSE
        ALTER ROLE supabase_auth_admin WITH LOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'supabase_storage_admin') THEN
        CREATE ROLE supabase_storage_admin WITH LOGIN NOINHERIT CREATEROLE;
    ELSE
        ALTER ROLE supabase_storage_admin WITH LOGIN;
    END IF;

    IF pg_pw IS NOT NULL THEN
        EXECUTE format('ALTER ROLE supabase_admin WITH PASSWORD %L', pg_pw);
        EXECUTE format('ALTER ROLE supabase_auth_admin WITH PASSWORD %L', pg_pw);
        EXECUTE format('ALTER ROLE supabase_storage_admin WITH PASSWORD %L', pg_pw);
    END IF;
END
$$;

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;
CREATE SCHEMA IF NOT EXISTS extensions;

GRANT ALL ON SCHEMA public TO postgres, supabase_admin;
GRANT ALL ON SCHEMA storage TO postgres, supabase_admin, supabase_storage_admin;
GRANT ALL ON SCHEMA auth TO postgres, supabase_admin, supabase_auth_admin;
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA storage TO anon, authenticated, service_role;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- 0.1 Minimal Auth Users & Storage Stubs for Foreign Keys and Early Seed

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS UUID LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$;

CREATE OR REPLACE FUNCTION auth.role()
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('request.jwt.claim.role', true), '')::text;
$$;

CREATE OR REPLACE FUNCTION auth.email()
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT nullif(current_setting('request.jwt.claim.email', true), '')::text;
$$;

GRANT EXECUTE ON FUNCTION auth.uid() TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION auth.role() TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION auth.email() TO anon, authenticated, service_role;

CREATE TABLE IF NOT EXISTS auth.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instance_id UUID,
    aud VARCHAR(255),
    role VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    encrypted_password VARCHAR(255),
    email_confirmed_at TIMESTAMPTZ,
    invited_at TIMESTAMPTZ,
    confirmation_token VARCHAR(255),
    confirmation_sent_at TIMESTAMPTZ,
    recovery_token VARCHAR(255),
    recovery_sent_at TIMESTAMPTZ,
    email_change_token_new VARCHAR(255),
    email_change VARCHAR(255),
    email_change_sent_at TIMESTAMPTZ,
    last_sign_in_at TIMESTAMPTZ,
    raw_app_meta_data JSONB DEFAULT '{}'::jsonb,
    raw_user_meta_data JSONB DEFAULT '{}'::jsonb,
    is_super_admin BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    phone TEXT DEFAULT NULL UNIQUE,
    phone_confirmed_at TIMESTAMPTZ DEFAULT NULL,
    phone_change TEXT DEFAULT '',
    phone_change_token VARCHAR(255) DEFAULT '',
    phone_change_sent_at TIMESTAMPTZ DEFAULT NULL,
    confirmed_at TIMESTAMPTZ GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current VARCHAR(255) DEFAULT '',
    email_change_confirm_status SMALLINT DEFAULT 0,
    banned_until TIMESTAMPTZ DEFAULT NULL,
    reauthentication_token VARCHAR(255) DEFAULT '',
    reauthentication_sent_at TIMESTAMPTZ DEFAULT NULL,
    is_sso_user BOOLEAN DEFAULT FALSE NOT NULL,
    deleted_at TIMESTAMPTZ DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS storage.buckets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    owner UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    public BOOLEAN DEFAULT FALSE,
    avif_autodetection BOOLEAN DEFAULT FALSE,
    file_size_limit BIGINT,
    allowed_mime_types TEXT[]
);

CREATE TABLE IF NOT EXISTS storage.objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket_id TEXT REFERENCES storage.buckets(id),
    name TEXT,
    owner UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB,
    path_tokens TEXT[] GENERATED ALWAYS AS (string_to_array(name, '/')) STORED
);

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION storage.foldername(name TEXT)
RETURNS TEXT[] LANGUAGE plpgsql AS $$
BEGIN
    RETURN string_to_array(name, '/');
END;
$$;

CREATE OR REPLACE FUNCTION storage.filename(name TEXT)
RETURNS TEXT LANGUAGE plpgsql AS $$
BEGIN
    RETURN split_part(name, '/', array_length(string_to_array(name, '/'), 1));
END;
$$;

CREATE OR REPLACE FUNCTION storage.extension(name TEXT)
RETURNS TEXT LANGUAGE plpgsql AS $$
BEGIN
    RETURN split_part(name, '.', array_length(string_to_array(name, '.'), 1));
END;
$$;


-- =============================================================================
-- 1. APP_SYSTEM_CONFIGS (Version Gating & Anti-Stale Cache Contract)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.app_system_configs (
    platform TEXT PRIMARY KEY CHECK (platform IN ('android', 'ios', 'web')),
    min_supported_version TEXT NOT NULL,
    latest_version TEXT NOT NULL,
    force_update_title TEXT,
    force_update_message TEXT,
    update_url TEXT NOT NULL,
    maintenance_mode BOOLEAN NOT NULL DEFAULT FALSE,
    maintenance_notice TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.app_system_configs IS 'System configuration and Version Gating contract for Flutter clients (prevents schema mismatch and stale web cache).';

-- Enable Row-Level Security
ALTER TABLE public.app_system_configs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Anyone (anon + authenticated) can read system configs to evaluate version gate on boot
CREATE POLICY "Allow public read of system configs"
ON public.app_system_configs FOR SELECT
TO public
USING (true);

-- RLS Policy: Only service_role can mutate version gating configurations
CREATE POLICY "Only service_role can modify system configs"
ON public.app_system_configs FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Seed Initial System Configurations
INSERT INTO public.app_system_configs (platform, min_supported_version, latest_version, force_update_title, force_update_message, update_url, maintenance_mode, maintenance_notice)
VALUES
    ('android', '1.0.0', '1.0.0', 'Cập nhật ứng dụng', 'Vui lòng cập nhật phiên bản mới nhất để tiếp tục sử dụng Constellation nhịp nhàng.', 'https://play.google.com/store/apps/details?id=com.constellation.quire', false, NULL),
    ('ios', '1.0.0', '1.0.0', 'Bản cập nhật mới', 'Constellation đã có phiên bản hoàn thiện mới. Mời bạn cập nhật qua App Store.', 'https://apps.apple.com/app/constellation/id123456789', false, NULL),
    ('web', '1.0.0', '1.0.0', 'Nạp lại trang web', 'Đã có bản build mới. Trình duyệt cần nạp lại phiên bản mới để đồng bộ dữ liệu chuẩn xác.', 'https://app.constellation.internal', false, NULL)
ON CONFLICT (platform) DO UPDATE SET
    min_supported_version = EXCLUDED.min_supported_version,
    latest_version = EXCLUDED.latest_version,
    update_url = EXCLUDED.update_url,
    updated_at = NOW();


-- =============================================================================
-- 2. PROFILES (User Identity & Avatar Linking)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.profiles IS 'User profiles linked 1:1 with auth.users. Stores timestamped avatar path.';

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Authenticated users can view profiles
CREATE POLICY "Authenticated users can read profiles"
ON public.profiles FOR SELECT
TO authenticated
USING (true);

-- RLS Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- RLS Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Trigger: Automatically create public.profiles row when auth.users is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'display_name',
            split_part(NEW.email, '@', 1),
            'User ' || substr(NEW.id::text, 1, 8)
        ),
        NULL
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- =============================================================================
-- 3. QUIRE CIRCLES & INTIMATE CIRCLE MEMBERS
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.quire_circles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.quire_circles IS 'Quire intimacy circles (Zero Public Graph: intimate friends circle managed by Backend, no hardcoded database ceiling).';

ALTER TABLE public.quire_circles ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.quire_circle_members (
    circle_id UUID NOT NULL REFERENCES public.quire_circles(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (circle_id, user_id)
);

COMMENT ON TABLE public.quire_circle_members IS 'Membership list for Quire circles. Membership limits managed flexibly at Backend layer.';

ALTER TABLE public.quire_circle_members ENABLE ROW LEVEL SECURITY;

-- Note: Hardcoded 12-member trigger dropped per architecture update. Limit/policy managed at Golang Backend.
-- Trigger: Automatically add circle creator as first member
CREATE OR REPLACE FUNCTION public.handle_new_circle_creator()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.quire_circle_members (circle_id, user_id)
    VALUES (NEW.id, NEW.created_by)
    ON CONFLICT (circle_id, user_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_circle_created ON public.quire_circles;
CREATE TRIGGER on_circle_created
    AFTER INSERT ON public.quire_circles
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_circle_creator();

-- RLS Policies for quire_circles
CREATE POLICY "Circle members can read circle"
ON public.quire_circles FOR SELECT
TO authenticated
USING (
    created_by = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.quire_circle_members cm
        WHERE cm.circle_id = quire_circles.id
          AND cm.user_id = auth.uid()
    )
);

CREATE POLICY "Authenticated users can create circle"
ON public.quire_circles FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Circle creator can update circle"
ON public.quire_circles FOR UPDATE
TO authenticated
USING (created_by = auth.uid())
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Circle creator can delete circle"
ON public.quire_circles FOR DELETE
TO authenticated
USING (created_by = auth.uid());

-- RLS Policies for quire_circle_members
CREATE POLICY "Circle members can read membership"
ON public.quire_circle_members FOR SELECT
TO authenticated
USING (
    user_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.quire_circle_members cm
        WHERE cm.circle_id = quire_circle_members.circle_id
          AND cm.user_id = auth.uid()
    )
    OR EXISTS (
        SELECT 1 FROM public.quire_circles c
        WHERE c.id = quire_circle_members.circle_id
          AND c.created_by = auth.uid()
    )
);

CREATE POLICY "Circle creator can add members"
ON public.quire_circle_members FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.quire_circles c
        WHERE c.id = circle_id
          AND c.created_by = auth.uid()
    )
);

CREATE POLICY "Circle members can leave or creator can remove"
ON public.quire_circle_members FOR DELETE
TO authenticated
USING (
    user_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.quire_circles c
        WHERE c.id = quire_circle_members.circle_id
          AND c.created_by = auth.uid()
    )
);


-- =============================================================================
-- 4. QUIRE MOMENTS & MOMENT RECIPIENTS (30-Day Ephemeral Lifecycle)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.quire_moments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL REFERENCES public.quire_circles(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    image_path TEXT NOT NULL,
    caption TEXT,
    article_id UUID,
    reply_to_moment_id UUID REFERENCES public.quire_moments(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '30 days')
);

COMMENT ON TABLE public.quire_moments IS 'Quire photo moments. Expires and purges automatically after 30 days.';

ALTER TABLE public.quire_moments ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.quire_moment_recipients (
    moment_id UUID NOT NULL REFERENCES public.quire_moments(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    read_at TIMESTAMPTZ DEFAULT NULL, -- Quiet Computing: Read receipts OFF by default
    liked BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (moment_id, recipient_id)
);

COMMENT ON TABLE public.quire_moment_recipients IS 'Recipient states for moments. read_at is NULL by default to prevent social pressure.';

ALTER TABLE public.quire_moment_recipients ENABLE ROW LEVEL SECURITY;

-- RLS Policies for quire_moments
CREATE POLICY "Circle members can read moments"
ON public.quire_moments FOR SELECT
TO authenticated
USING (
    sender_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.quire_moment_recipients r
        WHERE r.moment_id = quire_moments.id
          AND r.recipient_id = auth.uid()
    )
);

CREATE POLICY "Circle members can insert moments"
ON public.quire_moments FOR INSERT
TO authenticated
WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
        SELECT 1 FROM public.quire_circle_members cm
        WHERE cm.circle_id = quire_moments.circle_id
          AND cm.user_id = auth.uid()
    )
);

CREATE POLICY "Sender can update own moment"
ON public.quire_moments FOR UPDATE
TO authenticated
USING (sender_id = auth.uid())
WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Sender can delete own moment"
ON public.quire_moments FOR DELETE
TO authenticated
USING (sender_id = auth.uid());

-- RLS Policies for quire_moment_recipients
CREATE POLICY "Recipient or sender can read recipient status"
ON public.quire_moment_recipients FOR SELECT
TO authenticated
USING (
    recipient_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM public.quire_moments m
        WHERE m.id = quire_moment_recipients.moment_id
          AND m.sender_id = auth.uid()
    )
);

CREATE POLICY "Sender can insert recipients"
ON public.quire_moment_recipients FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.quire_moments m
        WHERE m.id = moment_id
          AND m.sender_id = auth.uid()
    )
);

CREATE POLICY "Recipient can update own status"
ON public.quire_moment_recipients FOR UPDATE
TO authenticated
USING (recipient_id = auth.uid())
WITH CHECK (recipient_id = auth.uid());


-- =============================================================================
-- 5. DREAM JOURNAL: ENTRIES & ATTACHMENTS (Strict Sanctum Privacy)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.dream_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT,
    mood TEXT,
    lucidity_level INT CHECK (lucidity_level BETWEEN 1 AND 5),
    veil_layer INT NOT NULL DEFAULT 1 CHECK (veil_layer BETWEEN 1 AND 5),
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.dream_entries IS 'Dream Journal records protected by 5-Layer Veil Sanctum. Accessible ONLY to author.';

ALTER TABLE public.dream_entries ENABLE ROW LEVEL SECURITY;

CREATE TABLE IF NOT EXISTS public.dream_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dream_id UUID NOT NULL REFERENCES public.dream_entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.dream_attachments IS 'Attached photo memories for dream awakening. Strict author-only privacy.';

ALTER TABLE public.dream_attachments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for dream_entries (Author-Only Access)
CREATE POLICY "Author can read own dream entries"
ON public.dream_entries FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Author can insert own dream entries"
ON public.dream_entries FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Author can update own dream entries"
ON public.dream_entries FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Author can delete own dream entries"
ON public.dream_entries FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- RLS Policies for dream_attachments (Author-Only Access)
CREATE POLICY "Author can read own dream attachments"
ON public.dream_attachments FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Author can insert own dream attachments"
ON public.dream_attachments FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
        SELECT 1 FROM public.dream_entries d
        WHERE d.id = dream_id
          AND d.user_id = auth.uid()
    )
);

CREATE POLICY "Author can delete own dream attachments"
ON public.dream_attachments FOR DELETE
TO authenticated
USING (user_id = auth.uid());


-- =============================================================================
-- 6. SUPABASE STORAGE BUCKETS (avatars, quire-moments, dream-attachments)
-- =============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    (
        'avatars',
        'avatars',
        true,
        1048576, -- 1MB
        ARRAY['image/webp', 'image/jpeg', 'image/png']
    ),
    (
        'quire-moments',
        'quire-moments',
        false,
        5242880, -- 5MB
        ARRAY['image/webp', 'image/jpeg', 'image/png']
    ),
    (
        'dream-attachments',
        'dream-attachments',
        false,
        10485760, -- 10MB
        ARRAY['image/webp', 'image/jpeg', 'image/png']
    )
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;


-- =============================================================================
-- 7. STORAGE OBJECTS ROW-LEVEL SECURITY (storage.objects)
-- =============================================================================

-- 7.1. BUCKET: avatars (avatars/{user_id}/avatar_{timestamp}.webp)
CREATE POLICY "Public Avatars Access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

CREATE POLICY "User Can Upload Own Avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "User Can Update Own Avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "User Can Delete Own Avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 7.2. BUCKET: quire-moments (quire-moments/{circle_id}/{moment_id}.webp)
CREATE POLICY "Circle Members Can Access Moment Images"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'quire-moments'
    AND (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND EXISTS (
        SELECT 1 FROM public.quire_circle_members cm
        WHERE cm.circle_id = (storage.foldername(name))[1]::uuid
          AND cm.user_id = auth.uid()
    )
);

CREATE POLICY "Circle Member Can Upload Moment"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'quire-moments'
    AND (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND EXISTS (
        SELECT 1 FROM public.quire_circle_members cm
        WHERE cm.circle_id = (storage.foldername(name))[1]::uuid
          AND cm.user_id = auth.uid()
    )
);

CREATE POLICY "Sender Can Delete Own Moment Image"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'quire-moments'
    AND (storage.foldername(name))[1] ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND EXISTS (
        SELECT 1 FROM public.quire_moments m
        WHERE m.circle_id = (storage.foldername(name))[1]::uuid
          AND (name = m.image_path OR name LIKE '%' || m.id::text || '%')
          AND m.sender_id = auth.uid()
    )
);

-- 7.3. BUCKET: dream-attachments (dream-attachments/{user_id}/{dream_id}/{photo_id}.webp)
CREATE POLICY "User Can Access Own Dream Attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'dream-attachments'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "User Can Upload Own Dream Attachments"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'dream-attachments'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "User Can Delete Own Dream Attachments"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'dream-attachments'
    AND (storage.foldername(name))[1] = auth.uid()::text
);


-- =============================================================================
-- 8. AUTOMATED 30-DAY PURGE MECHANISM (pg_cron & Stored Procedure)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.purge_expired_quire_moments()
RETURNS TABLE(purged_moments_count INT, purged_storage_files_count INT) AS $$
DECLARE
    v_purged_moments INT := 0;
    v_purged_files INT := 0;
    v_rec RECORD;
BEGIN
    -- 1. Identify expired moments and clean up corresponding storage objects physically
    FOR v_rec IN
        SELECT id, circle_id, image_path
        FROM public.quire_moments
        WHERE expires_at < NOW()
    LOOP
        DELETE FROM storage.objects
        WHERE bucket_id = 'quire-moments'
          AND (name = v_rec.image_path OR name LIKE v_rec.circle_id::text || '/' || v_rec.id::text || '%');
        v_purged_files := v_purged_files + 1;
    END LOOP;

    -- 2. Delete expired moments (cascades to quire_moment_recipients)
    WITH deleted_moments AS (
        DELETE FROM public.quire_moments
        WHERE expires_at < NOW()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_purged_moments FROM deleted_moments;

    RETURN QUERY SELECT v_purged_moments, v_purged_files;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.purge_expired_quire_moments() IS 'Daily batch purge procedure for Quire moments older than 30 days. Cascades recipients and purges physical storage objects.';

-- Schedule automated daily purge at 03:00 AM UTC using pg_cron if available
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        -- Remove previous schedule if exists to prevent duplicates
        PERFORM cron.unschedule('daily_purge_expired_quire_moments')
        WHERE EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'daily_purge_expired_quire_moments');

        PERFORM cron.schedule(
            'daily_purge_expired_quire_moments',
            '0 3 * * *',
            'SELECT public.purge_expired_quire_moments();'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'pg_cron job scheduling skipped (extension not active or permissions deferred). Procedure public.purge_expired_quire_moments() is ready for manual or external cron invocation.';
END $$;


-- =============================================================================
-- 9. INVARIANT ENFORCEMENT: THE VOID NON-PERSISTENCE CHECK
-- =============================================================================
-- Invariant verified from doc/patterns/ephemeral-privacy-lifecycles.md:
-- Zero data from After Midnight's The Void enters Supabase or persistence.
-- We verify no 'void' or 'midnight' tables exist in the public schema.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
          AND (table_name LIKE '%void%' OR table_name LIKE '%midnight%')
    ) THEN
        RAISE EXCEPTION 'CRITICAL INVARIANT VIOLATION: The Void / After Midnight data persistence is strictly prohibited.';
    END IF;
END $$;
