# [SLICE]: Automated Virtual Device E2E Integration Suite

- **Issue:** #116
- **Labels:** `type:slice`, `milestone:6-release`, `layer:e2e-test`, `priority:p0-blocker`

## 1. Student Context & Problem
Guarantee zero regressions and flawless end-to-end user flows across physical/virtual Android devices prior to release.

## 2. Tracer-Bullet Architecture Scope
- Build comprehensive test suite in `integration_test/app_e2e_test.dart` targeting `Automated_Device` (`emulator-5554`).
- Flow: Onboarding $\rightarrow$ Setup Semester $\rightarrow$ Configure Timetable $\rightarrow$ Record Lecture with Photo Evidence $\rightarrow$ Go Offline $\rightarrow$ Add Assignment $\rightarrow$ Go Online $\rightarrow$ Auto-Sync $\rightarrow$ Verify & Export PDF.

## 3. Acceptance Criteria
- [ ] **Given** fresh emulator installation,
  - **When** running E2E integration test,
  - **Then** execute full student lifecycle with 100% pass rate.

## 4. Verification
- [ ] `flutter test integration_test/app_e2e_test.dart -d emulator-5554` passes.
