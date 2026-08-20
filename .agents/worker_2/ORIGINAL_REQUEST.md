## 2026-07-24T08:19:59Z

<USER_REQUEST>
You are Worker 2. Your task is to wire the 6 core screens to live Riverpod StreamProviders in `c:\Projects\college_companion` while strictly preserving Material 3 UI design.
Your working directory is `c:\Projects\college_companion\.agents\worker_2`. Create your directory and files there.

DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Requirements & Detailed Tasks:
1. Refer to `c:\Projects\college_companion\.agents\explorer_2\analysis.md` for screen details and `c:\Projects\college_companion\.agents\worker_1\changes.md` for provider signatures.
2. Refactor all 6 core screens to extend `ConsumerWidget` or `ConsumerStatefulWidget`:
   - `lib/features/calendar/screens/calendar_screen.dart`: Convert to `ConsumerStatefulWidget`. Watch `calendarEventsStreamProvider(userId)`. Replace hardcoded `_allEvents` mock list with dynamic stream data. Handle `AsyncValue` loading/error states cleanly. Maintain month navigation, date selection, custom painters, and Material 3 UI widgets (`CCCard`, `ListTile`).
   - `lib/features/assignments/screens/assignments_screen.dart`: Convert to `ConsumerStatefulWidget`. Watch `assignmentsStreamProvider(userId)`. Replace static assignment cards and hardcoded overview metrics (`75%`, `8 of 12 done`) with dynamic calculations from stream data. Maintain filter chips, search field, progress bar, and card layout.
   - `lib/features/resources/screens/resources_screen.dart`: Convert to `ConsumerStatefulWidget`. Watch `resourcesStreamProvider(userId)`. Replace static resource cards with live dynamic resource list filtered by category. Maintain search bar, category chips, card layouts, and icons.
   - `lib/features/settings/screens/settings_screen.dart`: Convert to `ConsumerStatefulWidget`. Watch `userSettingsStreamProvider(userId)`. Wire push notification and reminder switches to `UserSettingsRepository.upsert()`. Wire Clear Cache dialog to clear database tables or invoke clear cache logic. Maintain settings tiles, cards, and M3 layout.
   - `lib/features/dashboard/screens/dashboard_screen.dart`: Convert to `ConsumerStatefulWidget`. Watch `dashboardSnapshotProvider(userId)`. Remove artificial `Future.delayed(600ms)` loading simulation and render dynamic `DashboardSnapshot` data (`nextAction`, `timelineEvents`, `academicSnapshot`). Maintain hero action card, timeline list, macro state cards, and greeting.
   - `lib/features/attendance/screens/attendance_screen.dart`: Convert to `ConsumerStatefulWidget`. Watch `safeBunkStreamProvider(userId)` and `attendanceRepositoryProvider`. Replace hardcoded attendance stats (82%, 148 present/32 absent) and static subject cards with dynamic values from `safeBunkStreamProvider` and `AttendanceRepository`. Maintain custom painters (`_GaugePainter`, `_TrendChartPainter`), tab navigation, chips, cards, and M3 styling.
3. User ID lookup: Obtain `userId` from `ref.watch(authStateProvider).user?.id` or `ref.watch(userRepositoryProvider)` / fallback `'default_user'`.
4. Strict M3 UI Preservation: Ensure NO `GlassCard`, `GlassChip`, or neon tokens are added. All visual aesthetics must remain clean Material 3.
5. Run `dart analyze lib` using `run_command` in `c:\Projects\college_companion` to confirm 0 errors and 0 warnings.
6. Run `flutter test` using `run_command` in `c:\Projects\college_companion` to ensure all existing tests pass.
7. Write your changes report to `c:\Projects\college_companion\.agents\worker_2\changes.md` and handoff report to `c:\Projects\college_companion\.agents\worker_2\handoff.md`.
8. Send your report back to parent using `send_message`.
</USER_REQUEST>
