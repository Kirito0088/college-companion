# Milestone Execution Plan

## Overview
This plan decomposes the 10 requirements (R1-R10) into 6 manageable milestones, ensuring step-by-step implementation, testing, review, and verification.

---

## Milestone 1: Quick Fixes & Details Screens CRUD (R1, R2, R3)
- **R1: Onboarding Button Label**
  - File: `lib/features/onboarding/screens/onboarding_screen.dart`
  - Change button label from `'Start'` to `'Get Started'`.
- **R2: Calendar Delete Event & UI/UX**
  - File: `lib/features/calendar/screens/event_details_screen.dart`
  - Receive route params (event ID), fetch real data from `CalendarRepository`, perform actual deletion, M3 destructive alert dialog.
- **R3: Assignments CRUD & UI/UX**
  - File: `lib/features/assignments/screens/assignment_details_screen.dart`
  - Accept ID from route, load real data, implement Mark Complete, Edit, Delete with M3 dialog.

---

## Milestone 2: Semester Feature & Attendance Cleanup (R4, R9)
- **R4: Semester Feature**
  - Screens: `lib/features/semester/screens/semester_details_screen.dart` and dialogs.
  - Load real data, Add Subject dialog, Add Timetable slots, Edit dates, Add important dates, overall metrics replacing "This Week".
- **R9: Attendance Cleanup**
  - File: `lib/features/attendance/screens/attendance_screen.dart`
  - Strip fake placeholder cards/percentages, add empty state, overview insight text using real data, quick action buttons, zero attendance display (0%).

---

## Milestone 3: Notifications & Push Reminders (R5, R6)
- **R5: Local Notifications System**
  - Data model/storage for notifications.
  - Generators for upcoming lectures, assignment due dates, calendar events, low attendance warnings.
  - Mark all as read, tap navigation to details.
- **R6: Push / Local Notifications Setup**
  - `flutter_local_notifications` setup.
  - Android system permission request when toggle enabled.
  - Schedule reminders (15 min before lectures, morning of assignment due dates, calendar event time).
  - Persist preference toggle in DB.

---

## Milestone 4: Focus / Pomodoro Mode (R7)
- **R7: Pomodoro Timer & Profile Navigation**
  - Move Focus Mode to `Profile > Focus Mode`.
  - Countdown timer via `dart:async` Timer.
  - Configurable work/break duration, session counter, timer states, local notification on completion.
  - Session history storage.
  - Router (`app_router.dart`) and profile UI updates.

---

## Milestone 5: Data Sync & Dashboard Integration (R8, R10)
- **R8: Data Sync & Storage Info**
  - Sync Now (`SyncService.syncPendingMutations()`).
  - Auto/Wi-Fi/Background toggles in `UserSettingsRepository`.
  - Real database file size calculation.
  - Clear cache implementation with confirmation dialog.
- **R10: Home/Dashboard Real Data Integration**
  - Connect dashboard widgets to providers (timetable, assignments, attendance summary).
  - Remove all mock/placeholder data.
  - Functional quick actions.

---

## Milestone 6: Quality Gate & Verification
- `dart analyze lib` -> 0 errors.
- `flutter test` -> All unit/widget/integration tests passing.
- Forensic Auditor integrity check across all updated features.
