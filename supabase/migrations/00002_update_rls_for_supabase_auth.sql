-- ════════════════════════════════════════════════════════════════════════════
-- Migration 00002: Update RLS policies for Supabase Third-Party Auth
-- ════════════════════════════════════════════════════════════════════════════
--
-- Context:
--   Supabase Third-Party Auth verifies Google OAuth tokens directly.
--   Users authenticate via `signInWithOAuth` with the Google provider.
--
-- Problem:
--   The original RLS policies used auth.uid()::text for user identification.
--   auth.uid() returns a UUID, but user_id columns are text. The cast fails,
--   auth.uid() returns NULL, and all policies deny access.
--
-- Solution:
--   Replace auth.uid()::text with (select auth.jwt()->>'sub') in all policies.
--   auth.jwt()->>'sub' returns the raw text value of the 'sub' claim,
--   which works for Supabase-generated user IDs.
--
-- Security:
--   The security semantics are IDENTICAL. Both expressions extract the
--   authenticated user's identifier from the verified JWT. The only
--   difference is the type: uuid vs text. Since user_id columns are
--   already text, this is a type-correct comparison.
--
-- Safety:
--   All 8 tables are currently empty (0 rows). This migration is atomic.
-- ════════════════════════════════════════════════════════════════════════════

BEGIN;

-- ── Drop existing policies (32 total) ────────────────────────────────────

-- users
DROP POLICY IF EXISTS users_select ON public.users;
DROP POLICY IF EXISTS users_insert ON public.users;
DROP POLICY IF EXISTS users_update ON public.users;
DROP POLICY IF EXISTS users_delete ON public.users;

-- semesters
DROP POLICY IF EXISTS semesters_select ON public.semesters;
DROP POLICY IF EXISTS semesters_insert ON public.semesters;
DROP POLICY IF EXISTS semesters_update ON public.semesters;
DROP POLICY IF EXISTS semesters_delete ON public.semesters;

-- subjects
DROP POLICY IF EXISTS subjects_select ON public.subjects;
DROP POLICY IF EXISTS subjects_insert ON public.subjects;
DROP POLICY IF EXISTS subjects_update ON public.subjects;
DROP POLICY IF EXISTS subjects_delete ON public.subjects;

-- timetable
DROP POLICY IF EXISTS timetable_select ON public.timetable;
DROP POLICY IF EXISTS timetable_insert ON public.timetable;
DROP POLICY IF EXISTS timetable_update ON public.timetable;
DROP POLICY IF EXISTS timetable_delete ON public.timetable;

-- attendance
DROP POLICY IF EXISTS attendance_select ON public.attendance;
DROP POLICY IF EXISTS attendance_insert ON public.attendance;
DROP POLICY IF EXISTS attendance_update ON public.attendance;
DROP POLICY IF EXISTS attendance_delete ON public.attendance;

-- assignments
DROP POLICY IF EXISTS assignments_select ON public.assignments;
DROP POLICY IF EXISTS assignments_insert ON public.assignments;
DROP POLICY IF EXISTS assignments_update ON public.assignments;
DROP POLICY IF EXISTS assignments_delete ON public.assignments;

-- internal_marks
DROP POLICY IF EXISTS internal_marks_select ON public.internal_marks;
DROP POLICY IF EXISTS internal_marks_insert ON public.internal_marks;
DROP POLICY IF EXISTS internal_marks_update ON public.internal_marks;
DROP POLICY IF EXISTS internal_marks_delete ON public.internal_marks;

-- user_settings
DROP POLICY IF EXISTS user_settings_select ON public.user_settings;
DROP POLICY IF EXISTS user_settings_insert ON public.user_settings;
DROP POLICY IF EXISTS user_settings_update ON public.user_settings;
DROP POLICY IF EXISTS user_settings_delete ON public.user_settings;


-- ── Recreate policies using auth.jwt()->>'sub' ──────────────────────────
-- Uses (select auth.jwt()->>'sub') for RLS optimization (evaluated once
-- per query, not per row).

-- users (PK is id, which stores the Supabase user ID)
CREATE POLICY users_select ON public.users
  FOR SELECT USING (id = (select auth.jwt()->>'sub'));
CREATE POLICY users_insert ON public.users
  FOR INSERT WITH CHECK (id = (select auth.jwt()->>'sub'));
CREATE POLICY users_update ON public.users
  FOR UPDATE USING (id = (select auth.jwt()->>'sub'))
             WITH CHECK (id = (select auth.jwt()->>'sub'));
CREATE POLICY users_delete ON public.users
  FOR DELETE USING (id = (select auth.jwt()->>'sub'));

-- semesters
CREATE POLICY semesters_select ON public.semesters
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY semesters_insert ON public.semesters
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY semesters_update ON public.semesters
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY semesters_delete ON public.semesters
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

-- subjects
CREATE POLICY subjects_select ON public.subjects
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY subjects_insert ON public.subjects
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY subjects_update ON public.subjects
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY subjects_delete ON public.subjects
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

-- timetable
CREATE POLICY timetable_select ON public.timetable
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY timetable_insert ON public.timetable
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY timetable_update ON public.timetable
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY timetable_delete ON public.timetable
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

-- attendance
CREATE POLICY attendance_select ON public.attendance
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY attendance_insert ON public.attendance
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY attendance_update ON public.attendance
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY attendance_delete ON public.attendance
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

-- assignments
CREATE POLICY assignments_select ON public.assignments
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY assignments_insert ON public.assignments
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY assignments_update ON public.assignments
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY assignments_delete ON public.assignments
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

-- internal_marks
CREATE POLICY internal_marks_select ON public.internal_marks
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY internal_marks_insert ON public.internal_marks
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY internal_marks_update ON public.internal_marks
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY internal_marks_delete ON public.internal_marks
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

-- user_settings
CREATE POLICY user_settings_select ON public.user_settings
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY user_settings_insert ON public.user_settings
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY user_settings_update ON public.user_settings
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
             WITH CHECK (user_id = (select auth.jwt()->>'sub'));
CREATE POLICY user_settings_delete ON public.user_settings
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));

COMMIT;
