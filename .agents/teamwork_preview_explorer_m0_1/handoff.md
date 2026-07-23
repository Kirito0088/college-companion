# Phase 4 Investigation Handoff Report

## 1. Observation

Direct code observations from `c:\Projects\college_companion_ui`:

1. **Unregistered Drift Table `Users`**:
   - `lib/database/tables/users.dart` lines 12-13: `@DataClassName('UserEntity') class Users extends Table`.
   - `lib/database/app_database.dart` lines 27-40:
     ```dart
     @DriftDatabase(
       tables: [
         Semesters,
         Subjects,
         Timetable,
         Attendance,
         Assignments,
         InternalMarks,
         UserSettings,
         SyncQueueItems,
         CalendarEvents,
         Resources,
       ],
     )
     ```
     `Users` is completely omitted from the `@DriftDatabase` tables list and from `lib/database/tables/table_registry.dart` line 17.

2. **`UserRepository` Drift Disconnect**:
   - `lib/features/authentication/repositories/user_repository.dart` line 24 & 30-38:
     ```dart
     final SupabaseClient _client;

     Future<void> upsertUser(AppUser user) async {
       try {
         await _client.from(_tableName).upsert({ ... });
       ...
     ```
     `UserRepository` does not inject or reference `AppDatabase` or Drift tables, interacting solely with Supabase.

3. **Performance Indices Deficit**:
   - `lib/database/tables/sync_queue.dart` lines 20-26: contains 4 `@TableIndex` annotations (`idx_sync_queue_record_id`, `idx_sync_queue_operation`, `idx_sync_queue_status`, `idx_sync_queue_pending`).
   - `lib/database/tables/semesters.dart`, `attendance.dart`, `assignments.dart`, `timetable.dart`, `internal_marks.dart`, `calendar_events.dart`, `resources.dart`, `user_settings.dart`, `users.dart`: Contain zero `@TableIndex` annotations or custom indices for foreign key fields (`userId`, `semesterId`, `subjectId`), status fields (`isCurrent`, `status`), or dates (`date`, `dueDate`, `startDate`).

4. **Incomplete Repository APIs**:
   - `lib/features/calendar/repositories/calendar_repository.dart` (40 lines total): Contains `watchAll`, `create`, `update`, `delete`. Missing `getById`, `watchById`, `watchByDateRange`.
   - `lib/features/resources/repositories/resources_repository.dart` (40 lines total): Contains `watchAll`, `create`, `update`, `delete`. Missing `getById`, `watchById`, `watchBySubject`, `watchByCategory`.
   - `lib/features/internal_marks/repositories/internal_marks_repository.dart` (40 lines total): Contains `watchAll`, `create`, `update`, `delete`. Missing `getById`, `watchById`, `watchBySubject`.

5. **Lack of Domain Exception Mapping**:
   - In all 9 repositories (`SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, `UserRepository`), database calls do not use try-catch to map SQLite/Drift exceptions into domain exceptions.

6. **Transaction Boundaries**:
   - Only `SemesterRepository.setCurrent` (`lib/features/semester/repositories/semesters_repository.dart` line 94) invokes `_database.transaction(...)`. All other repositories lack transaction boundaries.

---

## 2. Logic Chain

1. **Observation 1 & 2** show that `Users` is defined in `tables/users.dart` but omitted from `app_database.dart`, while `UserRepository` bypasses local Drift storage to communicate directly with Supabase.
   - **Reasoning**: This breaks the offline-first SQLite source-of-truth requirement (`docs/backend/database.md`). Without local SQLite storage, user profile data cannot be queried or read offline.
2. **Observation 3** shows that 9 out of 10 tables lack index annotations on `userId`, `semesterId`, `subjectId`, `date`, `dueDate`, and `status`.
   - **Reasoning**: Every repository stream query filters by `userId` and `deletedAt IS NULL`. Without indices on these columns, SQLite performs full table scans on every query, causing severe UI lag as database rows accumulate.
3. **Observation 4** shows that `CalendarRepository`, `ResourcesRepository`, and `InternalMarksRepository` only expose `watchAll` and basic write operations.
   - **Reasoning**: Feature screens requiring single-item lookup (`getById`/`watchById`) or filtered lists (`watchBySubject`, `watchByCategory`, `watchByDateRange`) will be forced to perform client-side filtering on `watchAll` streams or fail to retrieve individual records.
4. **Observation 5** shows that database exceptions bubble raw ORM/SQLite errors to callers.
   - **Reasoning**: UI providers and services cannot handle structured failure cases (e.g. `RecordNotFoundException`, `DuplicateRecordException`) gracefully.
5. **Observation 6** shows that cascading operations lack transaction boundaries.
   - **Reasoning**: Concurrent writes or multi-step operations (e.g. cascading soft-deletes or bulk timetable updates) risk leaving the database in an inconsistent partial state if an error occurs mid-operation.

---

## 3. Caveats

- Investigation was strictly read-only; no code modifications were applied to application files.
- Did not run full live database migration scripts against a physical SQLite file, but verified schema definitions statically.

---

## 4. Conclusion

The Phase 4 database and repository implementation provides solid foundational CRUD and stream operations for core entities (`Semesters`, `Subjects`, `Attendance`, `Timetable`, `Assignments`), but exhibits critical architectural deficits:
1. `Users` table is unregistered in Drift, and `UserRepository` breaks offline-first architecture by bypassing Drift.
2. Business tables lack performance indices on foreign keys and filter columns (`userId`, `semesterId`, `subjectId`, `date`, `status`).
3. Three repositories (`CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`) have incomplete query APIs.
4. Domain exception mapping is absent across all repositories, and transactions are missing for cascading mutations.

---

## 5. Verification Method

To independently verify these findings:
1. Inspect `lib/database/app_database.dart` lines 27-40 to confirm missing `Users` table registration.
2. Inspect `lib/features/authentication/repositories/user_repository.dart` to confirm absence of `AppDatabase` injection.
3. Inspect `lib/database/tables/*.dart` to confirm that only `sync_queue.dart` includes `@TableIndex` annotations.
4. Inspect `lib/features/calendar/repositories/calendar_repository.dart`, `resources_repository.dart`, and `internal_marks_repository.dart` to verify missing `getById`, `watchById`, and filter methods.
5. Run static analysis command `flutter analyze` or inspect repository exception handling code to confirm lack of try-catch blocks or domain error types.
