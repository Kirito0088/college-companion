# [SLICE]: Dedicated Timetable Screen, Weekly Schedule Grid & Stream Providers

- **Issue:** #101
- **Labels:** `type:slice`, `milestone:1-core-features`, `layer:ui-ux`, `layer:riverpod`, `layer:drift-db`, `priority:p0-blocker`

## 1. Student Context & Problem
Currently, `/timetable` in `app_router.dart` is wired to `PlaceholderScreen(title: 'Timetable')`. Students have no dedicated view to check, add, or manage their weekly lecture timetable schedule.

## 2. Tracer-Bullet Architecture Scope
- **UI Layer:** Create `lib/features/timetable/screens/timetable_screen.dart` featuring Monday–Saturday tabs, lecture time cards, and `AddEditTimetableEntryDialog`.
- **State Layer (Riverpod):** Implement `todayTimetableStreamProvider` and `weeklyTimetableStreamProvider` in `timetable_provider.dart`.
- **Data/Repository Layer:** Add `watchForDay(userId, dayOfWeek)` and `createEntry(TimetableCompanion)` in `timetable_repository.dart`.
- **Database (Drift SQLite):** `Timetable` table with CHECK constraint `day_of_week BETWEEN 0 AND 6`.
- **Routing:** Replace `PlaceholderScreen` with `TimetableScreen` on `RoutePaths.timetable`.

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Today's Schedule):**
  - **Given** an authenticated student with scheduled classes on Monday,
  - **When** navigating to `/timetable`,
  - **Then** display Monday's classes chronologically with subject name, room, start/end time, and teacher.
- [ ] **Scenario 2 (Empty Day):**
  - **Given** no classes scheduled for Sunday,
  - **When** Sunday tab is selected,
  - **Then** display `CcEmptyState(title: 'No classes scheduled', subtitle: 'Enjoy your free day')`.
- [ ] **Scenario 3 (Add Lecture):**
  - **Given** user fills `AddEditTimetableEntryDialog` with valid subject, room, day (0-6), and start/end time,
  - **When** saved,
  - **Then** insert into SQLite `timetable` table, enqueue to `sync_queue`, and update the UI reactively.

## 4. Verification & Quality Gates
- [ ] `dart analyze` reports 0 issues.
- [ ] `flutter test test/features/timetable_screen_test.dart` passes.
- [ ] Manual check on `Automated_Device` (`emulator-5554`).
