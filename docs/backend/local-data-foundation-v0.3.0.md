# Local Data Foundation (v0.3.0)

> Status: Architecture Design  
> Version: 0.3.0-draft  
> Date: 2026-06-29  
> Author: Kimi K2.6  

---

## Table of Contents

1. [Architecture Review](#1-archware-review)
2. [Current Repository Audit](#2-current-repository-audit)
3. [Current Database Audit](#3-current-database-audit)
4. [Current Sync Audit](#4-current-sync-audit)
5. [Problems Found](#5-problems-found)
6. [Proposed Architecture](#6-proposed-architecture)
7. [Folder Structure](#7-folder-structure)
8. [Repository Contracts](#8-repository-contracts)
9. [Sync Engine Design](#9-sync-engine-design)
10. [Conflict Resolution Strategy](#10-conflict-resolution-strategy)
11. [Connectivity Strategy](#11-connectivity-strategy)
12. [Database Responsibilities](#12-database-responsibilities)
13. [Cloud Responsibilities](#13-cloud-responsibilities)
14. [Development Roadmap](#14-development-roadmap-for-v030)

---

## 1. Architecture Review

### Current Architecture (v0.2.0)

| Layer | Technology | Status |
|-------|------------|--------|
| **Frontend** | Flutter, Material 3 | ✅ Complete |
| **State Management** | Riverpod (Notifier + sealed classes) | ✅ Complete |
| **Authentication** | Supabase Auth + native Google Sign-In | ✅ Complete |
| **Local Database** | Drift (SQLite) — `AppDatabase` | ⚠️ Empty (0 tables) |
| **Backend** | Supabase (PostgreSQL) | ✅ Complete (8 tables, RLS, triggers) |
| **Sync Engine** | Background sync via `UserRepository` | ⚠️ Partial (user profile only) |
| **Connectivity** | `connectivity_plus` + `internet_connection_checker_plus` | ✅ Ready |
| **Repositories** | `UserRepository` only | ⚠️ Only 1 of-effectively 8 domains |

### Design Philosophy (from existing docs)

1. **Offline-first**: SQLite is the source of truth. Every operation writes locally first.
2. **Local-first**: The UI reads from Drift, never directly from Supabase.
3. **Cloud for sync**: Supabase exists only for synchronization and backup.
4. **Invisible sync**: The user never waits for cloud operations.
5. **Feature-first**: Each feature owns its models, repository, service, and UI.

### What v0.3.0 Must Achieve

v0.3.0 is the **infrastructure layer**. It must provide:

- A complete Drift schema matching the Supabase schema (8 tables)
- A sync engine that handles all 8 domains automatically
- Repository contracts for all 7 future feature modules
- A connectivity-aware background sync manager
- Conflict resolution for simultaneous edits
- A foundation that requires **zero architectural changes** when adding new features

---

## 2. Current Repository Audit

### Existing Repositories (1 of 8)

#### `UserRepository` (`lib/features/authentication/repositories/user_repository.dart`)

| Aspect | Current State |
|--------|---------------|
| **Pattern** | Direct Supabase upsert, no local DB involvement |
| **Input** | `AppUser` (domain model, not a Drift entity) |
| **Output** | None (`Future<void>`) |
| **Error Handling** | Catches all exceptions, non-blocking (correct for offline-first) |
| **Sync Direction** | Upload only (no download) |
| **Sync Status Tracking** | None |
| **Queue** | None |

**Observation**: `UserRepository` currently bypasses Drift entirely. It writes directly to Supabase. This is acceptable for the `users` table (which is effectively read-only from the app's perspective—data comes from Supabase Auth), but it establishes the wrong pattern for data tables.

### Missing Repositories (7 of 8)

| Domain | Status | Tables |
|--------|--------|--------|
| **Semesters** | ❌ Not implemented | `semesters` |
| **Subjects** | ❌ Not implemented | `subjects` |
| **Timetable** | ❌ Not implemented | `timetable` |
| **Attendance** | ❌ Not implemented | `attendance` |
| **Assignments** | ❌ Not implemented | `assignments` |
| **Internal Marks** | ❌ Not implemented | `internal_marks` |
| **Settings** | ❌ Not implemented | `user_settings` |

---

## 3. Current Database Audit

### Drift (Local SQLite)

**File**: `lib/database/app_database.dart`

```dart
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  // schemaVersion: 1
  // onCreate: creates all tables
  // onUpgrade: placeholder
}
```

| Metric | Value |
|--------|-------|
| **Tables defined** | 0 |
| **Tables needed** | 8 |
| **DAOs** | 0 |
| **Migrations** | Placeholder only |
| **Generated file** | `app_database.g.dart` (empty) |

### Supabase (PostgreSQL)

**Migration**: `supabase/migrations/00001_mvp_foundation.sql`

| Table | Status | Columns | Notes |
|-------|--------|---------|-------|
| `users` | ✅ Created | 5 | PK = text (Supabase Auth UID) |
| `semesters` | ✅ Created | 8 | UUID PK, soft delete, RLS |
| `subjects` | ✅ Created | 8 | UUID PK, soft delete, RLS |
| `timetable` | ✅ Created | 9 | UUID PK, soft delete, RLS |
| `attendance` | ✅ Created | 10 | UUID PK, soft delete, RLS, unique constraint |
| `assignments` | ✅ Created | 10 | UUID PK, soft delete, RLS |
| `internal_marks` | ✅ Created | 9 | UUID PK, soft delete, RLS |
| `user_settings` | ✅ Created | 7 | UUID PK, 1:1 with users, RLS |

**Triggers**: Auto-update `updated_at` on every table.

**RLS**: 32 policies (SELECT/INSERT/UPDATE/DELETE × 8 tables).

**Indexes**: Strategic (user_id, semester_id, subject_id, date, status).

### Gap Analysis

The Supabase schema is **complete and production-ready**. The Drift schema is **empty**. This is the critical gap that v0.3.0 must close.

---

## 4. Current Sync Audit

### Documented Sync Architecture

`docs/backend/sync-engine.md` specifies:

```
User Action → SQLite → UI Update → Mark Pending Sync → Check Internet → Upload to Supabase → Mark Synced
```

**Sync Queue (documented)**:
- Record ID
- Table Name
- Operation (Insert / Update / Delete)
- Timestamp
- Sync Status

**Sync Status (documented)**:
- Pending
- Syncing
- Synced
- Failed

**Conflict Resolution (documented)**: Latest Updated Timestamp Wins.

**Retry Strategy (documented)**: Automatic, never discard, never interrupt user.

### Actually Implemented Sync

| Component | Status | Details |
|-----------|--------|---------|
| **Sync Queue Table** | ❌ Not implemented | No `sync_queue` table in Drift or Supabase |
| **Sync Status Column** | ❌ Not implemented | No `sync_status` on any table |
| **Sync Manager** | ❌ Not implemented | No background sync service |
| **Operation Tracking** | ❌ Not implemented | No record of pending operations |
| **Retry Logic** | ❌ Not implemented | No exponential backoff |
| **Conflict Resolution** | ❌ Not implemented | No timestamp comparison |
| **Batch Sync** | ❌ Not implemented | No batching of operations |

The **only sync that exists** is `UserRepository.upsertUser()`, which:
1. Is called directly from `AuthStateNotifier`
2. Writes directly to Supabase (not via Drift)
3. Has no queue, no status tracking, no retry
4. Catches exceptions silently (correct for offline-first, but not a general solution)

---

## 5. Problems Found

### Critical (Must Fix in v0.3.0)

1. **No Local Schema**: Drift has 0 tables. Every feature is blocked.
2. **No Sync Engine**: The sync architecture is documented but unimplemented.
3. **UserRepository Bypasses Drift**: Establishes a dangerous pattern for other features.
4. **No Sync Queue**: Changes are not tracked for background synchronization.
5. **No Sync Status**: Cannot distinguish between local-only and synced data.

### Important (Should Fix in v0.3.0)

6. **No DAOs**: All database access is direct, leading to duplication.
7. **No Type Converters**: Time, date, and JSON fields will require conversion.
8. **No Repository Contracts**: Features cannot agree on interfaces.
9. **ConnectivityService is Passive**: Listens but does not trigger actions.
10. **No Migrations Strategy**: Adding tables incrementally will require careful migration.

### Observations (Acknowledge)

11. **Supabase Schema is Complete**: The cloud side is ready. v0.3.0 only needs the local side.
12. **Auth is Complete**: No auth work needed.
13. **Dependencies are Ready**: `drift`, `connectivity_plus`, ` Riverpod` all installed.

---

## 6. Proposed Architecture

### 6.1 Core Principles

1. **Drift is the sole source of truth for application data.**
2. **Supabase is a replica.** The app must be able to reconstruct Supabase state from Drift state alone.
3. **All writes go through repositories.** No widget touches Drift or Supabase directly.
4. **Sync is automatic and invisible.** Users don't think about it.
5. **Conflict resolution is simple but extensible.** Start with "last write wins."
6. **Features are decoupled from sync mechanics.** Adding a new feature requires only a repository, a table, and a sync adapter.

### 6.2 Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                │
│  (Stateless/Consumer Widgets)                                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │ watch/listen
┌───────────────────────────▼─────────────────────────────────────┐
│                      State Layer (Riverpod)                     │
│  (Notifiers / AsyncNotifiers reading from repositories)         │
└───────────────────────────┬─────────────────────────────────────┘
                            │ use
┌───────────────────────────▼─────────────────────────────────────┐
│                    Repository Layer                             │
│  (Per-feature repositories with CRUD + query methods)          │
└───────────────────────────┬─────────────────────────────────────┘
                            │ read/write
┌───────────────────────────▼─────────────────────────────────────┐
│                    DAO Layer (Drift)                             │
│  (Table definitions, queries, type converters, migrations)      │
└───────────────────────────┬─────────────────────────────────────┘
                            │ persist
┌───────────────────────────▼─────────────────────────────────────┐
│                   Drift (SQLite)                                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │ semesters│ │ subjects │ │ timetable│ │attendance│ ...        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                         │
│  │assignments││int. marks│ │ settings │  + sync_queue         │
│  └──────────┘ └──────────┘ └──────────┘                         │
└───────────────────────────┬─────────────────────────────────────┘
                            │ schedule / dequeue
┌───────────────────────────▼─────────────────────────────────────┐
│                  Sync Engine (Background)                       │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐     │
│  │Queue → Batch   │  │ Conflict Res.  │  │ Retry + Backoff│     │
│  └────────────────┘  └────────────────┘  └────────────────┘     │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTPS / REST
┌───────────────────────────▼─────────────────────────────────────┐
│                    Supabase (PostgreSQL)                        │
│  (RLS-protected, auto-updated_at, triggers)                    │
└─────────────────────────────────────────────────────────────────┘
```

### 6.3 Architectural Decision: Sync Queue in Drift

**Decision**: The sync queue will be a Drift table, not a separate in-memory queue.

**Rationale**:
- Queue survives app restarts (critical for offline-first).
- No separate persistence mechanism needed.
- Can be queried for pending items count, displayed in UI.
- Batching and retry logic is simpler with a persistent queue.

**Trade-off**: Slightly more complex table design and slightly larger database.

### 6.4 Architectural Decision: Dual-Model Pattern

**Decision**: Each feature maintains two models:
1. **Entity** (`*_entity.dart`): Drift row class. Tightly coupled to the local DB schema.
2. **Domain Model** (`*_model.dart`): Pure Dart class. Used by UI and business logic.

**Rationale**:
- UI should not depend on Drift classes (decoupling).
- Repository converts between entity and model.
- Entities can change without breaking the UI.
- Facilitates testing with mock models.

### 6.5 Architectural Decision: Sync Adapter per Table

**Decision**: Each table has a corresponding `SyncAdapter` that knows how to:
- Convert a local entity to a Supabase row.
- Convert a Supabase row to a local entity.
- Identify the primary key for conflict resolution.

**Rationale**:
- Decouples sync engine from table-specific knowledge.
- Makes adding a new table a matter of adding its sync adapter.
- Keeps the sync engine generic and testable.

---

## 7. Folder Structure

### Proposed `lib/` Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   └── env_config.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── data/
│   │   ├── converters/
│   │   │   ├── date_time_converter.dart
│   │   │   ├── uuid_converter.dart
│   │   │   └── json_converter.dart
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── app_database.g.dart
│   │   │   ├── tables/
│   │   │   │   ├── semesters.dart
│   │   │   │   ├── subjects.dart
│   │   │   │   ├── timetable.dart
│   │   │   │   ├── attendance.dart
│   │   │   │   ├── assignments.dart
│   │   │   │   ├── internal_marks.dart
│   │   │   │   ├── user_settings.dart
│   │   │   │   └── sync_queue.dart
│   │   │   └── daos/
│   │   │       ├── semesters_dao.dart
│   │   │       ├── subjects_dao.dart
│   │   │       ├── timetable_dao.dart
│   │   │       ├── attendance_dao.dart
│   │   │       ├── assignments_dao.dart
│   │   │       ├── internal_marks_dao.dart
│   │   │       ├── user_settings_dao.dart
│   │   │       └── sync_queue_dao.dart
│   │   └── sync/
│   │       ├── sync_engine.dart
│   │       ├── sync_manager.dart
│   │       ├── sync_queue_processor.dart
│   │       └── sync_adapters/
│   │           ├── semesters_adapter.dart
│   │           ├── subjects_adapter.dart
│   │           ├── timetable_adapter.dart
│   │           ├── attendance_adapter.dart
│   │           ├── assignments_adapter.dart
│   │           ├── internal_marks_adapter.dart
│   │           └── user_settings_adapter.dart
│   └── extensions/
│       └── context_extensions.dart
├── features/
│   ├── attendance/
│   │   ├── models/
│   │   │   └── attendance_model.dart
│   │   ├── repositories/
│   │   │   └── attendance_repository.dart
│   │   └── ...
│   ├── assignments/
│   │   ├── models/
│   │   │   └── assignment_model.dart
│   │   ├── repositories/
│   │   │   └── assignments_repository.dart
│   │   └── ...
│   ├── authentication/
│   │   ├── models/
│   │   │   ├── app_user.dart
│   │   │   └── auth_state.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   ├── repositories/
│   │   │   └── user_repository.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── splash_screen.dart
│   │   └── services/
│   │       └── auth_service.dart
│   ├── dashboard/
│   ├── internal_marks/
│   ├── profile/
│   ├── semester/
│   │   ├── models/
│   │   │   └── semester_model.dart
│   │   ├── repositories/
│   │   │   └── semesters_repository.dart
│   │   └── ...
│   ├── settings/
│   │   ├── models/
│   │   │   └── settings_model.dart
│   │   ├── repositories/
│   │   │   └── settings_repository.dart
│   │   └── ...
│   ├── subjects/
│   │   ├── models/
│   │   │   └── subject_model.dart
│   │   ├── repositories/
│   │   │   └── subjects_repository.dart
│   │   └── ...
│   └── timetable/
│       ├── models/
│       │   └── timetable_model.dart
│       ├── repositories/
│       │   └── timetable_repository.dart
│       └── ...
├── providers/
│   └── app_providers.dart
├── routing/
│   ├── app_router.dart
│   └── scaffold_with_nav_bar.dart
├── services/
│   ├── connectivity_service.dart
│   └── supabase_service.dart
├── shared/
│   └── widgets/
│       └── placeholder_screen.dart
├── theme/
│   └── ...
└── utilities/
    └── logger.dart
```

### Key Changes from Current Structure

| Current | Proposed | Rationale |
|---------|----------|-----------|
| `lib/database/app_database.dart` | `lib/core/data/database/` | Consistent with `core` holding shared infrastructure |
| `lib/database/` only | `lib/core/data/` with subfolders | Organized by concern: tables, daos, sync |
| No `converters/` folder | `lib/core/data/converters/` | Centralized type converters for reuse |
| No `sync/` folder | `lib/core/data/sync/` | Dedicated sync engine location |
| No `models/` per feature (mostly) | Every feature gets `models/` | Separation between entity and domain model |
| `lib/features/semester/.gitkeep` | `lib/features/semester/` with real files | Semester will be first non-auth feature |

---

## 8. Repository Contracts

### 8.1 Base Repository Contract

Every repository must implement the following interface (or extend an abstract class):

```dart
/// Base contract for all feature repositories.
///
/// [T] is the domain model type.
/// [ID] is the primary key type (typically String for UUIDs).
abstract class BaseRepository<T, ID> {
  /// Returns a stream of all items, ordered by relevance.
  Stream<List<T>> watchAll();

  /// Returns a single item by ID, or null if not found.
  Future<T?> getById(ID id);

  /// Inserts a new item locally and queues it for sync.
  Future<ID> create(T item);

  /// Updates an item locally and queues it for sync.
  Future<void> update(T item);

  /// Soft-deletes an item locally and queues the delete for sync.
  Future<void> delete(ID id);

  /// Permanently removes soft-deleted items older than [maxAge].
  /// Called by the sync engine after successful remote delete.
  Future<void> purge({Duration maxAge});
}
```

### 8.2 Attendance Repository Contract

```dart
abstract class AttendanceRepository implements BaseRepository<Attendance, String> {
  /// Watch attendance for a specific subject.
  Stream<List<Attendance>> watchBySubject(String subjectId);

  /// Watch attendance for a specific date range.
  Stream<List<Attendance>> watchByDateRange(DateTime start, DateTime end);

  /// Watch today's attendance.
  Stream<List<Attendance>> watchToday();

  /// Mark attendance for a subject on a given date.
  Future<void> markAttendance(String subjectId, DateTime date, AttendanceStatus status,
      {String? notes, String? proofImagePath});

  /// Get attendance statistics for a subject.
  Future<AttendanceStats> getStats(String subjectId);
}
```

### 8.3 Timetable Repository Contract

```dart
abstract class TimetableRepository implements BaseRepository<TimetableEntry, String> {
  /// Watch timetable for a specific day of week.
  Stream<List<TimetableEntry>> watchByDay(int dayOfWeek);

  /// Watch the full weekly timetable.
  Stream<List<TimetableEntry>> watchWeekly();

  /// Get the timetable for today.
  Stream<List<TimetableEntry>> watchToday();
}
```

### 8.4 Assignments Repository Contract

```dart
abstract class AssignmentsRepository implements BaseRepository<Assignment, String> {
  /// Watch pending assignments.
  Stream<List<Assignment>> watchPending();

  /// Watch assignments by due date.
  Stream<List<Assignment>> watchByDueDate(DateTime date);

  /// Watch overdue assignments.
  Stream<List<Assignment>> watchOverdue();

  /// Mark an assignment as completed.
  Future<void> markCompleted(String id);
}
```

### 8.5 Semester Management Repository Contract

```dart
abstract class SemestersRepository implements BaseRepository<Semester, String> {
  /// Watch the currently active semester.
  Stream<Semester?> watchCurrent();

  /// Set a semester as current.
  Future<void> setCurrent(String id);

  /// Archive a semester.
  Future<void> archive(String id);

  /// Duplicate a semester (including subjects and timetable).
  Future<String> duplicate(String id, {String? newName});
}
```

### 8.6 Internal Marks Repository Contract

```dart
abstract class InternalMarksRepository implements BaseRepository<InternalMark, String> {
  /// Watch marks for a specific subject.
  Stream<List<InternalMark>> watchBySubject(String subjectId);

  /// Calculate average for a subject.
  Future<double> calculateAverage(String subjectId);
}
```

### 8.7 Settings Repository Contract

```dart
abstract class SettingsRepository implements BaseRepository<AppSettings, String> {
  /// Watch settings for the current user.
  Stream<AppSettings?> watchCurrent();

  /// Update a single preference.
  Future<void> updatePreference(String key, dynamic value);
}
```

### 8.8 Dashboard Data Provider Contract

The dashboard is read-only. It combines data from multiple repositories.

```dart
abstract class DashboardRepository {
  /// Watch the complete dashboard state.
  Stream<DashboardState> watchDashboard();
}
```

---

## 9. Sync Engine Design

### 9.1 Sync Queue Table

```dart
class SyncQueueItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'INSERT', 'UPDATE', 'DELETE'
  TextColumn get payload => text()(); // JSON-encoded row data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  TextColumn get error => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
```

### 9.2 Sync Flow

```
┌─────────────────┐
│  Local Change   │  (INSERT / UPDATE / DELETE via Repository)
└────────┬────────┘
         │
┌────────▼────────┐
│  Write to Drift │
└────────┬────────┘
         │
┌────────▼────────┐
│  Riverpod emits │  (UI updates immediately)
└────────┬────────┘
         │
┌────────▼────────┐
│ Insert into     │
│   sync_queue    │  (only for tracked tables)
└────────┬────────┘
         │
┌────────▼────────┐
│ SyncManager picks │  (on connectivity + periodic)
│ up pending items  │
└────────┬────────┘
         │
┌────────▼────────┐
│ Batch operations│  (group by table + operation)
└────────┬────────┘
         │
┌────────▼────────┐
│ Upload to       │  (Supabase REST API with RLS)
│   Supabase      │
└────────┬────────┘
         │
┌────────────────────────────────────────┐
│               Conflict?                  │
│  (compare local updated_at vs remote)   │
└────────┬────────┬────────────────┬──────┘
         │        │                │
        No     Yes, local       Yes, remote
         │        │                │
         │   ┌────▼────┐     ┌───▼────┐
         │   │ Overwrite│     │ Download│
         │   │  remote  │     │  remote │
         │   └────┬────┘     └───┬─────┘
         │        │                │
┌────────▼────────▼────────────────▼──────┐
│ Mark queue items as synced / remove   │
└────────────────────────────────────────┘
```

### 9.3 Sync Manager

```dart
class SyncManager {
  /// Starts the background sync process.
  /// Called on app launch and when connectivity is restored.
  Future<void> sync({bool force = false});

  /// Triggers an immediate sync attempt.
  /// Used by user-activated "Sync Now" button.
  Future<SyncResult> syncNow();

  /// Watches the current sync status.
  Stream<SyncStatus> get onStatusChange;

  /// Returns the number of pending sync items.
  Future<int> getPendingCount();
}
```

### 9.4 Background Sync Trigger Points

| Trigger | Condition | Action |
|---------|-----------|--------|
| **App Launch** | Always | Check queue, attempt sync if connected |
| **Connectivity Restored** | `ConnectivityService.onConnectivityChanged` → online | Trigger sync immediately |
| **Periodic** | Every 15 minutes while app is open | Attempt sync if pending items > 0 |
| **After Local Change** | Only if currently online | Attempt immediate sync |
| **Manual** | User presses "Sync Now" in settings | Full sync (upload + download) |

### 9.5 Batch Size and Concurrency

- **Batch size**: 50 records per request (configurable).
- **Concurrency**:_parallel per table but sequential across tables to maintain referential integrity.
- **Order of operations within a batch**: INSERTS first, then UPDATES, then DELETES.

### 9.6 Queued Operation Lifecycle

```
Created (local change) → Pending (in queue) → Syncing (attempting upload)
                              ↓
                           Failed (error, retry_count++) → Retry after delay
                              ↓ (max retries reached)
                           Permanently Failed → Logged, not lost
                              ↓
                           Synced → Removed from queue
```

---

## 10. Conflict Resolution Strategy

### 10.1 Decision: Last Updated Timestamp Wins

**Chosen Strategy**: Compare `updated_at` field between local and remote.

```
if local.updated_at > remote.updated_at:
    local wins → overwrite remote
else if local.updated_at < remote.updated_at:
    remote wins → overwrite local
else:
    same timestamp → no action needed
```

**Justification for MVP**:
- **Simple to implement**: Single timestamp comparison.
- **Predictable**: Users understand "last edit wins."
- **No user interruption**: No merge dialogs.
- **Per-record**: Conflicts are resolved at the row level, not the table level.

**Known Limitations**:
- Clock skew on devices can cause unexpected behavior.
- Two users editing the same field simultaneously will lose one user's data.
- No field-level merge (if Edits A and B on the same row, only one survives).

### 10.2 Future Extensibility

The sync adapter interface will预留 a `resolveConflict` method:

```dart
abstract class SyncAdapter<T> {
  SupabaseRow toSupabase(T entity);
  T fromSupabase(Map<String, dynamic> row);

  /// Called by the sync engine when a conflict is detected.
  /// Returns the resolved entity and the winning side.
  ConflictResult<T> resolveConflict(T local, T remote);
}
```

In v0.3.0, implementations will delegate to a default strategy. Future versions can provide:
- **Field-level merge**: Keep both changes if they touch different fields.
- **User intervention**: Show a dialog for conflicting fields.
- **Append-only lists**: Treat some lists as append-only.

---

## 11. Connectivity Strategy

### 11.1 Current State

`ConnectivityService` provides:
- `onConnectivityChanged` (Stream)
- `hasInternetAccess` (Future<bool>)
- `onStatusChange` (Stream<InternetStatus>)

### 11.2 Proposed Enhancement

Extend `ConnectivityService` to be **proactive**:

```dart
class ConnectivityService {
  /// Current connectivity state.
  Future<bool> get isOnline;

  /// Stream of online/offline transitions.
  Stream<bool> get onOnlineChange;

  /// Debounced online status to avoid rapid toggling.
  /// Emits true only after 3 seconds of continuous connectivity.
  Stream<bool> get onStableOnline;
}
```

**Debounce rationale**: Network flickers (WiFi dropout for 1 second) should not trigger sync. Only stable connectivity should.

### 11.3 Connectivity-Aware Sync Manager

```dart
class SyncManager {
  void _listenToConnectivity() {
    _connectivityService.onStableOnline.listen((isOnline) {
      if (isOnline) {
        _syncQueueProcessor.processPending();
      }
    });
  }
}
```

### 11.4 Offline UX

- All local operations continue normally.
- When an operation that would trigger sync is performed:
  - If offline: silently queue.
  - If online: attempt sync, but don't block UI on failure.
- Display a subtle indicator: "Changes saved locally. Will sync automatically."
- Do NOT show a full-screen offline banner (preemptive, user-hostile).

---

## 12. Database Responsibilities

### 12.1 What Belongs in Drift

| Data | Owner | Synced? | Rationale |
|------|-------|---------|-----------|
| `users` | Supabase Auth (read-only for app) | ⬇️ Download only | Auth source of truth |
| `semesters` | Drift | ⬆️⬇️ Two-way | User-created data |
| `subjects` | Drift | ⬆️⬇️ Two-way | User-created data |
| `timetable` | Drift | ⬆️⬇️ Two-way | User-created data |
| `attendance` | Drift | ⬆️⬇️ Two-way | User-generated data |
| `assignments` | Drift | ⬆️⬇️ Two-way | User-generated data |
| `internal_marks` | Drift | ⬆️⬇️ Two-way | User-generated data |
| `user_settings` | Drift | ⬆️⬇️ Two-way | User preferences |
| `sync_queue` | Drift | ❌ No | Internal tracking |

### 12.2 Local-Only Data

Some data should never be synced:
- **Sync queue metadata** (`sync_queue` table)
- **Device-specific settings** (e.g., notification sounds selected on this device)
- **Temporary state** (drafts not yet confirmed)

### 12.3 Sync Flags per Table

Each table will include a `sync_status` column:

```dart
enum SyncStatus { pending, synced, failed }
```

| Table | `sync_status` | Purpose |
|-------|---------------|---------|
| `semesters` | Yes | Track if this semester has been uploaded |
| `subjects` | Yes | Track if this subject has been uploaded |
| `timetable` | Yes | Track if this slot has been uploaded |
| `attendance` | Yes | Track if this record has been uploaded |
| `assignments` | Yes | Track if this assignment has been uploaded |
| `internal_marks` | Yes | Track if this mark has been uploaded |
| `user_settings` | Yes | Track if settings have been uploaded |

---

## 13. Cloud Responsibilities

### 13.1 Supabase as Replica

| Responsibility | Details |
|----------------|---------|
| **Data Storage** | Mirror of Drift data, with same soft-delete semantics |
| **Authentication** | Supabase Auth owns identity, not user data |
| **RLS** | Every table protected, user can only see their own data |
| **Triggers** | `updated_at` auto-updated on every write |
| **History** | Not a historical archive; current state only |
| **Conflict** | Supabase never resolves conflicts; the app does |

### 13.2 Supabase Tables (Summary)

All tables match Drift schema 1:1, with identical columns.

| Table | Key Column | Unique / Constraints |
|-------|------------|---------------------|
| `users` | `id` (text, PK) | — |
| `semesters` | `id` (uuid, PK) | — |
| `subjects` | `id` (uuid, PK) | — |
| `timetable` | `id` (uuid, PK) | `end_time > start_time` |
| `attendance` | `id` (uuid, PK) | `(user_id, subject_id, date, lecture_type)` |
| `assignments` | `id` (uuid, PK) | — |
| `internal_marks` | `id` (uuid, PK) | `marks_obtained <= max_marks` |
| `user_settings` | `id` (uuid, PK) | `user_id` UNIQUE |

### 13.3 Supabase Read vs Write

| Operation | Drift Action | Supabase Action |
|-----------|-------------|-----------------|
| **Create** (app online) | INSERT + set `sync_status=pending` | Upsert via Sync Engine |
| **Create** (app offline) | INSERT + set `sync_status=pending` | Queued, uploaded later |
| **Read** (all cases) | `SELECT` from Drift | Never blocks on Supabase read |
| **Update** | UPDATE + set `sync_status=pending` | Upsert via Sync Engine |
| **Delete** | Soft DELETE (`deleted_at=now()`) | Propagated via Sync Engine |
| **Download** (new device) | `INSERT or REPLACE` all received rows | `SELECT` all rows for user |

---

## 14. Development Roadmap for v0.3.0

### Phase 1: Foundation (Prerequisite for all features)
- [ ] Define all 8 Drift tables + sync_queue table
- [ ] Create type converters (DateTime, UUID, JSON)
- [ ] Set up Drift DAOs for all tables
- [ ] Write database migration from version 1 (empty) to version 2 (full schema)
- [ ] Validate with `dart run build_runner build`
- [ ] Verify generated code (`app_database.g.dart`)

### Phase 2: Sync Engine
- [ ] Implement `SyncQueueItem` table and DAO
- [ ] Implement `SyncManager` with scheduling
- [ ] Implement `SyncQueueProcessor` with batching
- [ ] Implement retry logic with exponential backoff
- [ ] Implement sync adapters for all 7 data tables
- [ ] Integrate `ConnectivityService` with debouncing
- [ ] Write unit tests for sync engine components

### Phase 3: Connectivity
- [ ] Add debounced connectivity stream
- [ ] Implement automatic queue flush on connection restore
- [ ] Test offline → online transitions
- [ ] Add sync status indicator (subtle)

### Phase 4: Repository Contracts (Stubs)
- [ ] Create `BaseRepository` abstract class
- [ ] Create `SemestersRepository` stub implementing `BaseRepository`
- [ ] Create `SubjectsRepository` stub implementing `BaseRepository`
- [ ] Create `TimetableRepository` stub implementing `BaseRepository`
- [ ] Create `AttendanceRepository` stub implementing `BaseRepository`
- [ ] Create `AssignmentsRepository` stub implementing `BaseRepository`
- [ ] Create `InternalMarksRepository` stub implementing `BaseRepository`
- [ ] Create `SettingsRepository` stub implementing `BaseRepository`
- [ ] Verify that repository interfaces are consistent

### Phase 5: Settings & Semesters (first real features)
- [ ] Implement `SemestersRepository` fully (with CRUD + sync)
- [ ] Implement `SettingsRepository` fully (with CRUD + sync)
- [ ] Wire repositories to Riverpod providers
- [ ] Test end-to-end: create semester → sync to Supabase → install on new device → data available

### Phase 6: Validation
- [ ] `dart format .`
- [ ] `flutter analyze`
- [ ] `flutter build apk --debug`
- [ ] Run all unit tests
- [ ] Verify offline operation (airplane mode)
- [ ] Verify sync (standard and flaky networks)

---

## Appendix A: Type Converter Specification

### DateTime Converter
```dart
class DateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime fromSql(int micros) => DateTime.fromMillisecondsSinceEpoch(micros);
  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}
```

### UUID Converter
```dart
class UuidConverter extends TypeConverter<String, String> {
  /// Validates that the stored value is a valid UUID.
  @override
  String fromSql(String fromDb) => fromDb;
  @override
  String toSql(String value) {
    // Validate UUID v4 format.
    return value;
  }
}
```

### JSON Converter (for settings/preferences)
```dart
class JsonConverter extends TypeConverter<Map<String, dynamic>, String> {
  @override
  Map<String, dynamic> fromSql(String jsonString) =>
      jsonDecode(jsonString) as Map<String, dynamic>;
  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}
```

---

## Appendix B: Migration Plan

### From schemaVersion 1 (empty) to 2 (full)

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      // Version 1 → 2: Create all tables for v0.3.0
      // Since v1 had no tables, createAll in onCreate handles this.
      // If upgrading from a populated v1, we would need explicit CREATEs.
    }
  },
);
```

**Important**: Because v1 had no user data, onCreate alone is sufficient. If there were v1 tables, we would need explicit `onUpgrade` logic to add new tables without losing data.

---

## Appendix C: Performance Considerations

### Battery

- **Debounced sync**: Only sync after 3 seconds of stable connectivity (avoids rapid toggles).
- **Batched uploads**: 50 records per request (not individual per-record requests).
- **Periodic sync**: Every 15 minutes, not continuous.
- **Background task**: Use `WorkManager` for true background sync when app is closed (future enhancement).

### Memory

- **Stream-based UI**: Use `StreamBuilder` or `StreamProvider` to avoid keeping entire tables in memory.
- **Pagination**: Use `LIMIT` and `OFFSET` for large lists (future).
- **Image handling**: Attendance proof images are stored locally first, uploaded to Supabase Storage only when synced.

### Database

- **Indexes**: Drift does not need the same indexes as PostgreSQL (single-user DB), but add them for query performance.
- **Vacuum**: Drift auto-vacuum is enabled by default.
- **Soft delete purge**: Periodically remove soft-deleted records older than 30 days to keep DB small.

### Synchronization Efficiency

- **Only sync changes**: Track `sync_status` to avoid re-syncing unchanged records.
- **Server timestamp**: Use Supabase's `now()` for `updated_at` on the server to ensure single source of truth for conflict timestamps.
- **Delta sync**: Future optimization to only fetch records where `updated_at` > `last_sync_at`.

---

*End of Local Data Foundation (v0.3.0) Architecture Design.*
