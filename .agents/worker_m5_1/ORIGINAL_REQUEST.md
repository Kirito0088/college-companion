## 2026-07-24T11:24:06Z
<USER_REQUEST>
You are a teamwork_preview_worker agent assigned to implement Milestone 5 (Requirements R8, R10).
Your working directory is `c:\Projects\college_companion\.agents\worker_m5_1`. Create `.agents/worker_m5_1/progress.md` and `handoff.md`.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Strategy:
Read the investigation report at `c:\Projects\college_companion\.agents\explorer_m5_1\handoff.md` carefully.

Tasks:
1. R8 (Sync Data & Clear Cache):
   - In `lib/features/settings/screens/data_sync_screen.dart`:
   - Wire `Sync Now` button to trigger `SyncService.syncPendingMutations()` and show real progress indicator and last synced status.
   - Connect Auto Sync / Wi-Fi Only / Background Sync toggles to `UserSettingsRepository` (add missing preference methods if needed).
   - Calculate real SQLite database file size and temporary cache folder size, replacing hardcoded strings.
   - Add Clear Cache action tile with M3 confirmation dialog to clear `getTemporaryDirectory()` files safely (without deleting database).
   - Save and display real last synced timestamp from `SyncMetadataDao`.
2. R10 (Dashboard / Home Integration):
   - In `lib/features/dashboard/screens/dashboard_screen.dart` & `providers/dashboard_provider.dart`:
   - Include `QuickActionsSection` in `DashboardScreen` layout with functional navigation (`RoutePaths.timetable`, `RoutePaths.attendance`, `RoutePaths.assignments`, `RoutePaths.internalMarks`).
   - Query today's timetable slots (`TimetableRepository.watchByDay`) and combine with calendar events in `dashboard_provider.dart` for real class schedule.
   - Compute attendance summary and upcoming assignments from real providers.
   - Compute next break state dynamically instead of hardcoded string.
   - Remove any remaining mock/placeholder data.

Build & Test Requirements:
Run `dart analyze lib` and `flutter test` after making modifications.
Document all file changes, exact lines modified, build status, and test execution results in `.agents/worker_m5_1/handoff.md`. Send a message to parent when done.
</USER_REQUEST>
