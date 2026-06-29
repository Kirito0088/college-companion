-- ============================================================================
-- College Companion — MVP Database Foundation
-- Migration: 00001_mvp_foundation
-- ============================================================================
--
-- Creates the complete production-ready schema for the College Companion MVP.
--
-- Tables (8):
--   users, semesters, subjects, timetable,
--   attendance, assignments, internal_marks, user_settings
--
-- Design sources:
--   docs/backend/database.md    — table definitions, relationships, IDs
--   docs/backend/security.md    — RLS, auth, policies
--   docs/backend/sync-engine.md — offline-first, conflict resolution
--   docs/00-project-vision.md   — core modules, philosophy
--   docs/08-screen-specifications.md — screen data requirements
--   docs/11-decision-log.md     — CC-0007 (Supabase Auth)
--
-- Key decisions:
--   - Supabase user ID (text) as users PK (CC-0007)
--   - UUID PKs on all other tables (database.md)
--   - Soft delete via deleted_at (database.md)
--   - RLS on every table — production policies only (security.md)
--   - No temporary anon bypass policies
--   - updated_at auto-trigger on every table
--   - No sync metadata — sync state belongs in local SQLite (sync-engine.md)
--   - working_days as smallint[] for consistency with timetable.day_of_week
--   - auth.uid()::text cast — user_id columns are text, auth.uid() returns uuid
--
-- RLS timing decision:
--   RLS is enabled immediately with production policies, even before the
--   Firebase→Supabase JWT bridge exists. This is intentional:
--   1. The anon key is public (embedded in the app binary). Without RLS,
--      anyone who extracts it has full database access.
--   2. The app is offline-first — sync failures are already handled
--      gracefully (sync-engine.md §111–119).
--   3. security.md: "Security is a core feature and must never be
--      compromised for convenience."
--   4. Deferring RLS creates a window of vulnerability and risk of
--      shipping to production without protection.
-- ============================================================================


-- ════════════════════════════════════════════════════════════════════════════
-- EXTENSIONS
-- ════════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- ════════════════════════════════════════════════════════════════════════════
-- TRIGGER FUNCTION
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.update_updated_at_column()
  IS 'Automatically sets updated_at to now() on every row UPDATE.';


-- ════════════════════════════════════════════════════════════════════════════
-- TABLES
-- ════════════════════════════════════════════════════════════════════════════


-- ────────────────────────────────────────────────────────────────────────────
-- 1. users — User profiles (Supabase user ID as PK)
-- ────────────────────────────────────────────────────────────────────────────
-- Stores the minimum user information documented in database.md:
-- User ID, Name, Email, Profile Photo, Created At.
-- The PK is a text column holding the Supabase user ID.

CREATE TABLE public.users (
  id            text        PRIMARY KEY,
  name          text        NOT NULL,
  email         text        NOT NULL,
  profile_photo text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.users              IS 'User profiles synced from Supabase Auth. One row per authenticated user.';
COMMENT ON COLUMN public.users.id           IS 'Supabase user ID — canonical user identifier (text).';
COMMENT ON COLUMN public.users.name         IS 'Display name from the Google account.';
COMMENT ON COLUMN public.users.email        IS 'Email address from the Google account.';
COMMENT ON COLUMN public.users.profile_photo IS 'Google profile photo URL. Nullable if unavailable.';
COMMENT ON COLUMN public.users.created_at   IS 'Row creation timestamp (UTC).';
COMMENT ON COLUMN public.users.updated_at   IS 'Last modification timestamp (UTC). Auto-updated by trigger.';


-- ────────────────────────────────────────────────────────────────────────────
-- 2. semesters — Academic semesters
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Semester Name, Working Days, Current Semester, Archived.
-- working_days uses smallint[] (not text[]) for consistency with
-- timetable.day_of_week. Mapping: 0=Monday … 6=Sunday (ISO 8601).

CREATE TABLE public.semesters (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      text        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name         text        NOT NULL,
  working_days smallint[]  NOT NULL DEFAULT '{}',
  is_current   boolean     NOT NULL DEFAULT false,
  is_archived  boolean     NOT NULL DEFAULT false,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  deleted_at   timestamptz,

  CONSTRAINT chk_working_days_valid
    CHECK (working_days <@ ARRAY[0,1,2,3,4,5,6]::smallint[])
);

COMMENT ON TABLE  public.semesters              IS 'Academic semesters belonging to a user. Supports archiving and soft delete.';
COMMENT ON COLUMN public.semesters.user_id      IS 'Owner — references users(id). Cascade deletes all semesters when user is removed.';
COMMENT ON COLUMN public.semesters.name         IS 'User-defined semester label (e.g. "Semester 5", "Fall 2026").';
COMMENT ON COLUMN public.semesters.working_days IS 'Array of day-of-week integers: 0=Mon, 1=Tue, 2=Wed, 3=Thu, 4=Fri, 5=Sat, 6=Sun. Consistent with timetable.day_of_week.';
COMMENT ON COLUMN public.semesters.is_current   IS 'Whether this is the active semester. Only one per user should be true.';
COMMENT ON COLUMN public.semesters.is_archived  IS 'Whether this semester has been archived. Archived semesters are hidden from active views.';
COMMENT ON COLUMN public.semesters.deleted_at   IS 'Soft delete timestamp. NULL means the record is active.';


-- ────────────────────────────────────────────────────────────────────────────
-- 3. subjects — Subjects within a semester
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Subject Name, Faculty, Type, Semester ID.
-- user_id is denormalized for efficient RLS filtering — every RLS policy
-- evaluates on every query, so avoiding a JOIN to resolve ownership is
-- worth the minor denormalization.

CREATE TABLE public.subjects (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     text        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  semester_id uuid        NOT NULL REFERENCES public.semesters(id) ON DELETE CASCADE,
  name        text        NOT NULL,
  faculty     text,
  type        text        NOT NULL DEFAULT 'theory'
                          CHECK (type IN ('theory', 'practical', 'tutorial')),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  deleted_at  timestamptz
);

COMMENT ON TABLE  public.subjects             IS 'Subjects within a semester. Central entity referenced by timetable, attendance, assignments, and internal_marks.';
COMMENT ON COLUMN public.subjects.user_id     IS 'Denormalized from semesters for RLS performance — avoids JOIN on every policy evaluation.';
COMMENT ON COLUMN public.subjects.semester_id IS 'Parent semester. Cascade deletes all subjects when semester is removed.';
COMMENT ON COLUMN public.subjects.name        IS 'Subject name (e.g. "Data Structures", "Physics Lab").';
COMMENT ON COLUMN public.subjects.faculty     IS 'Faculty/professor name. Nullable — may not be known at creation time.';
COMMENT ON COLUMN public.subjects.type        IS 'Subject type: theory, practical, or tutorial. Defaults to theory.';
COMMENT ON COLUMN public.subjects.deleted_at  IS 'Soft delete timestamp. NULL means the record is active.';


-- ────────────────────────────────────────────────────────────────────────────
-- 4. timetable — Weekly lecture schedule
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Day, Start Time, End Time, Subject, Room, Lecture Type.
-- No direct semester_id — the relationship is captured through subject_id →
-- subjects.semester_id. Denormalizing semester_id here would risk data
-- inconsistency without justification (see architecture review §3).

CREATE TABLE public.timetable (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      text        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id   uuid        NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  day_of_week  smallint    NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time   time        NOT NULL,
  end_time     time        NOT NULL,
  room         text,
  lecture_type text        NOT NULL DEFAULT 'theory'
                           CHECK (lecture_type IN ('theory', 'practical', 'tutorial')),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  deleted_at   timestamptz,

  CONSTRAINT chk_timetable_time_order CHECK (end_time > start_time)
);

COMMENT ON TABLE  public.timetable              IS 'Weekly lecture schedule. Each row is one time slot on one day for one subject.';
COMMENT ON COLUMN public.timetable.user_id      IS 'Denormalized for RLS performance.';
COMMENT ON COLUMN public.timetable.subject_id   IS 'The subject taught in this slot. Semester is resolved via subjects.semester_id.';
COMMENT ON COLUMN public.timetable.day_of_week  IS 'ISO 8601 day: 0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, 4=Friday, 5=Saturday, 6=Sunday.';
COMMENT ON COLUMN public.timetable.start_time   IS 'Lecture start time (local). Must be before end_time (enforced by chk_timetable_time_order).';
COMMENT ON COLUMN public.timetable.end_time     IS 'Lecture end time (local). Must be after start_time.';
COMMENT ON COLUMN public.timetable.room         IS 'Classroom or lab identifier. Nullable — may not be assigned.';
COMMENT ON COLUMN public.timetable.lecture_type  IS 'Type of lecture in this slot: theory, practical, or tutorial.';
COMMENT ON COLUMN public.timetable.deleted_at   IS 'Soft delete timestamp. NULL means the record is active.';


-- ────────────────────────────────────────────────────────────────────────────
-- 5. attendance — Daily attendance records
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Subject, Date, Status, Lecture Type, Proof Image, Notes.
-- Status values from 08-screen-specifications.md §5 (Attendance actions):
-- present, absent, cancelled, faculty_absent, holiday.

CREATE TABLE public.attendance (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         text        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id      uuid        NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  date            date        NOT NULL,
  status          text        NOT NULL
                              CHECK (status IN ('present', 'absent', 'cancelled',
                                                'faculty_absent', 'holiday')),
  lecture_type    text        NOT NULL DEFAULT 'theory'
                              CHECK (lecture_type IN ('theory', 'practical', 'tutorial')),
  proof_image_url text,
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  deleted_at      timestamptz,

  -- Prevent duplicate attendance for the same subject/type on the same day.
  CONSTRAINT uq_attendance_subject_date_type
    UNIQUE (user_id, subject_id, date, lecture_type)
);

COMMENT ON TABLE  public.attendance                 IS 'Daily attendance records. One row per subject per lecture type per day.';
COMMENT ON COLUMN public.attendance.user_id         IS 'Denormalized for RLS performance.';
COMMENT ON COLUMN public.attendance.subject_id      IS 'The subject this attendance record belongs to.';
COMMENT ON COLUMN public.attendance.date            IS 'The calendar date of the lecture.';
COMMENT ON COLUMN public.attendance.status          IS 'Attendance status: present, absent, cancelled, faculty_absent, or holiday.';
COMMENT ON COLUMN public.attendance.lecture_type    IS 'Type of lecture attended: theory, practical, or tutorial. Part of the uniqueness constraint.';
COMMENT ON COLUMN public.attendance.proof_image_url IS 'Supabase Storage URL for attendance proof image. Nullable — proof is optional.';
COMMENT ON COLUMN public.attendance.notes           IS 'Optional notes about the attendance record.';
COMMENT ON COLUMN public.attendance.deleted_at      IS 'Soft delete timestamp. NULL means the record is active.';


-- ────────────────────────────────────────────────────────────────────────────
-- 6. assignments — Assignment tracking
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Title, Description, Due Date, Subject, Status.
-- completed_at added for genuine long-term value — tracks the specific
-- moment status changed to 'completed', distinct from updated_at which
-- changes on any edit. See architecture review §4.

CREATE TABLE public.assignments (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      text        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id   uuid        NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  title        text        NOT NULL,
  description  text,
  due_date     date        NOT NULL,
  status       text        NOT NULL DEFAULT 'pending'
                           CHECK (status IN ('pending', 'completed')),
  completed_at timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now(),
  deleted_at   timestamptz
);

COMMENT ON TABLE  public.assignments              IS 'Student assignments with due dates, status tracking, and completion timestamps.';
COMMENT ON COLUMN public.assignments.user_id      IS 'Denormalized for RLS performance.';
COMMENT ON COLUMN public.assignments.subject_id   IS 'The subject this assignment belongs to.';
COMMENT ON COLUMN public.assignments.title        IS 'Assignment title.';
COMMENT ON COLUMN public.assignments.description  IS 'Optional detailed description of the assignment.';
COMMENT ON COLUMN public.assignments.due_date     IS 'The date the assignment is due. Used for sorting and overdue detection.';
COMMENT ON COLUMN public.assignments.status       IS 'Assignment status: pending or completed.';
COMMENT ON COLUMN public.assignments.completed_at IS 'Timestamp when status changed to completed. NULL while pending. Distinct from updated_at which changes on any edit.';
COMMENT ON COLUMN public.assignments.deleted_at   IS 'Soft delete timestamp. NULL means the record is active.';


-- ────────────────────────────────────────────────────────────────────────────
-- 7. internal_marks — Internal assessment scores
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Subject, Exam Name, Marks Obtained, Maximum Marks.
-- exam_name is free-form text (not an enum) to accommodate diverse
-- Indian college naming conventions: UT-1, Mid Sem, Prelim, Lab Viva, etc.
-- See architecture review §5.

CREATE TABLE public.internal_marks (
  id             uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        text         NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  subject_id     uuid         NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  exam_name      text         NOT NULL,
  marks_obtained numeric(5,2) NOT NULL CHECK (marks_obtained >= 0),
  max_marks      numeric(5,2) NOT NULL CHECK (max_marks > 0),
  created_at     timestamptz  NOT NULL DEFAULT now(),
  updated_at     timestamptz  NOT NULL DEFAULT now(),
  deleted_at     timestamptz,

  CONSTRAINT chk_marks_within_range CHECK (marks_obtained <= max_marks)
);

COMMENT ON TABLE  public.internal_marks                IS 'Internal assessment scores (unit tests, quizzes, mid-terms, etc.).';
COMMENT ON COLUMN public.internal_marks.user_id        IS 'Denormalized for RLS performance.';
COMMENT ON COLUMN public.internal_marks.subject_id     IS 'The subject this assessment belongs to.';
COMMENT ON COLUMN public.internal_marks.exam_name      IS 'Free-form assessment label (e.g. "UT-1", "Mid Sem", "Quiz 3", "Lab Viva"). Not an enum — accommodates diverse college naming conventions.';
COMMENT ON COLUMN public.internal_marks.marks_obtained IS 'Score achieved. Must be >= 0 and <= max_marks (enforced by chk_marks_within_range).';
COMMENT ON COLUMN public.internal_marks.max_marks      IS 'Maximum possible score. Must be > 0.';
COMMENT ON COLUMN public.internal_marks.deleted_at     IS 'Soft delete timestamp. NULL means the record is active.';


-- ────────────────────────────────────────────────────────────────────────────
-- 8. user_settings — Per-user app preferences
-- ────────────────────────────────────────────────────────────────────────────
-- Per database.md: Notifications, Enabled Modules, Theme, User Preferences.
-- Hybrid approach: structured columns for stable, queryable settings;
-- JSONB for extensible, evolving preferences. See architecture review §7.
-- One row per user (UNIQUE on user_id).

CREATE TABLE public.user_settings (
  id                    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               text        NOT NULL UNIQUE
                                    REFERENCES public.users(id) ON DELETE CASCADE,
  notifications_enabled boolean     NOT NULL DEFAULT true,
  enabled_modules       jsonb       NOT NULL DEFAULT '{}'::jsonb,
  theme                 text        NOT NULL DEFAULT 'dark',
  preferences           jsonb       NOT NULL DEFAULT '{}'::jsonb,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE  public.user_settings                       IS 'Per-user application preferences. Exactly one row per user (UNIQUE on user_id).';
COMMENT ON COLUMN public.user_settings.user_id               IS 'Owner — 1:1 relationship with users. UNIQUE ensures one settings row per user.';
COMMENT ON COLUMN public.user_settings.notifications_enabled IS 'Whether push notifications are enabled. Structured column for direct queryability.';
COMMENT ON COLUMN public.user_settings.enabled_modules       IS 'JSONB map of module names to enabled booleans (e.g. {"attendance": true, "assignments": true}). JSONB for extensibility as modules evolve.';
COMMENT ON COLUMN public.user_settings.theme                 IS 'UI theme preference. Defaults to dark (currently the only supported theme). Structured for future light mode support.';
COMMENT ON COLUMN public.user_settings.preferences           IS 'Flexible JSONB catch-all for future user preferences (e.g. default_view, calendar_start_day). Avoids schema migrations for new settings.';


-- ════════════════════════════════════════════════════════════════════════════
-- INDEXES
-- ════════════════════════════════════════════════════════════════════════════
-- Strategic indexes per database.md §Indexing: User ID, Semester ID,
-- Subject ID, Date, Status. Avoids unnecessary indexes.

-- semesters
CREATE INDEX idx_semesters_user_id ON public.semesters (user_id);

-- subjects
CREATE INDEX idx_subjects_user_id     ON public.subjects (user_id);
CREATE INDEX idx_subjects_semester_id ON public.subjects (semester_id);

-- timetable
CREATE INDEX idx_timetable_user_id    ON public.timetable (user_id);
CREATE INDEX idx_timetable_subject_id ON public.timetable (subject_id);

-- attendance
CREATE INDEX idx_attendance_user_id    ON public.attendance (user_id);
CREATE INDEX idx_attendance_subject_id ON public.attendance (subject_id);
CREATE INDEX idx_attendance_date       ON public.attendance (date);
CREATE INDEX idx_attendance_status     ON public.attendance (status);

-- assignments
CREATE INDEX idx_assignments_user_id    ON public.assignments (user_id);
CREATE INDEX idx_assignments_subject_id ON public.assignments (subject_id);
CREATE INDEX idx_assignments_due_date   ON public.assignments (due_date);
CREATE INDEX idx_assignments_status     ON public.assignments (status);

-- internal_marks
CREATE INDEX idx_internal_marks_user_id    ON public.internal_marks (user_id);
CREATE INDEX idx_internal_marks_subject_id ON public.internal_marks (subject_id);

-- user_settings: UNIQUE constraint on user_id already creates an implicit index.


-- ════════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY — Enable on all tables
-- ════════════════════════════════════════════════════════════════════════════
-- Per security.md: "Every table MUST have Row Level Security enabled."
--
-- RLS is enabled IMMEDIATELY — not deferred to a later migration.
-- Rationale:
--   1. The Supabase anon key is public (embedded in the app binary).
--      Without RLS, anyone who extracts it has full database access.
--   2. Deferring creates a window of vulnerability and risk of shipping
--      to production without protection.
--   3. The app is offline-first. Sync failures are already handled
--      gracefully — UserRepository catches all exceptions.
--   4. security.md: "If there is ever a conflict between convenience
--      and security, security wins."

ALTER TABLE public.users          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.semesters      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timetable      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.internal_marks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings  ENABLE ROW LEVEL SECURITY;


-- ════════════════════════════════════════════════════════════════════════════
-- RLS POLICIES — Production only (auth.jwt()->>'sub')
-- ════════════════════════════════════════════════════════════════════════════
-- Per security.md: "Every query must be restricted to the authenticated user."
-- Per security.md: "User A must never be capable of viewing, editing or
-- deleting User B's data. No exceptions."
--
-- auth.jwt()->>'sub' extracts the raw text user ID from the verified JWT.
-- This works for Supabase-generated user IDs stored as text in user_id columns.

-- ── users ──────────────────────────────────────────────────────────────────

CREATE POLICY users_select ON public.users
  FOR SELECT USING (id = auth.uid()::text);

CREATE POLICY users_insert ON public.users
  FOR INSERT WITH CHECK (id = auth.uid()::text);

CREATE POLICY users_update ON public.users
  FOR UPDATE USING (id = auth.uid()::text)
  WITH CHECK (id = auth.uid()::text);

CREATE POLICY users_delete ON public.users
  FOR DELETE USING (id = auth.uid()::text);

-- ── semesters ──────────────────────────────────────────────────────────────

CREATE POLICY semesters_select ON public.semesters
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY semesters_insert ON public.semesters
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY semesters_update ON public.semesters
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY semesters_delete ON public.semesters
  FOR DELETE USING (user_id = auth.uid()::text);

-- ── subjects ───────────────────────────────────────────────────────────────

CREATE POLICY subjects_select ON public.subjects
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY subjects_insert ON public.subjects
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY subjects_update ON public.subjects
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY subjects_delete ON public.subjects
  FOR DELETE USING (user_id = auth.uid()::text);

-- ── timetable ──────────────────────────────────────────────────────────────

CREATE POLICY timetable_select ON public.timetable
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY timetable_insert ON public.timetable
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY timetable_update ON public.timetable
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY timetable_delete ON public.timetable
  FOR DELETE USING (user_id = auth.uid()::text);

-- ── attendance ─────────────────────────────────────────────────────────────

CREATE POLICY attendance_select ON public.attendance
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY attendance_insert ON public.attendance
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY attendance_update ON public.attendance
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY attendance_delete ON public.attendance
  FOR DELETE USING (user_id = auth.uid()::text);

-- ── assignments ────────────────────────────────────────────────────────────

CREATE POLICY assignments_select ON public.assignments
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY assignments_insert ON public.assignments
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY assignments_update ON public.assignments
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY assignments_delete ON public.assignments
  FOR DELETE USING (user_id = auth.uid()::text);

-- ── internal_marks ─────────────────────────────────────────────────────────

CREATE POLICY internal_marks_select ON public.internal_marks
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY internal_marks_insert ON public.internal_marks
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY internal_marks_update ON public.internal_marks
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY internal_marks_delete ON public.internal_marks
  FOR DELETE USING (user_id = auth.uid()::text);

-- ── user_settings ──────────────────────────────────────────────────────────

CREATE POLICY user_settings_select ON public.user_settings
  FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY user_settings_insert ON public.user_settings
  FOR INSERT WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY user_settings_update ON public.user_settings
  FOR UPDATE USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

CREATE POLICY user_settings_delete ON public.user_settings
  FOR DELETE USING (user_id = auth.uid()::text);


-- ════════════════════════════════════════════════════════════════════════════
-- TRIGGERS — Auto-update updated_at on every table
-- ════════════════════════════════════════════════════════════════════════════

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_semesters_updated_at
  BEFORE UPDATE ON public.semesters
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_subjects_updated_at
  BEFORE UPDATE ON public.subjects
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_timetable_updated_at
  BEFORE UPDATE ON public.timetable
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_attendance_updated_at
  BEFORE UPDATE ON public.attendance
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_assignments_updated_at
  BEFORE UPDATE ON public.assignments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_internal_marks_updated_at
  BEFORE UPDATE ON public.internal_marks
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_user_settings_updated_at
  BEFORE UPDATE ON public.user_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


-- ════════════════════════════════════════════════════════════════════════════
-- Migration complete.
-- ════════════════════════════════════════════════════════════════════════════
