# [SLICE]: Local Academic Reminder Scheduler via Flutter Local Notifications

- **Issue:** #108
- **Labels:** `type:slice`, `milestone:3-notifications`, `layer:ui-ux`, `layer:riverpod`, `priority:p1-critical`

## 1. Student Context & Problem
`flutter_local_notifications` is declared in `pubspec.yaml` but never initialized in the application code. Students receive zero alerts for upcoming lectures, assignment due dates, or daily morning summaries.

## 2. Tracer-Bullet Architecture Scope
- **Service Layer:** Build `LocalNotificationService` (initialize Android notification channels, time zones via `timezone` package).
- **Scheduler Layer:** Schedule exact alarms:
  1. **10-minute Pre-Lecture Warning** (calculated from `timetable` entries).
  2. **Assignment Due Date Reminders** (24h and 2h before `dueDate`).
  3. **Daily Morning Briefing** (08:00 AM summary of today's schedule).

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Pre-Lecture Alert):**
  - **Given** lecture scheduled at 09:00 AM,
  - **When** device time reaches 08:50 AM,
  - **Then** post local notification: "Upcoming Class: Advanced Mathematics in Room 302 in 10m".
- [ ] **Scenario 2 (Assignment Alert):**
  - **Given** pending assignment due tomorrow at 11:59 PM,
  - **When** 24-hour reminder triggers,
  - **Then** display reminder with calm tone.

## 4. Verification & Quality Gates
- [ ] `flutter test test/unit/notification_service_test.dart` passes.
