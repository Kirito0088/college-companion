## 2026-07-24T16:54:05Z
You are a teamwork_preview_worker agent assigned to implement Milestone 3 (Requirements R5, R6).
Your working directory is `c:\Projects\college_companion\.agents\worker_m3_1`. Create `.agents/worker_m3_1/progress.md` and `handoff.md`.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Scope & Strategy:
Read the investigation report at `c:\Projects\college_companion\.agents\explorer_m3_1\handoff.md` carefully.

Tasks:
1. R5 (Notifications Feature):
   - Add a Notifications table (`lib/database/tables/notifications.dart`) or local notification store / repository (`NotificationsRepository`). Register table in `app_database.dart` if needed and generate companion code or repository layer.
   - Generate dynamic notifications from real events: upcoming lectures (timetable), assignment due dates, calendar events, low attendance warnings.
   - Refactor `NotificationsScreen` (`lib/features/notifications/screens/notifications_screen.dart`) to watch notifications provider.
   - Implement "Mark all as read" functionality.
   - Wire individual notification tap handlers to navigate to the relevant detail screen (`context.push(...)`).
2. R6 (Push & Local Notifications):
   - Add `flutter_local_notifications`, `timezone`, `permission_handler` to `pubspec.yaml`.
   - Update `AndroidManifest.xml` with permissions: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`.
   - Implement `LocalNotificationService` to schedule reminders:
     - Lecture reminders 15 min before timetable slot.
     - Assignment due date reminders morning of due date.
     - Calendar event reminders.
   - Request system notification permission on enabling Push Notifications switch in Settings.
   - Persist `Lecture Reminders` toggle to database / `UserSettingsRepository` (replacing local ephemeral state in `settings_screen.dart`).

Build & Test Requirements:
Run `dart analyze lib` and `flutter test` after making modifications.
Document all file changes, exact lines modified, build status, and test execution results in `.agents/worker_m3_1/handoff.md`. Send a message to parent when done.
