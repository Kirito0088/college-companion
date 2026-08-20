# Handoff Report: Milestone 2 (R4, R9) Investigation

**Agent**: explorer_m2_1  
**Milestone**: Milestone 2 — Semester Feature (R4) & Attendance Cleanup (R9)  
**Date**: 2026-07-24  

---

## 1. Observation

### R4: Semester Feature (`lib/features/semester/`)

1. **`lib/features/semester/screens/semester_details_screen.dart`**:
   - **Lines 9–696**: The entire screen is implemented as a `StatelessWidget`. It does not listen to Riverpod providers (`ref.watch`) nor fetch any database records.
   - **Line 27, 82**: Hardcoded header labels `"Semester 5"` and `"July 2026 – November 2026"`.
   - **Lines 134, 155–158**: Hardcoded semester progress metrics (`"68%"`, `"7"` Subjects, `"24"` Credits, `"82%"` Attendance, `"68%"` Complete).
   - **Lines 191–234**: Hardcoded static subjects list (Operating Systems CS501, DBMS CS502, Computer Networks CS503, AI CS504, SE CS505, Web Tech CS506, Mini Project CS507).
   - **Lines 370–405**: Hardcoded `"This Week"` class summary (`"18"` Classes, `"12"` Completed, `"6"` Remaining).
   - **Lines 468–495**: Hardcoded `"Important Dates"` exams list (Mid Semester 15 Aug, Practical Submission 28 Aug, Viva 3 Sept, End Semester 21 Oct).
   - **Lines 583–591**: Resources section with empty `onTap: () {}` callbacks.
   - **Lines 664–688**: Hardcoded timeline (`"45 days ago"`, `"62 days remaining"`).
   - **Missing Modals & Action Dialogs**:
     - No "Add Subject" dialog/button to create subjects under this semester via `SubjectRepository.create(...)`.
     - No "Timetable Slots" dialog/button to create timetable entries via `TimetableRepository.create(...)`.
     - No "Edit Semester" dialog to edit semester name, start date, end date, or active status via `SemesterRepository.update(...)`.
     - No "Add Important Date" dialog to add calendar events via `CalendarRepository.create(...)`.

2. **`lib/features/semester/screens/semesters_list_screen.dart`**:
   - **Line 201**: `onTap: () => context.push(RoutePaths.semesterDetails)` navigates to `/semester-details` without passing any semester ID or parameter.

3. **`lib/routing/app_router.dart`**:
   - **Line 76**: Route path definition `static const String semesterDetails = '/semester-details';`.
   - **Lines 304–308**:
     ```dart
     GoRoute(
       path: RoutePaths.semesterDetails,
       name: RouteNames.semesterDetails,
       parentNavigatorKey: _rootNavigatorKey,
       builder: (context, state) => const SemesterDetailsScreen(),
     )
     ```
     The router configuration does not pass query parameters (`state.uri.queryParameters['id']`) or `state.extra` to `SemesterDetailsScreen`.

4. **Repositories & Models Ready for Integration**:
   - `SemesterRepository` (`lib/features/semester/repositories/semesters_repository.dart`): Contains `watchAll`, `watchById`, `getById`, `create`, `update`, `delete`, `watchCurrent`, `setCurrent`.
   - `SubjectRepository` (`lib/features/subjects/repositories/subjects_repository.dart`): Contains `watchBySemester`, `create`, `update`, `delete`.
   - `TimetableRepository` (`lib/features/timetable/repositories/timetable_repository.dart`): Contains `watchBySubject`, `watchByDay`, `create`, `update`, `delete`.
   - `CalendarRepository` (`lib/features/calendar/repositories/calendar_repository.dart`): Contains `watchAll`, `watchUpcoming`, `create`, `update`, `delete`.

---

### R9: Attendance Feature (`lib/features/attendance/`)

1. **`lib/features/attendance/screens/attendance_screen.dart`**:
   - **Lines 147–157 & 184–193**: When `filteredSubjects` is empty or when stream errors out, `_buildSubjectsTab` falls back to rendering fake hardcoded subject cards:
     - `_buildSubjectCard(context, 'Operating Systems', '84%', 42, 50, 0.84)`
     - `_buildSubjectCard(context, 'Database Management', '96%', 48, 50, 0.96)`
     - `_buildSubjectCard(context, 'Computer Networks', '71%', 35, 49, 0.71)`
   - **Line 164**: Fake percentage fallback for subjects with 0 attendance records:
     ```dart
     final pct = total > 0 ? (present / total) : 0.85; // 85% fallback if no records yet
     ```
     This displays `85%` for any subject that has 0 attendance records.
   - **Line 207–208**: Health card fallback string when `safeBunk == null`:
     `'You can miss approximately 8 more lectures before reaching 75%.'`
   - **Line 263**: Insights card fallback average attendance when `safeBunk == null`:
     `safeBunk != null ? '${safeBunk.currentPercentage.round()}%' : '82%';`
   - **Lines 299–307**: Hardcoded static text for Insights: `"DBMS (96%)"` (Highest) and `"CN (71%)"` (Lowest).
   - **Lines 368–372**: Requirement card defaults to `"75%"`, `"82%"`, and `"Eligible"` when `safeBunk == null`.
   - **Lines 497–522**: Quick actions cards have empty `onTap: () {}` handlers:
     - Attendance History: `onTap: () {}`
     - Attendance Calculator: `onTap: () {}` (should navigate to `RoutePaths.safeBunk`)
     - Attendance Settings: `onTap: () {}` (should navigate to `RoutePaths.settings` or `RoutePaths.dataSync`)

2. **`lib/features/attendance/widgets/overall_gauge.dart`**:
   - **Line 18**: `final pct = safeBunk != null ? safeBunk!.currentPercentage : 82.0;` — hardcoded 82.0% fallback when `safeBunk` is null.
   - **Line 29**: `badgeText` defaults to `'You can miss 12 lectures'` when `safeBunk` is null.

3. **`lib/features/attendance/widgets/stats_row.dart`**:
   - **Lines 13–15**:
     - `presentStr`: defaults to `'148'` when `safeBunk` is null.
     - `absentStr`: defaults to `'32'` when `safeBunk` is null.
     - `totalStr`: defaults to `'180'` when `safeBunk` is null.

4. **`lib/features/attendance/widgets/attendance_trend_card.dart`**:
   - **Lines 163–171**: Uses hardcoded point offsets (`Offset(0, 0.5)`, `Offset(0.16, 0.6)...`) to draw a static trend curve regardless of actual data.

---

## 2. Logic Chain

1. **R4 (Semester Feature) Gap Reasoning**:
   - The user request requires a complete semester feature including the details screen, router config, subject creation dialog, timetable slots, semester dates edit, important dates, and overall status metrics.
   - Currently, `SemesterDetailsScreen` is disconnected from Drift database models and Riverpod state. It renders static strings and mock arrays.
   - Therefore, `SemesterDetailsScreen` must be converted to a Riverpod `ConsumerWidget` or `ConsumerStatefulWidget` that accepts a `semesterId` (from query params or current active semester), watches `semesterStreamProvider`, `subjectsBySemesterStreamProvider`, `timetableStreamProvider`, and `calendarEventsStreamProvider`, and dynamically computes status metrics.
   - Navigation in `app_router.dart` and `semesters_list_screen.dart` must pass `semesterId` to ensure the correct semester is loaded.
   - User actions (Add Subject, Add Timetable Slot, Edit Semester, Add Important Date) must be exposed via standard M3 dialogs invoking respective repository methods.

2. **R9 (Attendance Cleanup) Gap Reasoning**:
   - The user request requires stripping all fake/placeholder cards, displaying zero-attendance properly (0%), providing dynamic overview insight text, and wiring quick action button navigation.
   - Currently, if there are no subjects or 0 attendance records, the UI injects fake cards (OS, DBMS, CN) and fake metrics (85%, 82%, 148 present, 32 absent, 180 total).
   - Furthermore, quick action cards have empty `onTap: () {}` callbacks.
   - Therefore, all hardcoded fallbacks (0.85, 82.0, 148, 32, 180) must be replaced with `0.0` or `'0'` / empty state widgets (`EmptySubjects()`).
   - Overview insights must compute highest/lowest subject attendance dynamically from subject records.
   - Quick action `onTap` handlers must be wired to GoRouter paths (`RoutePaths.safeBunk`, `RoutePaths.lectureRecord`, `RoutePaths.settings`).

---

## 3. Caveats

- **No Schema Changes Needed**: Drift database tables (`semesters`, `subjects`, `timetable`, `attendance`, `calendar_events`, `lecture_records`) and repositories are fully implemented and tested in the core data layer.
- **Scope Limit**: This report provides read-only investigation and exact technical specification. Source code implementation should be executed by the implementer agent in Milestone 2.

---

## 4. Conclusion & Recommended Fix Strategy

### Fix Strategy for R4 (Semester Feature)

1. **Routing (`lib/routing/app_router.dart`)**:
   - Update `/semester-details` route to extract `semesterId` from query parameter or `state.extra`:
     ```dart
     GoRoute(
       path: RoutePaths.semesterDetails,
       name: RouteNames.semesterDetails,
       parentNavigatorKey: _rootNavigatorKey,
       builder: (context, state) {
         final semesterId = state.uri.queryParameters['id'] ?? state.extra as String?;
         return SemesterDetailsScreen(semesterId: semesterId);
       },
     )
     ```
   - In `semesters_list_screen.dart` (line 201), update card tap:
     `context.push('${RoutePaths.semesterDetails}?id=${semester.id}');`

2. **`SemesterDetailsScreen` Refactoring**:
   - Convert to `ConsumerStatefulWidget`.
   - Accept optional `String? semesterId`. If `semesterId == null`, watch current active semester via `ref.watch(currentSemesterStreamProvider(userId))`.
   - Watch subjects for semester via `ref.watch(subjectsBySemesterStreamProvider(userId, targetSemesterId))`.
   - Calculate real overall metrics:
     - Subject count, total credits.
     - Attendance percentage aggregated across subjects.
     - Semester start date, end date, days elapsed, days remaining.
     - Weekly timetable class count and status.
   - Add M3 Dialogs:
     - **Add Subject Dialog**: Input name, code, faculty, type (`theory`/`practical`/`tutorial`). Calls `SubjectRepository.create`.
     - **Add Timetable Slot Dialog**: Select subject, day of week (0-6), start time, end time, room, lecture type. Calls `TimetableRepository.create`.
     - **Edit Semester Dialog**: Edit name, start/end dates, active status. Calls `SemesterRepository.update`.
     - **Add Important Date Dialog**: Title, date, event type. Calls `CalendarRepository.create`.

---

### Fix Strategy for R9 (Attendance Feature)

1. **Strip Hardcoded & Placeholder Fallbacks**:
   - In `attendance_screen.dart` line 164, change:
     `final pct = total > 0 ? (present / total) : 0.0;`
   - In `_buildSubjectsTab`: If `subjects` list is empty, return `Center(child: EmptySubjects())` instead of hardcoded OS, DBMS, CN cards.
   - In `OverallGauge` (`overall_gauge.dart` line 18): Default `pct` to `0.0` when `safeBunk == null`. Display `'0%'` and `'No attendance records'`.
   - In `StatsRow` (`stats_row.dart` lines 13–15): Default `presentStr`, `absentStr`, `totalStr` to `'0'` when `safeBunk == null`.

2. **Real Overview Insights**:
   - Compute highest and lowest attendance subject dynamically by iterating over watched subjects and their attendance records.
   - Count subjects where attendance percentage < 75.0%.
   - If no attendance records exist, display `'N/A'` or `'0 Subjects'`.

3. **Wire Quick Action Navigation**:
   - "Attendance Calculator" -> `context.push(RoutePaths.safeBunk)`
   - "Attendance History" / "Log Lecture" -> `context.push(RoutePaths.lectureRecord)`
   - "Attendance Settings" -> `context.push(RoutePaths.settings)`

4. **Dynamic Trend Card**:
   - Compute day-by-day attendance % for the current week (Mon–Sun) using `AttendanceRepository.watchByDateRange`. Draw points accordingly or flat 0% line when no records exist.

---

## 5. Verification Method

To verify the implementation once applied:
1. **Static Analysis**:
   ```bash
   dart analyze lib
   ```
   Expect 0 issues.

2. **Automated Testing**:
   ```bash
   flutter test test/widget/core_screens_widget_test.dart
   flutter test test/features/attendance_read_model_test.dart
   ```
   Expect all tests to pass.

3. **Manual Invalidation Conditions**:
   - Any remaining hardcoded fallback strings (`'85%'`, `'82%'`, `'148'`, `'32'`, `'180'`, `'Semester 5'`, `'CS501'`).
   - Unhandled zero-attendance division by zero.
   - Clicking quick action cards resulting in no navigation (`onTap: () {}`).
