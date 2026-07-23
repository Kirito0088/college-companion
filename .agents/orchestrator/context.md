# Context Memory

## Project Location
`c:\Projects\college_companion_ui`

## Mission
Orchestrate Phase 4 (Drift Local Database Enterprise Completion) and Phase 5 (Supabase Sync Engine & Cloud Persistence).

## Core Requirements
- 9 Repositories: `SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, `UserRepository`.
- CRUD, reactive streams, transactions, soft deletion filtering (`is_deleted`), table indices.
- Offline-first Supabase sync engine: `sync_queue` background worker, exponential backoff, retry logic, deterministic conflict resolution.
- Supabase Auth persistence, token refresh, RLS policies.
- 100% test pass rate (`flutter test`).

## Key Files & Directories (To be populated by Explorers)
- `lib/core/database/`
- `lib/features/*/data/repositories/`
- `lib/core/sync/`
- `test/`
