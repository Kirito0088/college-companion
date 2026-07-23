## 2026-07-24T00:16:18Z

Execute Phase 5 Supabase Sync Engine & Cloud Persistence Implementation in c:\Projects\college_companion_ui.
Working directory: c:\Projects\college_companion_ui\.agents\teamwork_preview_worker_m2_1

DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Tasks:
1. Fix `SyncQueueItems` Drift Table Schema & `SyncQueueRepository`:
   - In `lib/database/tables/sync_queue.dart`, add `TextColumn get targetTable => text()();` column.
   - Update `lib/core/repositories/sync_queue_repository.dart` to accept `required String targetTable` in `enqueue()` and store it in SQLite.
2. Inject Mutation Enqueuing in Business Repositories:
   - Update business repositories (`SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, `UserRepository`, `UserSettingsRepository`) to accept `SyncQueueRepository` (optional/injected) and call `syncQueueRepository.enqueue(...)` when local write operations (`create`/`insert`, `update`, `delete`) complete.
3. Complete `SyncService` Background Worker:
   - In `lib/services/sync_service.dart`:
     - Implement `_processItem(SyncQueueItem item)` to read row payload from local Drift DB based on `targetTable` and `recordId`.
     - Perform `_supabaseClient.from(item.targetTable).upsert(payload)` for INSERT/UPDATE operations, and `.delete().eq('id', item.recordId)` for DELETE operations.
     - Implement exponential backoff (`pow(2, item.retryCount) * 500ms`), max retries check (5 retries), error recording via `recordFailure()`, and purging synced items via `purgeSyncedItems()`.
     - Implement deterministic conflict resolution (local database as offline source of truth).
     - Subscribe to `ConnectivityService.onStatusChange` (or `onConnectivityChanged`) so that when network connectivity is restored, `syncPendingMutations()` is automatically triggered.
     - Register `SyncService` in Riverpod (`lib/providers/app_providers.dart`) and ensure initialization.
4. Validate Auth Session Persistence & Token Refresh Stream:
   - In `lib/features/authentication/providers/auth_provider.dart`, bind `authService.authStateChanges` stream to handle session restoration, token refresh, and auth state changes reactively.
5. Build & Code Generation:
   - Run `dart run build_runner build --delete-conflicting-outputs`
   - Run `flutter analyze` and `flutter test` to ensure zero compilation or lint errors.
6. Write a comprehensive handoff report at `c:\Projects\college_companion_ui\.agents\teamwork_preview_worker_m2_1\handoff.md` and send a message back with your summary and test/build command outputs.
