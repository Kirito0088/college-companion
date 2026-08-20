# [SLICE]: Dynamic Subject Details Screen with Route Parameter & Live Streams

- **Issue:** #102
- **Labels:** `type:slice`, `milestone:1-core-features`, `layer:ui-ux`, `layer:riverpod`, `layer:drift-db`, `priority:p1-critical`

## 1. Student Context & Problem
`SubjectDetailsScreen` currently hardcodes "Operating Systems CS501" and does not accept a `subjectId` parameter. Students cannot view real subject data, faculty, or subject-specific attendance and assignments.

## 2. Tracer-Bullet Architecture Scope
- **UI Layer:** Refactor `SubjectDetailsScreen` to accept `required String subjectId`, displaying dynamic subject name, code, type chip (theory/practical/tutorial), attendance ring, and related assignments.
- **State Layer (Riverpod):** Create `subjectDetailsStreamProvider(subjectId)` combining subject entity, attendance percentage, and pending assignments.
- **Data/Repository Layer:** Add `SubjectsRepository.getById(subjectId)` and `AttendanceRepository.watchBySubject(subjectId)`.
- **Routing:** Update `RoutePaths.subjectDetails` to `/subject-details/:id` and pass `subjectId` from route path parameter.

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Dynamic Render):**
  - **Given** tapping subject "Database Systems" (`sub_db_1`) in the subjects list,
  - **When** navigating to `/subject-details/sub_db_1`,
  - **Then** render "Database Systems", its code, faculty name, and syllabus notes.
- [ ] **Scenario 2 (Live Attendance Reactivity):**
  - **Given** user marks a lecture as Present for this subject,
  - **When** database row updates,
  - **Then** the attendance gauge on this screen updates instantly without requiring a page reload.

## 4. Verification & Quality Gates
- [ ] `dart analyze` reports 0 issues.
- [ ] `flutter test test/features/subject_details_screen_test.dart` passes.
