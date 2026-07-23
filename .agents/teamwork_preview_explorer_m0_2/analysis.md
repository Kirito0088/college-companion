# Phase 5 Implementation Audit Report: Offline Sync & Supabase Integration

**Target Project:** `c:\Projects\college_companion_ui`  
**Date:** 2026-07-23  
**Auditor:** Teamwork Explorer (`teamwork_preview_explorer_m0_2`)  

---

## Executive Summary

Phase 5 introduces the backend foundation, local sync queue, background synchronization, Supabase Authentication, and Row Level Security (RLS) policies.

This audit evaluates the codebase against the specified requirements and reference specifications (`docs/backend/sync-engine.md`, `docs/backend/security.md`, `docs/backend/database.md`).

**Key Takeaways:**
1. **Supabase Auth & RLS Policies (Complete & Production-Ready):** Supabase Auth integration via native Google Sign-In (`google_sign_in`) and RLS migrations (`00001_mvp_foundation.sql`, `00002_update_rls_for_supabase_auth.sql`) are well-architected, fully enforcing user isolation via `(select auth.jwt()->>'sub')`.
2. **Drift `sync_queue` Schema (Defined with Critical Bug):** Drift table is defined in `lib/database/tables/sync_queue.dart` and `AppDatabase`, but has a critical schema bug: **missing column for the target business table name**.
3. **Background Sync Worker & Queue Manager (Incomplete / Stub):** `SyncService` in `lib/services/sync_service.dart` contains stub execution methods, is not wired up to Riverpod providers, does not listen to connectivity restoration events, and local business repositories do not enqueue write mutations into `SyncQueueRepository`.

---

## Detailed Audit Findings

### 1. Drift `sync_queue` Table & Repository

#### File Paths
- Table Definition: `lib/database/tables/sync_queue.dart`
- Database Registration: `lib/database/app_database.dart`
- Repository Implementation: `lib/core/repositories/sync_queue_repository.dart`
- Unit Tests: `test/unit/database/sync_queue_repository_test.dart`

#### Observations & Evaluation
- **Table Schema (`SyncQueueItems`):**
  - Defines primary key `id` (auto-increment integer), `recordId` (text UUID), `operation` (text: 'INSERT'/'UPDATE'/'DELETE'), `retryCount` (integer, default 0), `createdAt` (ISO 8601 text), `lastAttempt` (nullable ISO text), `error` (nullable text), and `isSynced` (boolean, default false).
  - Includes database indexes: `idx_sync_queue_record_id`, `idx_sync_queue_operation`, `idx_sync_queue_status`, `idx_sync_queue_pending`.
- **Critical Schema Defect:**
  - In `lib/database/tables/sync_queue.dart` lines 31–33:
    ```dart
    /// The name of the business table (e.g., 'semesters', 'subjects').
    @override
    String get tableName => 'sync_queue';
    ```
  - `@override String get tableName` is Drift's getter to override the SQLite table name (`sync_queue`). **No table column was defined for storing the target business table name** (e.g., `'assignments'`, `'attendance'`). Consequently, queued items record `recordId` but lose track of which business table the record belongs to.
- **Dead Code Enum:**
  - `enum SyncOperationStatus { pending, syncing, failed }` is declared on line 11 of `sync_queue.dart`, but the table schema uses `isSynced` (boolean) instead.
- **Supabase Parity:**
  - `sync_queue` is strictly local to SQLite/Drift and is NOT created in Supabase SQL migrations, matching `docs/backend/sync-engine.md` design principles.

---

### 2. Background Sync Worker & Queue Manager

#### File Paths
- Sync Service: `lib/services/sync_service.dart`
- Connectivity Service: `lib/services/connectivity_service.dart`
- Providers: `lib/providers/app_providers.dart`

#### Observations & Evaluation
- **Queue Mutation Processing on Connectivity Restore:**
  - `ConnectivityService` wraps `connectivity_plus` and `internet_connection_checker_plus`.
  - **MISSING:** No background listener or worker subscribes to `ConnectivityService.onConnectivityChanged` / `onStatusChange` to trigger `SyncService.syncPendingMutations()`.
  - **MISSING:** `SyncService` is not registered in `app_providers.dart` or initialized in `main.dart`.
  - **MISSING:** Business repositories (`AttendanceRepository`, `AssignmentsRepository`, etc.) do not invoke `SyncQueueRepository.enqueue()` when performing CUD operations.
- **Exponential Backoff & Retry Logic:**
  - `SyncService` implements exponential backoff:
    - Max retries constant: `_maxRetries = 5`.
    - Checks `item.retryCount >= _maxRetries` and skips items exceeding max attempts.
    - Increments retry count and stores error via `SyncQueueRepository.recordFailure()`.
    - Delay calculation: `final delayMs = pow(2, item.retryCount).toInt() * 500;` (delay sequence: 500ms, 1000ms, 2000ms, 4000ms, 8000ms).
  - **Limitation:** Backoff delay is executed inline (`await Future.delayed(...)`) inside the batch loop, blocking processing of remaining pending items.
- **Deterministic Conflict Resolution (Offline Source of Truth):**
  - **STUB:** `SyncService._processItem(dynamic item)` (lines 95–100) is an empty stub with commented pseudocode (`// client.from(item.tableName).upsert(...)`).
  - **MISSING:** Does not read actual row payload from Drift business tables before attempting remote upsert.
  - **MISSING:** Downstream sync (pulling remote updates from Supabase into SQLite and resolving timestamp conflicts via "latest timestamp wins") is completely unimplemented.
- **Mutation States Handling:**
  - Tracks `pending` (`isSynced == false`), `failed` (`retryCount > 0` + `error`), and `completed` (`isSynced == true`).
  - Synced items are purged at end of batch via `purgeSyncedItems()`.
  - `processing` state is managed via an in-memory boolean `_isSyncing` flag on `SyncService` rather than item-level DB state.

---

### 3. Supabase Auth, Session Persistence, Token Refresh & RLS Policies

#### File Paths
- Auth Service: `lib/features/authentication/services/auth_service.dart`
- Auth Provider: `lib/features/authentication/providers/auth_provider.dart`
- User Repository: `lib/features/authentication/repositories/user_repository.dart`
- Supabase Service: `lib/services/supabase_service.dart`
- SQL Migrations:
  - `supabase/migrations/00001_mvp_foundation.sql`
  - `supabase/migrations/00002_update_rls_for_supabase_auth.sql`

#### Observations & Evaluation
- **Supabase Auth Setup:**
  - `SupabaseService.initialize()` initializes Supabase client with `EnvConfig.supabaseUrl` and `EnvConfig.supabasePublishableKey`.
  - `AuthService.signInWithGoogle()` uses `google_sign_in` package to obtain Google `idToken` and `accessToken`, exchanging them with Supabase via `_supabaseClient.auth.signInWithIdToken()`.
- **Session Persistence & Token Refresh:**
  - Session tokens are persisted natively by `supabase_flutter` via secure storage.
  - `AuthStateNotifier._restoreSession()` checks `authService.getCurrentUser()` (`_supabaseClient.auth.currentUser`) on app startup to restore session seamlessly.
  - **Minor Gap:** `AuthStateNotifier` does not subscribe continuously to `_supabaseClient.auth.onAuthStateChange` stream to handle background token refresh errors or session revocation reactively.
- **User Profile Sync:**
  - `UserRepository.upsertUser(AppUser user)` syncs user details (`id`, `name`, `email`, `profile_photo`, `updated_at`) to the Supabase `users` table via non-blocking async execution.
- **Row Level Security (RLS) Policies:**
  - Migration `00002_update_rls_for_supabase_auth.sql` updates RLS policies across all 8 tables (`users`, `semesters`, `subjects`, `timetable`, `attendance`, `assignments`, `internal_marks`, `user_settings`).
  - Uses `(select auth.jwt()->>'sub')` to match text `user_id` columns (and `id` on `users` table).
  - Enforces 32 total policies covering `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.
  - The `(select ...)` subquery wrapper optimizes performance by evaluating the JWT claim once per query rather than per row.

---

## Gap Analysis & Missing Features Matrix

| Feature Component | Status | Implementation File | Missing / Incomplete Elements |
| :--- | :--- | :--- | :--- |
| **`sync_queue` Table Schema** | Partial | `lib/database/tables/sync_queue.dart` | Missing column for target business table name (`target_table_name`). `tableName` getter overrides Drift table name instead of adding column. `SyncOperationStatus` enum unused. |
| **Local Write Enqueuing** | Missing | Business Repositories | Repositories (`AttendanceRepository`, `AssignmentsRepository`, etc.) do not enqueue operations into `SyncQueueRepository`. |
| **Network Restoration Sync Trigger** | Missing | `lib/services/sync_service.dart` | No stream listener on `ConnectivityService.onStatusChange` to trigger sync on reconnection. |
| **Background Sync Execution** | Partial / Stub | `lib/services/sync_service.dart` | `_processItem()` is an empty stub. `SyncService` is not registered in Riverpod or called anywhere. |
| **Downstream Sync Engine** | Missing | `lib/services/sync_service.dart` | Cloud-to-local sync (pulling Supabase changes to Drift) & timestamp conflict resolution missing. |
| **Exponential Backoff Logic** | Complete | `lib/services/sync_service.dart` | Functional backoff math (`2^retryCount * 500ms`), but blocks queue batch loop inline. |
| **Supabase Auth & OAuth** | Complete | `lib/features/authentication/services/auth_service.dart` | Native Google Sign-In token exchange implemented cleanly. |
| **Session Persistence** | Complete | `lib/features/authentication/providers/auth_provider.dart` | Restores existing session on app initialization via `_restoreSession()`. |
| **Token Refresh Reactive Handling** | Partial | `lib/features/authentication/providers/auth_provider.dart` | `authStateChanges` stream available but not actively bound to Riverpod state updates. |
| **Row Level Security (RLS)** | Complete | `supabase/migrations/00002_update_rls_for_supabase_auth.sql` | All 8 tables protected with `(select auth.jwt()->>'sub')` policies across all operations. |

---

## Recommendations for Phase 5 Completion

1. **Fix Drift `SyncQueueItems` Table Schema:**
   - Add `TextColumn get targetTable => text()();` (or `targetTableName`) to `SyncQueueItems`.
   - Update `SyncQueueRepository.enqueue()` to accept `required String targetTable`.
2. **Wire Up Business Repositories to Enqueue Mutations:**
   - Inject `SyncQueueRepository` into business repositories and call `enqueue()` on `insert`, `update`, `delete`.
3. **Complete `SyncService` Implementation:**
   - Implement `_processItem` to fetch actual entity data from Drift tables based on `targetTable` and `recordId`, then perform `Supabase.client.from(targetTable).upsert(...)`.
   - Register `SyncService` in Riverpod (`syncServiceProvider`).
   - Listen to `ConnectivityService.onStatusChange` to trigger `syncPendingMutations()` when connectivity becomes `connected`.
4. **Implement Reactive Auth Listener:**
   - Bind `authService.authStateChanges` stream inside `AuthStateNotifier` to update state on token refresh or logout events.
