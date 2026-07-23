## 2026-07-24T00:40:52Z

OBJECTIVE:
1. Verify and expand unit test coverage across all 9 Drift Repositories (`Assignments`, `Attendance`, `Calendar`, `InternalMarks`, `Resources`, `Semesters`, `Subjects`, `SyncQueue`, `Timetable`, `User`, `UserSettings`), `SyncService`, database migrations (`database_migration_test.dart`), and edge cases (`edge_cases_test.dart`).
2. Run `flutter analyze` via `run_command` in `c:\Projects\college_companion_ui` and fix any static analysis errors or warnings.
3. Run `flutter test` via `run_command` in `c:\Projects\college_companion_ui` and ensure ALL tests pass cleanly with 100% pass rate.
4. If any tests fail or are missing, write/modify test files using your tools, re-run `flutter analyze` and `flutter test` until clean.
5. Mandatory Integrity Warning: DO NOT CHEAT. All implementations and tests must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or bypass real tests. A Forensic Auditor will independently verify your work.
6. When `flutter analyze` and `flutter test` both pass 100% cleanly, write `handoff.md` in `c:\Projects\college_companion_ui\.agents\teamwork_preview_worker_m3_3\` documenting:
   - Summary of test files verified/added
   - Exact `flutter analyze` output and status
   - Exact `flutter test` output and status (number of tests passed, 0 failed)
7. Send a message to parent orchestrator with the completion status and report path.
