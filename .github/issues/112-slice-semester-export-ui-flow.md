# [SLICE]: Semester Export UI Stepper & Native Android Share Flow

- **Issue:** #112
- **Labels:** `type:slice`, `milestone:4-semester-export`, `layer:ui-ux`, `layer:riverpod`, `priority:p1-critical`

## 1. Student Context & Problem
Students need an intuitive, guided interface to trigger and monitor their semester verification and export workflow.

## 2. Tracer-Bullet Architecture Scope
- Build export bottom sheet in `SemesterDetailsScreen`:
  1. Pre-flight Check (Google Auth & Connectivity).
  2. Cloud Parity Verification.
  3. PDF Compilation.
  4. Android Intent Share Sheet.

## 3. Acceptance Criteria
- [ ] **Given** user taps "Export Semester",
  - **When** the 4 steps complete successfully,
  - **Then** open the native Android Share Sheet with the generated PDF cache path.

## 4. Verification
- [ ] `flutter test test/widget/semester_export_dialog_test.dart` passes.
