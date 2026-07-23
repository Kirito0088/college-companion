# Original User Request

## Initial Request — 2026-07-23T18:26:55Z

Complete Phase 4 (Drift Local Database) and Phase 5 (Supabase Backend & Sync Engine) of the College Companion application to 100% completion with enterprise-grade quality, offline-first reliability, full test coverage, and optimized SQL performance.

Working directory: c:\Projects\college_companion_ui

Requirements:

R1. Phase 4 — Drift Database Enterprise Completion
- Ensure all 9 repositories (SemesterRepository, SubjectRepository, AttendanceRepository, TimetableRepository, AssignmentRepository, CalendarRepository, ResourcesRepository, InternalMarksRepository, UserRepository) have comprehensive CRUD, reactive stream watching, transaction boundaries, soft deletion filtering, and error handling.
- Verify and optimize table indices in Drift for fast querying, join operations, and stream emissions.

R2. Phase 5 — Supabase Sync Engine & Cloud Persistence
- Implement background sync worker / queue manager using sync_queue table to process offline mutations when connectivity is restored.
- Implement exponential backoff, retry logic, and deterministic conflict resolution (local database as offline source of truth).
- Validate Supabase Auth session persistence, token refresh, and Row Level Security (RLS) policies.

R3. Comprehensive Verification & Enterprise Quality
- Unit & integration test coverage for all repositories, database migrations, sync queue state transitions, and edge cases (network drops, invalid payload, duplicate records).
- All tests must pass cleanly (flutter test).

Acceptance Criteria:
- 100% of repositories have full CRUD, reactive stream methods, and soft-delete filters.
- All table foreign keys and query indices are validated for zero full table scans on indexed columns.
- Offline mutations are queued in sync_queue table and automatically processed upon internet reconnection.
- Sync failures handle exponential backoff up to max retries without data corruption or lost mutations.
- 100% passing rate on unit and repository test suites (flutter test).
- Code strictly follows karpathy-guidelines and ponytail principles (surgical changes, zero over-engineering, minimalist implementation).

## Follow-up — 2026-07-24T00:45:14Z

Resume from Milestone 3 (Full Test Suite Verification & Audit). Your previous instance crashed due to quota limits just as you were running the final verifications.

Goal: Complete Phase 4 (Drift Database) and Phase 5 (Supabase Backend & Sync Engine) to 100% completion with Enterprise-grade Quality.

Working directory: `c:\Projects\college_companion_ui`

## Requirements

### R1. Phase 4 — Drift Database Enterprise Completion
- Ensure all 9 repositories (`SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, `UserRepository`) have comprehensive CRUD, reactive stream watching, transaction boundaries, soft deletion filtering, and error handling.
- Verify and optimize table indices in Drift for fast querying, join operations, and stream emissions.

### R2. Phase 5 — Supabase Sync Engine & Cloud Persistence
- Implement background sync worker / queue manager using `sync_queue` table to process offline mutations when connectivity is restored.
- Implement exponential backoff, retry logic, and deterministic conflict resolution (local database as offline source of truth).
- Validate Supabase Auth session persistence, token refresh, and Row Level Security (RLS) policies.

### R3. Comprehensive Verification & Enterprise Quality
- Unit & integration test coverage for all repositories, database migrations, sync queue state transitions, and edge cases (network drops, invalid payload, duplicate records).
- All tests must pass cleanly (`flutter test`).

## Acceptance Criteria

### Drift Database
- [x] 100% of repositories have full CRUD, reactive stream methods, and soft-delete filters
- [x] All table foreign keys and query indices are validated for zero full table scans on indexed columns

### Supabase Backend & Sync
- [x] Offline mutations are queued in `sync_queue` table and automatically processed upon internet reconnection
- [x] Sync failures handle exponential backoff up to max retries without data corruption or lost mutations

### Quality & Testing
- [x] 100% passing rate on unit and repository test suites (`flutter test`)
- [x] Code strictly follows `karpathy-guidelines` and `ponytail` principles (surgical changes, zero over-engineering, minimalist implementation)

Run the tests (which should now be 90/90 passing), perform your final Victory Audit, and report back your success so I can mark this overarching goal as complete!
