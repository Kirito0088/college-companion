# Handoff Report — Phase 5 Audit

## 1. Observation

Direct code and file observations:

- **Drift `sync_queue` Table:**
  - File: `lib/database/tables/sync_queue.dart:27-58`
  - `SyncQueueItems` defines `id`, `recordId`, `operation`, `retryCount`, `createdAt`, `lastAttempt`, `error`, `isSynced`.
  - Line 33: `@override String get tableName => 'sync_queue';` overrides Drift table metadata. No column exists for storing the target business table name (e.g. `'attendance'`, `'assignments'`).
  - Line 11: `enum SyncOperationStatus { pending, syncing, failed }` is defined but unused by the table schema.
- **SyncQueueRepository:**
  - File: `lib/core/repositories/sync_queue_repository.dart:17-66`
  - Defines `enqueue()`, `getPendingItems()`, `markSynced()`, `recordFailure()`, `purgeSyncedItems()`.
  - `enqueue()` is not called by any business repository in `lib/features/*/repositories/`.
- **Sync Worker / SyncService:**
  - File: `lib/services/sync_service.dart:15-101`
  - `_processItem()` (lines 95–100) is an un-implemented stub containing commented pseudocode.
  - Implements exponential backoff at lines 83–84: `pow(2, item.retryCount).toInt() * 500`.
  - Is not registered in `lib/providers/app_providers.dart` nor called by any connectivity listener or background job.
- **Supabase Auth & Session:**
  - File: `lib/services/supabase_service.dart:24-30` initializes Supabase client via `Supabase.initialize()`.
  - File: `lib/features/authentication/services/auth_service.dart:47-90` implements native Google Sign-In and token exchange via `_supabaseClient.auth.signInWithIdToken()`.
  - File: `lib/features/authentication/providers/auth_provider.dart:48-74` restores session via `authService.getCurrentUser()`.
  - File: `lib/features/authentication/repositories/user_repository.dart:30-49` upserts user records to Supabase `users` table.
- **Row Level Security (RLS) Policies:**
  - File: `supabase/migrations/00001_mvp_foundation.sql` & `supabase/migrations/00002_update_rls_for_supabase_auth.sql`
  - Enabled RLS on all 8 tables (`users`, `semesters`, `subjects`, `timetable`, `attendance`, `assignments`, `internal_marks`, `user_settings`).
  - Migration 00002 applies 32 policies using `(select auth.jwt()->>'sub')` to match text user ID columns strictly.

---

## 2. Logic Chain

1. **Table Schema Defect:** `SyncQueueItems` defines `recordId` and `operation`, but uses `@override String get tableName => 'sync_queue'` (the Drift table name getter) instead of defining a database column like `TextColumn get targetTable => text()()`. Therefore, when `SyncQueueRepository.enqueue()` is called, the target business table is unknown.
2. **Disconnected Sync Flow:** Even if items were enqueued, `SyncService` is never triggered automatically on connectivity restoration because no listener binds `ConnectivityService.onStatusChange` to `SyncService.syncPendingMutations()`. Furthermore, `SyncService._processItem()` does not pull local record data from Drift or execute `Supabase.client.from(targetTable).upsert()`.
3. **Write Enqueuing Gap:** Local business repositories execute Drift queries directly without enqueuing operations to `SyncQueueRepository`. Therefore, local CUD operations currently create no queue entries.
4. **Auth & Security Readiness:** In contrast to the sync queue, Supabase Auth and RLS policies are fully implemented. Session restoration works on startup, and RLS policies properly secure user data per-JWT `sub` claim across all CRUD operations.

---

## 3. Caveats

- Investigation was performed via static read-only code and migration analysis without running an active Supabase backend instance or Flutter emulator.
- Native Google Sign-In (`google_sign_in`) requires valid `googleWebClientId` configuration in runtime `.env` file to exchange tokens with Supabase in live environments.

---

## 4. Conclusion

Phase 5 implementation is **partially complete**:
- **Authentication & Security (100% Complete):** Supabase Auth, Google OAuth token exchange, session persistence, and 32 RLS policies are production-ready.
- **Sync Queue Schema (50% Complete):** Drift table and repository exist, but lack a column for the target business table name.
- **Background Sync Engine (20% Complete):** `SyncService` contains stub logic for payload processing, lacks connectivity auto-triggering, lacks business repository mutation enqueuing, and lacks downstream cloud-to-local sync.

---

## 5. Verification Method

To verify these findings independently:
1. View `lib/database/tables/sync_queue.dart` lines 27–58 to verify absence of `targetTable` text column.
2. Search repository for calls to `enqueue`: `grep_search(Query: "enqueue", SearchPath: "lib")` to verify business repositories do not queue mutations.
3. Inspect `lib/services/sync_service.dart` lines 95–100 to verify `_processItem()` is a stub.
4. Inspect `supabase/migrations/00002_update_rls_for_supabase_auth.sql` lines 86–172 to verify 32 RLS policies using `(select auth.jwt()->>'sub')`.
5. Run existing unit tests: `flutter test test/unit/database/sync_queue_repository_test.dart`.
