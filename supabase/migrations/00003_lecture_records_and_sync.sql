-- ============================================================================
-- College Companion — Phase 4 Backend Foundation
-- Migration: 00003_lecture_records_and_sync
-- ============================================================================
--
-- Replaces the legacy `attendance` table with the immutable `lecture_records`
-- ledger (Phase 4 §5). Evidence is local-only and has no cloud counterpart.
--
-- Changes:
--   DROP  attendance table + policies + trigger + indexes (0 rows, safe)
--   CREATE lecture_records — immutable, one per timetable lecture (1:1 UNIQUE)
--   CREATE indexes + RLS policies + updated_at trigger on lecture_records
--
-- Design sources:
--   Locked Attendance Record spec          — immutability §4, 1:1 §3, status §5
--   Phase 4 Finalized Architecture Addendum — §5 lecture_records schema
--   docs/backend/security.md               — RLS on every table
--   docs/backend/sync-engine.md            — sync metadata is local-only
--
-- Key decisions:
--   - NO deleted_at on lecture_records (spec §4: never deleted)
--   - NO sync metadata columns (local-only — sync engine owns that)
--   - timetable_id UNIQUE enforces 1:1 per lecture (spec §3)
--   - semester_id denormalized for per-semester export/verification
--   - status_text stores encoded primary|secondary pair (spec §5)
--   - Evidence stays local-only (spec §8/§16) — never synced to cloud
--   - RLS uses (select auth.jwt()->>'sub') pattern from 00002
--   - updated_at auto-trigger mirrors 00001 pattern
-- ============================================================================

BEGIN;

-- ════════════════════════════════════════════════════════════════════════════
-- 1. DROP LEGACY ATTENDANCE TABLE
-- ════════════════════════════════════════════════════════════════════════════
-- Zero production rows — safe to drop. The legacy attendance table stored
-- mutable per-day records with proof-image URLs (superseded by immutable
-- lecture_records + local-only evidence).

DROP POLICY IF EXISTS attendance_select ON public.attendance;
DROP POLICY IF EXISTS attendance_insert ON public.attendance;
DROP POLICY IF EXISTS attendance_update ON public.attendance;
DROP POLICY IF EXISTS attendance_delete ON public.attendance;

DROP TRIGGER IF EXISTS trg_attendance_updated_at ON public.attendance;
DROP INDEX IF EXISTS idx_attendance_user_id;
DROP INDEX IF EXISTS idx_attendance_subject_id;
DROP INDEX IF EXISTS idx_attendance_date;
DROP INDEX IF EXISTS idx_attendance_status;

DROP TABLE IF EXISTS public.attendance;


-- ════════════════════════════════════════════════════════════════════════════
-- 2. CREATE LECTURE_RECORDS — IMMUTABLE LEDGER
-- ════════════════════════════════════════════════════════════════════════════
-- One immutable row per timetable lecture (UNIQUE on timetable_id).
-- Business columns match the Drift `lecture_records` table exactly.
-- No deletedAt (spec §4), no sync-metadata (local-only).

CREATE TABLE public.lecture_records (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         text        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  timetable_id    uuid        NOT NULL REFERENCES public.timetable(id) ON DELETE CASCADE,
  subject_id      uuid        NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  semester_id     uuid        NOT NULL REFERENCES public.semesters(id) ON DELETE CASCADE,
  status_text     text        NOT NULL,
  note            text,
  recorded_at     timestamptz NOT NULL,
  device_timezone text        NOT NULL,
  app_version     text        NOT NULL,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),

  -- 1:1 — each timetable slot gets exactly one record (spec §3).
  CONSTRAINT uq_lecture_record_timetable UNIQUE (timetable_id)
);

COMMENT ON TABLE  public.lecture_records
  IS 'Immutable lecture attendance ledger. One row per timetable lecture (1:1). No soft delete — records are permanent (spec §4).';

COMMENT ON COLUMN public.lecture_records.user_id
  IS 'Owner — references users(id). Cascade deletes all records when user is removed.';

COMMENT ON COLUMN public.lecture_records.timetable_id
  IS 'The timetable slot this record belongs to. UNIQUE — one record per lecture (spec §3 1:1).';

COMMENT ON COLUMN public.lecture_records.subject_id
  IS 'The subject taught in this slot.';

COMMENT ON COLUMN public.lecture_records.semester_id
  IS 'Denormalized from subjects for per-semester export and verification queries.';

COMMENT ON COLUMN public.lecture_records.status_text
  IS 'Encoded primary|secondary attendance status (spec §5). Format: present | absent | cancelled, optionally with |secondary|other_text.';

COMMENT ON COLUMN public.lecture_records.note
  IS 'Optional immutable note (spec §7). Nullable.';

COMMENT ON COLUMN public.lecture_records.recorded_at
  IS 'UTC instant when the record was created (spec §11 metadata).';

COMMENT ON COLUMN public.lecture_records.device_timezone
  IS 'IANA timezone of the recording device (spec §11 metadata).';

COMMENT ON COLUMN public.lecture_records.app_version
  IS 'App version that created the record (spec §11 metadata).';

COMMENT ON COLUMN public.lecture_records.created_at
  IS 'Row creation timestamp (UTC). Auto-set by DEFAULT now().';

COMMENT ON COLUMN public.lecture_records.updated_at
  IS 'Last modification timestamp (UTC). Auto-updated by trigger. For sync-bookkeeping writes only.';


-- ════════════════════════════════════════════════════════════════════════════
-- 3. INDEXES
-- ════════════════════════════════════════════════════════════════════════════

CREATE INDEX idx_lecture_records_user_id      ON public.lecture_records (user_id);
CREATE INDEX idx_lecture_records_subject_id    ON public.lecture_records (subject_id);
CREATE INDEX idx_lecture_records_semester_id   ON public.lecture_records (semester_id);

-- timetable_id UNIQUE constraint already creates an implicit index.


-- ════════════════════════════════════════════════════════════════════════════
-- 4. ROW LEVEL SECURITY
-- ════════════════════════════════════════════════════════════════════════════
-- Pattern: (select auth.jwt()->>'sub') from 00002 — type-correct text
-- comparison for Supabase Third-Party Auth.

ALTER TABLE public.lecture_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY lecture_records_select ON public.lecture_records
  FOR SELECT USING (user_id = (select auth.jwt()->>'sub'));

CREATE POLICY lecture_records_insert ON public.lecture_records
  FOR INSERT WITH CHECK (user_id = (select auth.jwt()->>'sub'));

CREATE POLICY lecture_records_update ON public.lecture_records
  FOR UPDATE USING (user_id = (select auth.jwt()->>'sub'))
               WITH CHECK (user_id = (select auth.jwt()->>'sub'));

CREATE POLICY lecture_records_delete ON public.lecture_records
  FOR DELETE USING (user_id = (select auth.jwt()->>'sub'));


-- ════════════════════════════════════════════════════════════════════════════
-- 5. UPDATED_AT TRIGGER
-- ════════════════════════════════════════════════════════════════════════════
-- Uses the existing update_updated_at_column() function from 00001.
-- ticks on sync-bookkeeping writes from the Phase 5 engine.

CREATE TRIGGER trg_lecture_records_updated_at
  BEFORE UPDATE ON public.lecture_records
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


COMMIT;

-- ════════════════════════════════════════════════════════════════════════════
-- Migration complete.
-- ════════════════════════════════════════════════════════════════════════════