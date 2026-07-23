# Master Plan: Phase 4 & Phase 5 Enterprise Completion

## Audit Findings & Roadmap Summary
The codebase exploration by 3 parallel Explorers revealed clear gaps in Phase 4, Phase 5, and Test Coverage.

### Phase 4 Gaps
1. `Users` table (`lib/database/tables/users.dart`) omitted from `@DriftDatabase` tables in `lib/database/app_database.dart` and `table_registry.dart`.
2. `UserRepository` connects directly to Supabase bypassing local Drift DB, violating offline-first source of truth.
3. 9 domain tables lack `@TableIndex` annotations on foreign keys, status fields, dates, and `deletedAt`.
4. `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository` missing `getById`, `watchById`, and filtered streams (`watchBySubject`, `watchByCategory`, `watchByDateRange`).
5. Missing domain exception hierarchy/mapping and transaction boundaries for multi-row/cascade operations.

### Phase 5 Gaps
1. `SyncQueueItems` missing `targetTable` column.
2. Domain repositories do not enqueue write mutations into `SyncQueueRepository`.
3. `SyncService._processItem()` is an empty stub.
4. `SyncService` not registered in Riverpod and not listening to `ConnectivityService` reconnect events.

### Test Coverage Gaps
1. 5 of 11 repositories (`Assignments`, `User`, `Semester`, `Subject`, `Timetable`) have 0% test coverage.
2. `SyncService` (backoff, retry, offline skipping) and `AppDatabase` schema migrations have 0% test coverage.
3. Lack `mocktail` package in `pubspec.yaml` for testing network and service mocks.

---

## Execution Milestones

### Milestone 1: Phase 4 Drift Database & 9 Repositories Enterprise Completion
- **Worker 1**:
  - Register `Users` table in `@DriftDatabase` and `table_registry.dart`.
  - Add `@TableIndex` annotations across all 9 domain tables (`Semesters`, `Subjects`, `Timetable`, `Attendance`, `Assignments`, `InternalMarks`, `CalendarEvents`, `Resources`, `UserSettings`, `Users`).
  - Refactor `UserRepository` to write to local Drift DB first (offline source of truth).
  - Implement missing CRUD and stream methods in `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`.
  - Add domain exception mapping and transaction boundaries for cascade operations.
- **Reviewer 1**: Review correctness, Drift index syntax, offline-first compliance, stream methods, and transactions.

### Milestone 2: Phase 5 Supabase Sync Engine, Queue Manager & Auth Integration
- **Worker 2**:
  - Add `targetTable` column to `SyncQueueItems` Drift table and update `SyncQueueRepository.enqueue()`.
  - Inject `SyncQueueRepository` into all domain repositories and enqueue mutations (`insert`, `update`, `delete`).
  - Complete `SyncService._processItem()` to push local Drift rows to Supabase based on `targetTable` & `recordId`.
  - Wire up `SyncService` in Riverpod (`app_providers.dart`) and subscribe to `ConnectivityService.onStatusChange` for automatic queue flushing on network reconnect.
  - Implement exponential backoff, retry handling (max 5 retries), error recording, and Auth token refresh stream binding in `AuthStateNotifier`.
- **Reviewer 2**: Review sync queue state transitions, backoff math, connectivity listener, and RLS / Auth session persistence.

### Milestone 3: Full Test Suite Verification, Stress Testing & Forensic Audit
- **Worker 3**:
  - Add `mocktail` to `pubspec.yaml` `dev_dependencies` if needed.
  - Add unit tests for all 9 repositories in `test/unit/database/` (covering CRUD, stream filtering, soft deletion, and error handling).
  - Add unit tests for `SyncService` in `test/unit/services/sync_service_test.dart` (covering queue processing, exponential backoff, network drops, max retries).
  - Add database schema/migration tests in `test/unit/database/database_migration_test.dart`.
  - Run `flutter test` and achieve 100% pass rate across all tests.
- **Challenger**: Run empirical verification and edge case stress tests (network drop simulation, invalid payloads, duplicate record upserts).
- **Forensic Auditor**: Run static and execution integrity audit to guarantee zero facade / hardcoded test results.
