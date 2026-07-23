## 2026-07-24T00:02:48Z
Execute Phase 4 Drift Database & 9 Repositories Enterprise Completion in c:\Projects\college_companion_ui.
Working directory: c:\Projects\college_companion_ui\.agents\teamwork_preview_worker_m1_1

DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Tasks:
1. Register `Users` Table:
   - Add `Users` table class from `lib/database/tables/users.dart` to `@DriftDatabase(tables: [..., Users])` in `lib/database/app_database.dart` and `lib/database/tables/table_registry.dart`.
2. Add `@TableIndex` Annotations:
   - In `lib/database/tables/`:
     - `Semesters`: `@TableIndex(name: 'idx_semesters_user_deleted', columns: {#userId, #deletedAt})`, `@TableIndex(name: 'idx_semesters_user_current', columns: {#userId, #isCurrent})`
     - `Subjects`: `@TableIndex(name: 'idx_subjects_user_deleted', columns: {#userId, #deletedAt})`
     - `Timetable`: `@TableIndex(name: 'idx_timetable_user_day', columns: {#userId, #dayOfWeek, #deletedAt})`, `@TableIndex(name: 'idx_timetable_subject', columns: {#subjectId})`
     - `Attendance`: `@TableIndex(name: 'idx_attendance_user_date', columns: {#userId, #date, #deletedAt})`, `@TableIndex(name: 'idx_attendance_subject', columns: {#subjectId})`
     - `Assignments`: `@TableIndex(name: 'idx_assignments_user_status', columns: {#userId, #status, #deletedAt})`, `@TableIndex(name: 'idx_assignments_subject', columns: {#subjectId})`, `@TableIndex(name: 'idx_assignments_due_date', columns: {#dueDate})`
     - `InternalMarks`: `@TableIndex(name: 'idx_internal_marks_subject', columns: {#subjectId, #deletedAt})`
     - `CalendarEvents`: `@TableIndex(name: 'idx_calendar_events_user_date', columns: {#userId, #startDate, #deletedAt})`
     - `Resources`: `@TableIndex(name: 'idx_resources_subject', columns: {#subjectId, #deletedAt})`
     - `UserSettings`: `@TableIndex(name: 'idx_user_settings_user', columns: {#userId})`
     - `Users`: `@TableIndex(name: 'idx_users_id', columns: {#id})`
3. Refactor `UserRepository` for Offline-First SQLite Storage:
   - In `lib/features/authentication/repositories/user_repository.dart`, import and inject `AppDatabase`.
   - Store and retrieve user profile updates in local SQLite `Users` Drift table first (`upsertUser`, `getUserById`, `watchUser`).
4. Complete All 9 Repositories:
   - Ensure all 9 repositories (`SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, `UserRepository`) have complete:
     - CRUD operations (`create`/`insert`, `getById`, `update`, `delete` soft delete)
     - Reactive stream watching methods (`watchAll`, `watchById`, and domain streams like `watchBySubject`, `watchByCategory`, `watchByDateRange`, `watchUpcoming`)
     - Soft-deletion filtering (`where((t) => t.deletedAt.isNull())` / `is_deleted = false`)
     - Transaction boundaries (`transaction(() async { ... })`) for multi-row operations and cascade soft deletes (e.g. soft deleting a subject soft deletes related timetable, attendance, assignments, internal marks inside a single transaction).
     - Domain exception mapping (wrap SQLite/Drift calls with try-catch and throw domain exceptions from `lib/core/errors/exceptions.dart`).
5. Build & Code Generation:
   - Run build runner to regenerate `app_database.g.dart`: `dart run build_runner build --delete-conflicting-outputs`
   - Run `flutter analyze` or `flutter test` to verify zero build errors.
6. Write a comprehensive handoff report `c:\Projects\college_companion_ui\.agents\teamwork_preview_worker_m1_1\handoff.md` and send a message back with your summary and test/build command outputs.
