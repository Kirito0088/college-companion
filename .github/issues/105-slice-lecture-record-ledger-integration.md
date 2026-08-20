# [SLICE]: Complete Lecture Record Screen Integration with Immutable Drift Ledger

- **Issue:** #105
- **Labels:** `type:slice`, `milestone:2-lecture-ledger`, `layer:ui-ux`, `layer:drift-db`, `priority:p0-blocker`

## 1. Student Context & Problem
`LectureRecordScreen` currently creates legacy `AttendanceCompanion` rows instead of writing to `lecture_records` and `LectureRecordRepository`. The 3-layer immutability model is bypassed by the UI.

## 2. Tracer-Bullet Architecture Scope
- **UI Layer:** Wire `LectureRecordScreen` directly to `lectureRecordRepositoryProvider.createRecord()`.
- **Data Layer:** Enforce 1:1 `timetable_id` uniqueness, primary status (`present`, `absent`, `cancelled`), secondary status (`facultyAbsent`, `holiday`, etc.), and immutable notes.

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Create Immutable Record):**
  - **Given** student selects attendance status for a timetable lecture,
  - **When** tapping "Save Lecture Record",
  - **Then** insert row into Drift SQLite `lecture_records` table and permanently lock further edits.
- [ ] **Scenario 2 (Locked Ledger View):**
  - **Given** existing lecture record for this timetable slot today,
  - **When** opening the screen,
  - **Then** display read-only locked ledger state with timestamp and hash indicators.

## 4. Verification & Quality Gates
- [ ] `flutter test test/features/lecture_record_repository_test.dart` passes.
