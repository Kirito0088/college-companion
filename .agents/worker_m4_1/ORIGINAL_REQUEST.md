## 2026-07-24T11:24:06Z
You are a teamwork_preview_worker agent assigned to implement Milestone 4 (Requirement R7).
Your working directory is `c:\Projects\college_companion\.agents\worker_m4_1`. Create `.agents/worker_m4_1/progress.md` and `handoff.md`.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Strategy:
Read the investigation report at `c:\Projects\college_companion\.agents\explorer_m4_1\handoff.md` carefully.

Tasks:
1. R7 (Focus / Pomodoro Mode & Navigation):
   - Relocate Focus Mode route to `Profile > Focus Mode` (`/profile/focus`) in `app_router.dart`.
   - Add `Focus Mode` (`Symbols.timer`) item into `ProfileMenuList` (`lib/features/profile/widgets/profile_menu_list.dart`). Update or redirect `SettingsScreen` link.
   - Implement Pomodoro timer state machine using `dart:async` `Timer` in a Riverpod `FocusTimerNotifier` (`focus_timer_provider.dart`).
   - Support configurable work duration (default 25 min) and break duration (default 5 min).
   - Session counter tracking completed focus sessions.
   - Timer state management (`idle`, `running`, `paused`, `break`).
   - Local notification / alert on timer completion.
   - Session history stored locally (`FocusRepository` / Drift / SharedPreferences).
   - Refactor `FocusScreen` (`lib/features/focus/screens/focus_screen.dart`) to watch timer state, update dynamic ring progress and `MM:SS` display, interactive preset chips, and display real session history.

Build & Test Requirements:
Run `dart analyze lib` and `flutter test` after making modifications.
Document all file changes, exact lines modified, build status, and test execution results in `.agents/worker_m4_1/handoff.md`. Send a message to parent when done.
