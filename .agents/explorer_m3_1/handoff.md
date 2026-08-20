# Handoff Report: Milestone 3 (R5 & R6 - Notifications & Push Reminders)

**Agent ID:** `explorer_m3_1`  
**Working Directory:** `c:\Projects\college_companion\.agents\explorer_m3_1`  
**Date:** 2026-07-24  

---

## 1. Observation

### R5: Notifications Screen & System (`lib/features/notifications/`)

1. **Static UI Implementation (`lib/features/notifications/screens/notifications_screen.dart`)**:
   - `NotificationsScreen` is a `StatelessWidget` (`lib/features/notifications/screens/notifications_screen.dart:8-143`).
   - Hardcoded notification list with static strings for "Critical Academic Alerts", "Upcoming Today", and "Insights & Updates" (`lib/features/notifications/screens/notifications_screen.dart:47-139`).
   - Header "Mark all read" action (`Symbols.done_all`, lines 35-38) has a stub handler: `onPressed: () {}` (`line 37`).
   - Notification item list tile (`_NotificationItem`, lines 187-296) has a stub tap handler: `onTap: () {}` (`line 215`). Tap navigation to target feature screens (e.g., Attendance screen for low attendance, Assignment details for due assignments, Calendar for exam alerts) is not implemented.
   - Unread state indicator (`line 211, lines 257-268`) is strictly visual based on constructor parameter `isUnread: true/false`, with no backing dynamic state.

2. **Absence of Notifications DB Table & Repositories/Providers**:
   - In `lib/database/tables/`, there are tables for `assignments.dart`, `attendance.dart`, `calendar_events.dart`, `internal_marks.dart`, `lecture_records.dart`, `timetable.dart`, `user_settings.dart`, etc., but **no `notifications.dart` table** exists.
   - In `lib/database/app_database.dart`, there is no notification entity registered in `@DriftDatabase`.
   - In `lib/features/notifications/`, there are no `models/`, `repositories/`, `providers/`, or `services/` subdirectories. Only `screens/notifications_screen.dart` exists.

3. **Event Querying & Reactive Domain Streams**:
   - `lib/features/assignments/providers/assignments_provider.dart:19-30` provides `assignmentsStreamProvider` and `pendingAssignmentsStreamProvider`.
   - `lib/features/calendar/providers/calendar_provider.dart:19-23` provides `calendarEventsStreamProvider`.
   - `lib/features/attendance/providers/attendance_provider.dart:85-101` provides `safeBunkStreamProvider`.
   - `lib/features/timetable/providers/timetable_provider.dart:11-15` provides `timetableRepositoryProvider`.
   - None of these domain streams are currently piped into a unified notification aggregator or alert generation engine.

---

### R6: Push & Local Notifications (`flutter_local_notifications`)

1. **Missing Packages in `pubspec.yaml` (`pubspec.yaml:10-51`)**:
   - `flutter_local_notifications` is **NOT** listed in `pubspec.yaml`.
   - `timezone` (required for scheduled local notifications) is **NOT** listed in `pubspec.yaml`.
   - `permission_handler` is **NOT** listed in `pubspec.yaml`.

2. **Android Permissions & Manifest Configuration (`android/app/src/main/AndroidManifest.xml:1-63`)**:
   - Only `INTERNET` (`line 2`) and `ACCESS_NETWORK_STATE` (`line 3`) permissions are declared.
   - Missing required Android permissions:
     - `android.permission.POST_NOTIFICATIONS` (required for Android 13+ / API 33+).
     - `android.permission.SCHEDULE_EXACT_ALARM` / `android.permission.USE_EXACT_ALARM` (required for exact scheduled lecture & assignment reminders).
     - `android.permission.RECEIVE_BOOT_COMPLETED` (required to reschedule pending notifications upon device reboot).
     - `android.permission.VIBRATE`.

3. **Missing Notification Service Implementation**:
   - There is no local notification service (e.g. `LocalNotificationService`) in `lib/services/` or `lib/features/notifications/services/`.
   - Notification channel configuration (e.g. `channel_lectures`, `channel_assignments`, `channel_calendar`) and permission request flows are missing.
   - Background/scheduled notification logic for:
     - Lectures (15 min before start time)
     - Assignment due dates (morning of due date, e.g. 8:00 AM)
     - Calendar events
     is unhandled.

4. **User Settings Persistence for Lecture Reminders (`lib/features/settings/screens/settings_screen.dart`)**:
   - `Push Notifications` switch (`lib/features/settings/screens/settings_screen.dart:91-124`) calls `userSettingsRepositoryProvider.saveSettings(...)` to persist `notificationsEnabled` into Drift `user_settings` table.
   - `Lecture Reminders` switch (`lib/features/settings/screens/settings_screen.dart:125-135`) is bound ONLY to a component local state variable `bool _lectureReminders = true;` (`line 26`). Toggling this switch only invokes `setState` (`lines 130-132`) and is **NOT persisted** to Drift or `SharedPreferences`. When `SettingsScreen` reloads, `_lectureReminders` resets to `true`.
   - In `lib/database/tables/user_settings.dart:17-47`, the schema includes `notificationsEnabled` (`line 26`) and `preferences` JSON string (`line 37`), but lacks a dedicated column for `lectureRemindersEnabled` or logic to update the `preferences` / `enabledModules` text column.

---

## 2. Logic Chain

1. **Observation**: `notifications_screen.dart` uses hardcoded arrays of `_NotificationItem` widgets with empty callbacks `onPressed: () {}` and `onTap: () {}`.  
   **Deduction**: The notification screen is a frontend UI prototype without backing state management, dynamic data fetching, mark-as-read mutations, or route navigation on item tap.

2. **Observation**: Drift database contains no `Notifications` table or DAO.  
   **Deduction**: Notifications generated dynamically or via events cannot be persisted locally, marked as read across sessions, or listed reactively unless a Drift database table / persistent model layer is created.

3. **Observation**: `pubspec.yaml` lacks `flutter_local_notifications`, `timezone`, and `permission_handler`.  
   **Deduction**: Attempting to invoke local or scheduled push notifications will fail at build time. Dependencies must be added and configured first.

4. **Observation**: `AndroidManifest.xml` only declares basic network permissions.  
   **Deduction**: Scheduled local notifications on modern Android versions (Android 13+) will fail or fail to schedule exact alarms unless `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, and `RECEIVE_BOOT_COMPLETED` permissions and receiver components are declared.

5. **Observation**: `SettingsScreen` manages `_lectureReminders` using an unpersisted `StatefulWidget` field `bool _lectureReminders = true;`.  
   **Deduction**: User preference for lecture reminders is lost whenever the settings screen is closed and reopened. The setting must be hooked up to `UserSettingsRepository` / `UserSettings` table in Drift.

---

## 3. Caveats

- **Network Mode**: Investigation was executed under `CODE_ONLY` mode. No remote API calls or external downloads were executed.
- **Platform Limitations**: iOS notification setup (`AppDelegate.swift` / `Info.plist` permissions) was verified structurally; full iOS device testing requires macOS build tools.
- **Background Execution Engine**: Depending on whether background scheduling needs to trigger while the app is killed or device rebooted, `flutter_local_notifications` uses standard Android `AlarmManager` under `zonedSchedule`. No separate WorkManager is strictly necessary if standard exact alarms with `RECEIVE_BOOT_COMPLETED` are used.

---

## 4. Conclusion & Recommended Implementation Strategy

To satisfy requirements R5 and R6 completely, implementers should follow this structured step-by-step strategy:

### Phase 1: Dependencies & Android Manifest Setup (R6)
1. In `pubspec.yaml`:
   - Add `flutter_local_notifications: ^18.0.1`
   - Add `timezone: ^0.9.4`
   - Add `permission_handler: ^11.3.1`
2. In `android/app/src/main/AndroidManifest.xml`:
   - Add permissions:
     ```xml
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
     <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
     <uses-permission android:name="android.permission.VIBRATE"/>
     ```
   - Add boot receiver for rescheduling exact notifications after reboot.

### Phase 2: User Settings Persistence Fix (R6)
1. Update `lib/database/tables/user_settings.dart`:
   - Either add `BoolColumn get lectureRemindersEnabled => boolean().withDefault(const Constant(true))();` or manage it inside `preferences` JSON map. (Adding column is cleaner and queryable).
   - Re-run `flutter pub run build_runner build --delete-conflicting-outputs`.
2. Update `lib/features/settings/repositories/user_settings_repository.dart`:
   - Add helper `updateLectureRemindersEnabled(String userId, bool enabled)`.
3. Update `lib/features/settings/screens/settings_screen.dart:125-135`:
   - Connect `Lecture Reminders` switch to `userSettingsStreamProvider` and `UserSettingsRepository`.

### Phase 3: Local Notification Service (R6)
1. Create `lib/services/local_notification_service.dart`:
   - Initialize `FlutterLocalNotificationsPlugin`.
   - Setup timezones via `tz.initializeTimeZones()`.
   - Create channels: `lectures_channel`, `assignments_channel`, `calendar_channel`.
   - Methods:
     - `requestPermissions()`
     - `scheduleLectureReminder({required int id, required String title, required String body, required DateTime scheduledTime})` (15 min before lecture start).
     - `scheduleAssignmentReminder({required int id, required String title, required String body, required DateTime dueDate})` (8:00 AM on assignment due date).
     - `scheduleCalendarEventReminder(...)`
     - `cancelNotification(int id)` / `cancelAll()`.

### Phase 4: Notifications Schema & Repository (R5)
1. Create `lib/database/tables/notifications.dart`:
   - Fields: `id`, `userId`, `title`, `message`, `type`, `targetRoute`, `isRead`, `createdAt`, `deletedAt`.
2. Create `lib/features/notifications/repositories/notifications_repository.dart`:
   - `watchAll(String userId)`
   - `markAsRead(String id)`
   - `markAllAsRead(String userId)`
   - `insertNotification(NotificationsCompanion notification)`
3. Create Riverpod providers in `lib/features/notifications/providers/notifications_provider.dart`:
   - `notificationsStreamProvider`
   - `unreadNotificationsCountProvider`

### Phase 5: Notifications Screen Integration (R5)
1. Refactor `lib/features/notifications/screens/notifications_screen.dart`:
   - Convert to `ConsumerWidget` or `ConsumerStatefulWidget`.
   - Watch `notificationsStreamProvider(userId)`.
   - Group notifications dynamically into "Critical Academic Alerts", "Upcoming Today", "Insights & Updates".
   - Bind "Mark all read" button (`line 35-38`) to `ref.read(notificationsRepositoryProvider).markAllAsRead(userId)`.
   - Bind `_NotificationItem.onTap` (`line 215`) to:
     1. Mark notification as read.
     2. `context.push(notification.targetRoute)` if `targetRoute` is present.

---

## 5. Verification Method

To verify the implementation independently:

1. **Static Analysis & Build Verification**:
   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   dart analyze
   ```
2. **Unit Tests**:
   - Run unit tests for UserSettingsRepository persistence:
     ```bash
     flutter test test/unit/database/user_settings_repository_test.dart
     ```
   - Add unit tests for `NotificationsRepository` (`test/unit/database/notifications_repository_test.dart`) testing `watchAll`, `markAsRead`, and `markAllAsRead`.
3. **Widget & Flow Inspection**:
   - Verify `NotificationsScreen` updates dynamically when new notifications are added or marked read.
   - Verify `Lecture Reminders` switch state persists across page navigate-away and app restart.
