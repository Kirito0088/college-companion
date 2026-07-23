# Phase 4 Implementation Audit: Drift Database & Repository Layer

**Target Directory**: `c:\Projects\college_companion_ui`  
**Audit Date**: 2026-07-23  
**Status**: Completed  

---

## 1. Executive Summary

This document presents a comprehensive audit of the Phase 4 database and repository implementation for `college_companion_ui`. The audit evaluated:
1. **Drift Database Definitions**: Table schema, `@DriftDatabase` registration, foreign key integrity, and table indices.
2. **Repository Architecture**: Implementation of all 9 core domain repositories (`SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, and `UserRepository`).
3. **Core Repository Criteria**: CRUD completeness, reactive stream watching, soft-deletion filtering (`deletedAt IS NULL`), transaction boundaries (`transaction()`), and domain exception mapping/error handling.
4. **Indexing & Query Performance**: Assessment of SQLite indices on foreign key columns, lookups, and stream filter predicates.

### Key Findings Summary
* **Unregistered Drift Table**: The `Users` table defined in `lib/database/tables/users.dart` is missing from the `@DriftDatabase` `tables` list in `lib/database/app_database.dart` and `lib/database/tables/table_registry.dart`.
* **Disconnected UserRepository**: `UserRepository` (`lib/features/authentication/repositories/user_repository.dart`) interacts directly with Supabase via `SupabaseClient` and does not use local Drift database storage, violating the offline-first SQLite source-of-truth principle (`docs/backend/database.md`).
* **Severe Index Deficit**: Only `SyncQueueItems` defines table indices (`@TableIndex`). All business entity tables (`Semesters`, `Timetable`, `Attendance`, `Assignments`, `InternalMarks`, `CalendarEvents`, `Resources`, `UserSettings`, `Users`) have **zero performance indices** on heavily queried foreign keys (`userId`, `semesterId`, `subjectId`), status fields (`isCurrent`, `status`), or dates (`date`, `dueDate`, `startDate`).
* **Incomplete Repository APIs**: `CalendarRepository`, `ResourcesRepository`, and `InternalMarksRepository` lack essential CRUD methods (`getById`, `watchById`) and domain-specific filtered streams (`watchBySubject`, `watchByCategory`, `watchByDateRange`).
* **Lack of Domain Exception Mapping**: Across all 9 repositories, database errors are not mapped to domain failures/exceptions (`DomainException`, `RepositoryException`). Operations either throw raw Drift/SQLite exceptions or return raw `null` without error context.
* **Missing Transaction Boundaries**: Only `SemesterRepository.setCurrent` uses `db.transaction()`. Cascading soft deletions (e.g., soft deleting a subject and its related timetable entries, attendance records, and assignments) lack transactional guarantees.

---

## 2. Drift Database Schema & Definitions Audit

### 2.1 Database Definition File
* **File Location**: `lib/database/app_database.dart`
* **Registered Tables**: 10 tables
  - `Semesters` (`lib/database/tables/semesters.dart`)
  - `Subjects` (`lib/database/tables/subjects.dart`)
  - `Timetable` (`lib/database/tables/timetable.dart`)
  - `Attendance` (`lib/database/tables/attendance.dart`)
  - `Assignments` (`lib/database/tables/assignments.dart`)
  - `InternalMarks` (`lib/database/tables/internal_marks.dart`)
  - `UserSettings` (`lib/database/tables/user_settings.dart`)
  - `SyncQueueItems` (`lib/database/tables/sync_queue.dart`)
  - `CalendarEvents` (`lib/database/tables/calendar_events.dart`)
  - `Resources` (`lib/database/tables/resources.dart`)

### 2.2 Table Definitions & Schema Issues

| Table Class | File Location | Registered in AppDatabase? | Primary Key | Soft Delete Column | Custom Unique Keys |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **Semesters** | `lib/database/tables/semesters.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| **Subjects** | `lib/database/tables/subjects.dart` | Yes | `id` | `deletedAt` (text nullable) | `{userId, semesterId, name}` |
| **Timetable** | `lib/database/tables/timetable.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| **Attendance** | `lib/database/tables/attendance.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| **Assignments** | `lib/database/tables/assignments.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| `InternalMarks` | `lib/database/tables/internal_marks.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| `UserSettings` | `lib/database/tables/user_settings.dart` | Yes | `id` | N/A (settings per user) | None |
| `SyncQueueItems` | `lib/database/tables/sync_queue.dart` | Yes | `id` (autoincrement) | N/A (queue table) | None |
| `CalendarEvents` | `lib/database/tables/calendar_events.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| `Resources` | `lib/database/tables/resources.dart` | Yes | `id` | `deletedAt` (text nullable) | None |
| **`Users`** | `lib/database/tables/users.dart` | ❌ **NO** | `id` | None | None |

#### Critical Findings in Schema:
1. **Unregistered `Users` Table**: `lib/database/tables/users.dart` defines `UserEntity` / `Users`, but `AppDatabase` `@DriftDatabase(tables: [...])` omits `Users`. Running migrations or database generation leaves the `users` table non-existent in the generated SQLite schema.
2. **Missing Drift Foreign Key Constraints**: No Drift table definitions utilize `.references(...)` (e.g., `subjectId.references(Subjects, #id)`). Foreign key fields (`userId`, `semesterId`, `subjectId`) are plain `TextColumn` types, placing 100% of relational integrity overhead onto the application code without SQLite database-level foreign key enforcement.

---

## 3. Database Performance & Indexing Audit

Per `docs/backend/database.md` (Section "Indexing"), the system spec mandates indexing `userId`, `semesterId`, `subjectId`, `date`, and `status`.

### Current Indexing Status Across Tables

| Table | Column(s) Filtered / Joined | Index Present in Code? | Recommendation |
| :--- | :--- | :---: | :--- |
| **SyncQueueItems** | `recordId`, `operation`, `isSynced`, `retryCount` | ✅ **YES** (4 `@TableIndex`) | Well-indexed. |
| **Semesters** | `userId`, `deletedAt`, `isCurrent` | ❌ **NO** | Add index on `(userId, deletedAt)` & `(userId, isCurrent)`. |
| **Subjects** | `userId`, `semesterId`, `deletedAt` | ⚠️ **PARTIAL** (via unique key) | Unique key `{userId, semesterId, name}` covers `(userId, semesterId)`, but need index on `(userId, deletedAt)`. |
| **Timetable** | `userId`, `subjectId`, `dayOfWeek`, `deletedAt` | ❌ **NO** | Add index on `(userId, deletedAt, dayOfWeek)` & `(subjectId)`. |
| **Attendance** | `userId`, `subjectId`, `date`, `deletedAt` | ❌ **NO** | Add index on `(userId, deletedAt, date)` & `(subjectId, date)`. |
| **Assignments** | `userId`, `subjectId`, `status`, `dueDate`, `deletedAt` | ❌ **NO** | Add index on `(userId, status, deletedAt)` & `(subjectId)` & `(dueDate)`. |
| **InternalMarks** | `userId`, `subjectId`, `deletedAt` | ❌ **NO** | Add index on `(userId, deletedAt)` & `(subjectId)`. |
| **CalendarEvents** | `userId`, `startDate`, `endDate`, `deletedAt` | ❌ **NO** | Add index on `(userId, deletedAt)` & `(startDate)`. |
| **Resources** | `userId`, `subjectId`, `category`, `deletedAt` | ❌ **NO** | Add index on `(userId, deletedAt)` & `(subjectId)`. |
| **UserSettings** | `userId` | ❌ **NO** | Add unique index on `(userId)`. |
| **Users** | `id` | ❌ **NO** | Add index once registered. |

**Performance Impact**: Every reactive stream query (`watchAll`, `watchPending`, `watchByDateRange`, etc.) executes full table scans (`table scan`) in SQLite as data grows. Adding multi-column index definitions `@TableIndex` is critical before production release.

---

## 4. Audit of the 9 Repositories

### 4.1 Feature Audit Matrix

| Repository | Path | CRUD Operations | Stream Watching | Soft Delete Filter | Transactions (`transaction`) | Domain Exception Mapping |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **1. SemesterRepository** | `lib/features/semester/repositories/semesters_repository.dart` | ✅ Complete | ✅ `watchAll`, `watchById`, `watchCurrent` | ✅ `t.deletedAt.isNull()` | ✅ `setCurrent` | ❌ None |
| **2. SubjectRepository** | `lib/features/subjects/repositories/subjects_repository.dart` | ✅ Complete | ✅ `watchAll`, `watchBySemester`, `watchById` | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **3. AttendanceRepository** | `lib/features/attendance/repositories/attendance_repository.dart` | ✅ Complete | ✅ `watchAll`, `watchById`, `watchBySubject`, `watchOnDate`, `watchByDateRange` | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **4. TimetableRepository** | `lib/features/timetable/repositories/timetable_repository.dart` | ✅ Complete | ✅ `watchAll`, `watchByDay`, `watchBySubject`, `watchById` | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **5. AssignmentRepository** | `lib/features/assignments/repositories/assignments_repository.dart` | ✅ Complete | ✅ `watchAll`, `watchPending`, `watchCompleted`, `watchDueOn`, `watchUpcoming`, `watchById` | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **6. CalendarRepository** | `lib/features/calendar/repositories/calendar_repository.dart` | ❌ Missing `getById` | ⚠️ Only `watchAll` (Missing `watchById`, `watchByDateRange`) | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **7. ResourcesRepository** | `lib/features/resources/repositories/resources_repository.dart` | ❌ Missing `getById` | ⚠️ Only `watchAll` (Missing `watchById`, `watchBySubject`) | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **8. InternalMarksRepository** | `lib/features/internal_marks/repositories/internal_marks_repository.dart` | ❌ Missing `getById` | ⚠️ Only `watchAll` (Missing `watchById`, `watchBySubject`) | ✅ `t.deletedAt.isNull()` | ❌ None | ❌ None |
| **9. UserRepository** | `lib/features/authentication/repositories/user_repository.dart` | ❌ No local SQLite CRUD | ❌ No stream watching | N/A | ❌ None | ⚠️ Logs error; swallows exception |

---

### 4.2 In-Depth Repository Evaluation

#### 1. SemesterRepository (`lib/features/semester/repositories/semesters_repository.dart`)
* **Strengths**: Clean Drift query construction; includes `watchCurrent` and `setCurrent`. Employs transaction boundaries inside `setCurrent` to guarantee atomic unsetting of previous active semester and setting of new active semester.
* **Weaknesses**: Lacks try-catch blocks and error handling; returns raw Drift companion/entity types without domain wrapping.

#### 2. SubjectRepository (`lib/features/subjects/repositories/subjects_repository.dart`)
* **Strengths**: Provides `watchBySemester`, `watchById`, and standard CRUD methods with soft-deletion predicate `t.deletedAt.isNull()`.
* **Weaknesses**: No transactional support for cascade operations (e.g. deleting a subject does not transactionally soft-delete dependent timetable entries or attendance records). No domain exception mapping.

#### 3. AttendanceRepository (`lib/features/attendance/repositories/attendance_repository.dart`)
* **Strengths**: Comprehensive stream methods (`watchBySubject`, `watchOnDate`, `watchByDateRange`). Proper ISO 8601 string formatting for date key comparisons (`_dayKey`).
* **Weaknesses**: Lacks transactions for batch operations (e.g. marking whole day attendance). No error handling/exception mapping.

#### 4. TimetableRepository (`lib/features/timetable/repositories/timetable_repository.dart`)
* **Strengths**: Well-structured queries for `watchByDay` (0=Monday...6=Sunday) and `watchBySubject`. Proper sorting by `startTime`.
* **Weaknesses**: Missing transactional methods for replacing/updating bulk day schedules. No error handling.

#### 5. AssignmentRepository (`lib/features/assignments/repositories/assignments_repository.dart`)
* **Strengths**: Rich query capabilities (`watchPending`, `watchCompleted`, `watchDueOn`, `watchUpcoming`). Proper state update method `markCompleted`.
* **Weaknesses**: No transaction boundaries or exception handling.

#### 6. CalendarRepository (`lib/features/calendar/repositories/calendar_repository.dart`)
* **Deficiencies**: Extremely minimal implementation (40 lines).
  - Missing `getById(userId, id)`
  - Missing `watchById(userId, id)`
  - Missing `watchByDateRange(userId, start, end)` or `watchUpcoming(userId, end)`
  - No domain error handling or transaction boundaries.

#### 7. ResourcesRepository (`lib/features/resources/repositories/resources_repository.dart`)
* **Deficiencies**: Extremely minimal implementation (40 lines).
  - Missing `getById(userId, id)`
  - Missing `watchById(userId, id)`
  - Missing `watchBySubject(userId, subjectId)`
  - Missing `watchByCategory(userId, category)`
  - No domain error handling or transaction boundaries.

#### 8. InternalMarksRepository (`lib/features/internal_marks/repositories/internal_marks_repository.dart`)
* **Deficiencies**: Extremely minimal implementation (40 lines).
  - Missing `getById(userId, id)`
  - Missing `watchById(userId, id)`
  - Missing `watchBySubject(userId, subjectId)`
  - No domain error handling or transaction boundaries.

#### 9. UserRepository (`lib/features/authentication/repositories/user_repository.dart`)
* **Architectural Gap**:
  - `UserRepository` only communicates with `SupabaseClient` via `_client.from('users').upsert(...)`.
  - It **does not import or inject `AppDatabase`**, nor does it interact with local SQLite.
  - The local `Users` Drift table in `lib/database/tables/users.dart` is left unused and unregistered in `AppDatabase`.
  - Breaks the offline-first SQLite source-of-truth requirement. User profiles must be persisted locally in Drift and synced asynchronously via `SyncQueue`.

---

## 5. Architectural Recommendations & Action Plan

### Recommended Action Items

1. **Register `Users` Table in `AppDatabase`**:
   - Add `Users` to `@DriftDatabase(tables: [..., Users])` in `lib/database/app_database.dart`.
   - Include `Users()` in `lib/database/tables/table_registry.dart`.

2. **Refactor `UserRepository` for Offline-First Architecture**:
   - Inject `AppDatabase` into `UserRepository`.
   - Persist user profile updates to local SQLite first, then enqueue sync item or push to Supabase.
   - Implement `watchUser(userId)` and `getUserById(userId)` streaming/fetching methods.

3. **Add `@TableIndex` Annotations Across All Drift Tables**:
   - `Semesters`: `@TableIndex(name: 'idx_semesters_user_deleted', columns: {#userId, #deletedAt})`
   - `Subjects`: `@TableIndex(name: 'idx_subjects_user_deleted', columns: {#userId, #deletedAt})`
   - `Timetable`: `@TableIndex(name: 'idx_timetable_user_day', columns: {#userId, #dayOfWeek, #deletedAt})`, `@TableIndex(name: 'idx_timetable_subject', columns: {#subjectId})`
   - `Attendance`: `@TableIndex(name: 'idx_attendance_user_date', columns: {#userId, #date, #deletedAt})`, `@TableIndex(name: 'idx_attendance_subject', columns: {#subjectId})`
   - `Assignments`: `@TableIndex(name: 'idx_assignments_user_status', columns: {#userId, #status, #deletedAt})`, `@TableIndex(name: 'idx_assignments_subject', columns: {#subjectId})`, `@TableIndex(name: 'idx_assignments_due_date', columns: {#dueDate})`
   - `InternalMarks`: `@TableIndex(name: 'idx_internal_marks_subject', columns: {#subjectId, #deletedAt})`
   - `CalendarEvents`: `@TableIndex(name: 'idx_calendar_events_user_date', columns: {#userId, #startDate, #deletedAt})`
   - `Resources`: `@TableIndex(name: 'idx_resources_subject', columns: {#subjectId, #deletedAt})`

4. **Complete Missing Stream & Fetch APIs in Minimal Repositories**:
   - Expand `CalendarRepository` with `getById`, `watchById`, `watchByDateRange`.
   - Expand `ResourcesRepository` with `getById`, `watchById`, `watchBySubject`, `watchByCategory`.
   - Expand `InternalMarksRepository` with `getById`, `watchById`, `watchBySubject`.

5. **Establish Domain Exception Hierarchy & Mapping**:
   - Define custom domain exceptions (e.g., `DatabaseException`, `RecordNotFoundException`) in `lib/core/errors/exceptions.dart`.
   - Wrap repository mutations and queries with structured error handling to convert raw SQLite/Drift exceptions into predictable domain exceptions.

6. **Add Transaction Boundaries for Cascade Deletes**:
   - Add transactional cascade delete helpers (e.g., when deleting a Subject, soft-delete its related Timetable entries, Attendance records, Assignments, and Internal Marks within a single `_database.transaction(...)`).

---
