## 2026-07-24T11:24:05Z
You are a teamwork_preview_worker agent assigned to implement Milestone 2 (Requirements R4, R9).
Your working directory is `c:\Projects\college_companion\.agents\worker_m2_1`. Create `.agents/worker_m2_1/progress.md` and `handoff.md`.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Strategy:
Read the investigation report at `c:\Projects\college_companion\.agents\explorer_m2_1\handoff.md` carefully.

Tasks:
1. R4 (Semester Feature):
   - Refactor `SemesterDetailsScreen` (`lib/features/semester/screens/semester_details_screen.dart`) to a `ConsumerStatefulWidget` accepting `semesterId` (via router query param or route extra).
   - Watch `SemesterRepository`, `SubjectRepository`, `TimetableRepository`, `CalendarRepository` to populate real semester details, subjects list, progress, dates, and overall semester status metrics (replacing 'This Week').
   - Add M3 dialogs/bottom sheets for:
     - Add Subject (calls `SubjectRepository.create`)
     - Add Timetable Slot per subject (calls `TimetableRepository.create`)
     - Edit Semester (dates/name, calls `SemesterRepository.update`)
     - Add Important Date (exams/deadlines, calls `CalendarRepository.create`)
   - Update `app_router.dart` and `semesters_list_screen.dart` to pass `semesterId`.
2. R9 (Attendance Feature Cleanup):
   - In `lib/features/attendance/screens/attendance_screen.dart` & widgets (`overall_gauge.dart`, `stats_row.dart`, `attendance_trend_card.dart`):
   - Strip all hardcoded fallback subject cards ('Operating Systems', 'DBMS', 'CN') and fake fallback percentages (85%, 82%, 148, 32, 180).
   - Display `EmptySubjects()` empty state when no subjects exist.
   - Zero-attendance subjects must display 0% with appropriate visual indicator.
   - Update overview insight text to compute metrics dynamically from real subject attendance data.
   - Wire quick action buttons ('Record Attendance' -> `RoutePaths.lectureRecord`, 'Calculator / Safe Bunk' -> `RoutePaths.safeBunk`, 'Settings' -> `RoutePaths.settings`).

Build & Test Requirements:
Run `dart analyze lib` and `flutter test` after making modifications.
Document all file changes, exact lines modified, build status, and test execution results in `.agents/worker_m2_1/handoff.md`. Send a message to parent when done.
