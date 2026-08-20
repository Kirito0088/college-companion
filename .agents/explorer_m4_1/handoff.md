# Handoff Report: Requirement R7 - Focus / Pomodoro Mode & Navigation

## 1. Observation

Direct observations from codebase inspection of `c:\Projects\college_companion`:

### 1.1 Routing & Navigation
* **`lib/routing/app_router.dart`**:
  * Line 27: `import 'package:college_companion/features/focus/screens/focus_screen.dart';`
  * Line 83: `static const String focusMode = '/focus-mode';`
  * Line 121: `static const String focusMode = 'focus-mode';`
  * Lines 270–279: `StatefulShellBranch` for `Profile` only contains `ProfileScreen` at `/profile`.
  * Lines 340–345:
    ```dart
    GoRoute(
      path: RoutePaths.focusMode,
      name: RouteNames.focusMode,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FocusScreen(),
    ),
    ```
* **`lib/features/profile/widgets/profile_menu_list.dart`**:
  * Lines 27–67: `ProfileMenuList` currently contains 6 menu items:
    1. `Semesters` (`RoutePaths.semester`)
    2. `Notifications` (`RoutePaths.notifications`)
    3. `Settings` (`RoutePaths.settings`)
    4. `Data & Sync` (`RoutePaths.dataSync`)
    5. `Help & Support` (`RoutePaths.helpSupport`)
    6. `About College Companion` (`RoutePaths.about`)
  * `Focus Mode` is missing from `ProfileMenuList`.
* **`lib/features/settings/screens/settings_screen.dart`**:
  * Lines 139–150: Contains a section titled `'Study & Focus'` with `Focus Mode` linking to `RoutePaths.focusMode`:
    ```dart
    _SettingsRow(
      icon: Symbols.timer,
      label: 'Focus Mode',
      showBorder: false,
      onTap: () => context.push(RoutePaths.focusMode),
    )
    ```

### 1.2 Pomodoro Timer & UI State
* **`lib/features/focus/screens/focus_screen.dart`**:
  * Line 8: `class FocusScreen extends StatefulWidget`
  * Lines 15–18: Local ephemeral state variables:
    ```dart
    bool _isRunning = false;
    String _selectedPreset = '25 min';
    bool _dndEnabled = true;
    ```
  * Lines 85–155 (`_buildHeroTimer`):
    * Line 94–107: Static `TweenAnimationBuilder<double>` animation fixed from `0` to `0.75`.
    * Line 112: Hardcoded static display string `'25:00'`.
    * Line 139: Hardcoded static progress text `"Today's Progress: 2 / 8 Sessions"`.
  * Lines 157–201 (`_buildSessionControls`):
    * Toggles `_isRunning = true / false` state only. No `dart:async` `Timer` is instantiated, running, or ticking.
  * Lines 241–288 (`_buildSessionPresets`):
    * Option chips (`'25 min'`, `'45 min'`, `'60 min'`, `'Custom'`) update local string `_selectedPreset` without modifying countdown duration or timer state.
  * Lines 290–335 (`_buildStatisticsCard`):
    * Hardcoded focus stats: `'2h 15m'`, Sessions `'5'`, Streak `'3'`.
  * Lines 337–402 (`_buildStudyGoalCard`):
    * Hardcoded progress `'5 / 8 Sessions'` with static linear animation (`begin: 0, end: 5 / 8`).
  * Lines 476–569 (`_buildSessionHistory`):
    * Hardcoded static session history entries for Mathematics (25 min), Operating Systems (45 min), DBMS Revision (25 min).

### 1.3 Dependencies & Persistence Capabilities
* **`pubspec.yaml`**:
  * `flutter_riverpod: ^2.6.1` is present.
  * `drift: ^2.25.0` is present.
  * `shared_preferences: ^2.5.3` is present.
  * `flutter_local_notifications` is **not** present in `pubspec.yaml`.

---

## 2. Logic Chain

1. **Routing Relocation Requirement**:
   * *Observation*: Focus Mode route is currently defined as top-level `/focus-mode` (lines 83, 340-345 in `app_router.dart`) and linked from `SettingsScreen` (line 147 in `settings_screen.dart`).
   * *Deduction*: To relocate Focus Mode under `Profile > Focus Mode` as requested by R7:
     a) Route path `RoutePaths.focusMode` should be updated to `'/profile/focus'` (or nested under `/profile`).
     b) A new `_MenuItem` for `'Focus Mode'` with icon `Symbols.timer` (or `Symbols.center_focus_strong`) must be added to `ProfileMenuList` in `lib/features/profile/widgets/profile_menu_list.dart`.
     c) Navigating to `RoutePaths.focusMode` from `ProfileMenuList` will take users to Focus Mode.
     d) The `SettingsScreen` entry under `'Study & Focus'` should be removed or redirected to `Profile > Focus Mode`.

2. **Pomodoro Timer Engine Requirement**:
   * *Observation*: `FocusScreen` uses local `StatefulWidget` booleans with static strings (`'25:00'`, 75% hardcoded arc) and no `Timer` instance (`lib/features/focus/screens/focus_screen.dart`:15-201).
   * *Deduction*: A proper Pomodoro state machine using `dart:async` `Timer` periodic ticks must be introduced. To ensure timer countdown state persists when the user navigates away from `FocusScreen` to other tabs/screens, the state machine must live inside a global Riverpod `Notifier` / `StateNotifier` (`FocusTimerNotifier`).

3. **Timer States & Configuration**:
   * *Observation*: Requirement R7 specifies configurable work (25 min default) / break (5 min default) durations, session counter, timer states (`running`, `paused`, `break`, `idle`).
   * *Deduction*:
     * Define `FocusTimerState` model holding: `status` (`idle`, `running`, `paused`, `breakMode`), `remainingSeconds`, `totalSeconds`, `workDurationMinutes` (default 25), `breakDurationMinutes` (default 5), `completedSessionsToday`, `currentSubject`.
     * `FocusTimerNotifier` manages a periodic 1-second `Timer.periodic`.
     * On each tick, decrement `remainingSeconds`.
     * When `remainingSeconds == 0`:
       * If in work mode: complete session, increment session counter, persist to history, send completion notification, transition to `breakMode` (countdown `breakDurationMinutes * 60`).
       * If in break mode: complete break, send break completion notification, transition to `idle` (reset countdown to `workDurationMinutes * 60`).

4. **Local Notification & Session History Persistence**:
   * *Observation*: `flutter_local_notifications` is not in `pubspec.yaml`, but Riverpod, Drift, and `shared_preferences` are available.
   * *Deduction*:
     * For Local Notification on Completion: Use an in-app notification banner / `SnackBar` / dialog notification via a Riverpod listener or notification service helper when the session reaches 0 seconds (and optionally add `flutter_local_notifications` package if OS-level system bar alerts during backgrounding are required).
     * For Session History Persistence: Create a `focus_sessions` Drift database table (or `FocusRepository` storing completed sessions in Drift DB / `SharedPreferences`) with columns: `id`, `userId`, `subjectName`, `durationMinutes`, `completedAt`.

---

## 3. Caveats

* **System-level vs In-App Notifications**: `flutter_local_notifications` is not currently in `pubspec.yaml`. If the requirement "local notification on completion" strictly means OS system tray push notifications while the app is backgrounded/closed, `flutter_local_notifications` will need to be added to `pubspec.yaml` and initialized. If in-app alerts are sufficient when the app is active, `ScaffoldMessenger` / custom SnackBar / dialog notification service is fully supported with existing dependencies.
* **Drift Schema Migration**: Adding a new table `focus_sessions` to Drift (`lib/database/app_database.dart`) will require updating schema version or adding database table registry mapping and running `build_runner`. Alternatively, `SharedPreferences` can provide immediate lightweight local persistence for session history without modifying DB schema.

---

## 4. Conclusion

Requirement R7 requires two primary workstreams:

1. **Routing & Location Migration**:
   * Change `RoutePaths.focusMode` path to `'/profile/focus'` in `lib/routing/app_router.dart`.
   * Add a Focus Mode item (`Symbols.timer`) into `ProfileMenuList` in `lib/features/profile/widgets/profile_menu_list.dart`.
   * Remove/refactor the Focus Mode row in `lib/features/settings/screens/settings_screen.dart`.

2. **Pomodoro Timer Architecture**:
   * Create `lib/features/focus/models/focus_timer_state.dart` with state enums and properties.
   * Create `lib/features/focus/providers/focus_timer_provider.dart` using Riverpod + `dart:async` `Timer`.
   * Create `lib/features/focus/repositories/focus_repository.dart` for session history persistence.
   * Refactor `lib/features/focus/screens/focus_screen.dart` to consume `focusTimerProvider`, displaying real countdown `MM:SS`, dynamic ring progress, interactive preset configuration, and real session history list.

---

## 5. Verification Method

To independently verify the implementation after code changes are completed:

1. **Static Analysis & Compilation**:
   ```bash
   flutter analyze lib/features/focus/ lib/features/profile/ lib/routing/app_router.dart
   ```
   *Expected result*: No errors or warnings.

2. **Unit & Widget Testing**:
   Run existing widget test suite:
   ```bash
   flutter test test/widget/core_screens_widget_test.dart
   ```
   Add a new test `test/unit/focus_timer_test.dart` testing:
   * Timer start, pause, resume, reset transitions.
   * Work session completion and transition to break mode.
   * Session counter incrementing and history persistence.

3. **Manual Verification / UI Flow Inspection**:
   * Navigate to `Profile` tab (`/profile`).
   * Tap on `Focus Mode` in `ProfileMenuList`. Confirm route is `/profile/focus`.
   * Start a 25-min focus session. Observe `MM:SS` ticking down and arc progress updating dynamically.
   * Switch presets to 45 min / 5 min break.
   * Pause and resume timer. End session manually.
   * Verify session history list displays saved sessions.
