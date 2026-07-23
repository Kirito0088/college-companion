# Project: College Companion Phase 4 & Phase 5

## Architecture
- Flutter Application with Drift (SQLite) local database layer and Supabase cloud persistence.
- Offline-first paradigm: local Drift DB is the single source of truth; local changes write to `sync_queue` table for async processing to Supabase when network is connected.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 0 | Exploration & Analysis | Audit 9 Repos, DB indices, sync queue, tests | None | DONE |
| 1 | Drift Repos & Indices (Phase 4) | Register Users table, add @TableIndex across all 10 tables, complete all 9 Repositories CRUD/streams/transactions/soft-delete/errors, refactor UserRepository to offline-first | M0 | DONE |
| 2 | Supabase Sync & Auth (Phase 5) | Fix sync_queue table schema (targetTable), local write enqueuing in repos, complete SyncService processing, backoff, connectivity listener, auth token refresh | M1 | DONE |
| 3 | Comprehensive Testing & Audit | Write unit/integration tests for all 9 repos, SyncService, DB schema, network drop & edge cases. Pass flutter test 100%. Reviewer, Challenger & Forensic Audit | M1, M2 | DONE |

## Interface Contracts
### Drift Database & Repositories (Phase 4) - VERIFIED DONE
- **AppDatabase**: Registers 11 tables (`Semesters`, `Subjects`, `Timetable`, `Attendance`, `Assignments`, `InternalMarks`, `UserSettings`, `SyncQueueItems`, `CalendarEvents`, `Resources`, `Users`).
- **Indices**: `@TableIndex` on foreign keys (`userId`, `semesterId`, `subjectId`), status fields, dates, and `deletedAt`.

### Sync Queue & Sync Engine (Phase 5) - VERIFIED DONE
- **SyncQueueItems Table**: `id` (int PK auto), `recordId` (text UUID), `targetTable` (text), `operation` ('INSERT'/'UPDATE'/'DELETE'), `retryCount` (int), `createdAt` (ISO text), `lastAttempt` (ISO text nullable), `error` (text nullable), `isSynced` (bool).
- **SyncService**: Background worker triggered on initialization and `ConnectivityService.onStatusChange` (when `connected`).
  - Reads `targetTable` + `recordId` from Drift.
  - Pushes payload to Supabase via `.upsert()` or `.delete()`.
  - Calculates exponential backoff: `2^retryCount * 500ms`, max retries: 5.

### Comprehensive Testing & Verification (Milestone 3) - VERIFIED DONE
- 100% repository unit test coverage across all 9 domain repositories + `UserSettingsRepository` + `SyncQueueRepository`.
- Complete unit test suite for `SyncService` (queue state transitions, exponential backoff, max retries limit, network drop handling).
- Database migration & schema instantiation unit tests.
- 100% test pass rate (`flutter test` - 114/114 passing tests, 0 `flutter analyze` issues).
- Challenger empirical stress testing verified (emissions, soft-deletes, transactions, indices, backoff).
- Forensic Auditor verdict: **CLEAN**.
