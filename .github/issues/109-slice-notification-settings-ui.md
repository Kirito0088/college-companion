# [SLICE]: Notification Settings UI & Channel Configuration

- **Issue:** #109
- **Labels:** `type:slice`, `milestone:3-notifications`, `layer:ui-ux`, `layer:riverpod`, `priority:p2-normal`

## 1. Student Context & Problem
Students need the ability to toggle notification channels (e.g. disable morning digest or adjust reminder lead time) without being overwhelmed by notifications.

## 2. Tracer-Bullet Architecture Scope
- Wire toggles in `SettingsScreen` to `UserSettingsRepository.updateNotificationPreferences()`.
- Update alarm scheduling logic in `LocalNotificationService` to respect disabled channels.

## 3. Acceptance Criteria
- [ ] **Given** student turns off "Lecture Reminders",
  - **When** switch is toggled,
  - **Then** cancel all pending lecture alarm IDs in `flutter_local_notifications`.

## 4. Verification
- [ ] `flutter test test/unit/database/user_settings_repository_test.dart` passes.
