## 2026-07-24T13:42:08Z
<USER_REQUEST>
You are Worker 1. Your task is to implement and restore the Phase 6 Riverpod StreamProviders and related presentation models in `c:\Projects\college_companion` on `main`.
Your working directory is `c:\Projects\college_companion\.agents\worker_1`. Create your directory and files there.

DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Tasks:
1. Read the findings from `c:\Projects\college_companion\.agents\explorer_1\analysis.md` for exact StreamProvider code structures.
2. Implement/Restore StreamProviders and Domain Models in `lib/`:
   - `lib/features/assignments/providers/assignments_provider.dart`:
     - `assignmentRepositoryProvider`
     - `assignmentsStreamProvider` (`StreamProvider.family<List<AssignmentData>, String>` or matching Drift entity type) calling `watchAll(userId)`
     - `pendingAssignmentsStreamProvider` calling `watchPending(userId)`
   - `lib/features/attendance/providers/attendance_provider.dart`:
     - `attendanceRepositoryProvider`
     - `SafeBunkResult` class & `SafeBunkCalculator` utility
     - `safeBunkStreamProvider` (`StreamProvider.family<SafeBunkResult, String>`) watching `attendanceRepositoryProvider` and calculating safe bunks.
   - `lib/features/calendar/providers/calendar_provider.dart`:
     - `calendarRepositoryProvider`
     - `calendarEventsStreamProvider` (`StreamProvider.family<List<CalendarEventData>, String>`) calling `watchAll(userId)`
   - `lib/features/resources/providers/resources_provider.dart`:
     - `resourcesRepositoryProvider`
     - `resourcesStreamProvider` (`StreamProvider.family<List<ResourceData>, String>`) calling `watchAll(userId)`
   - `lib/features/settings/providers/settings_provider.dart`:
     - `userSettingsRepositoryProvider`
     - `userSettingsStreamProvider` (`StreamProvider.family<UserSettingsData?, String>`) calling `watchByUserId(userId)`
   - `lib/features/dashboard/models/dashboard_snapshot.dart` & `lib/features/dashboard/providers/dashboard_provider.dart`:
     - Presentation models: `DashboardSnapshot`, `HeroAction`, `TimelineEvent`, `AcademicSnapshot`
     - `dashboardSnapshotProvider`: `FutureProvider.family<DashboardSnapshot, String>` or `StreamProvider.family<DashboardSnapshot, String>` aggregating values from calendar, assignments, and attendance streams.
3. Check all repository method names and Drift model names in `lib/database/app_database.dart` and `lib/features/*/repositories/` to ensure exact type compatibility and signature matching.
4. DO NOT copy over any glassmorphism or neon visual tokens (`GlassCard`, `GlassChip`, `primaryCyan`, etc.).
5. Run `dart analyze lib` using `run_command` in `c:\Projects\college_companion` to confirm all provider files compile cleanly without any analyze errors or warnings.
6. Document changes in `c:\Projects\college_companion\.agents\worker_1\changes.md` and write a handoff report in `c:\Projects\college_companion\.agents\worker_1\handoff.md`.
7. Send your report back to parent using `send_message`.
</USER_REQUEST>
