# Progress Log

Last visited: 2026-07-24T00:14:10Z

- Registered `Users` table in `app_database.dart` and `table_registry.dart`.
- Added all 10 table `@TableIndex` annotations in `lib/database/tables/`.
- Created domain exception hierarchy in `lib/core/errors/exceptions.dart`.
- Refactored `UserRepository` for local SQLite table storage with optional Supabase fallback.
- Completed all 9 repositories (`SemesterRepository`, `SubjectRepository`, `AttendanceRepository`, `TimetableRepository`, `AssignmentRepository`, `CalendarRepository`, `ResourcesRepository`, `InternalMarksRepository`, `UserRepository`) with complete CRUD, reactive stream watching, soft-delete filtering, single-transaction cascade soft deletes, and domain exception mapping.
- Regenerated Drift code via `dart run build_runner build --delete-conflicting-outputs`.
- Fixed analyzer warnings (`flutter analyze` returned 0 issues).
- Verified test suite (`flutter test` returned 35/35 passing tests).
