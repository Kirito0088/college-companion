# Empirical Stress Test & Adversarial Review Report

**Agent**: Challenger 1 (Empirical Challenger)  
**Date**: 2026-07-24  
**Target File**: `test/empirical/stream_reactivity_stress_test.dart`  
**Command Executed**: `flutter test test/empirical/stream_reactivity_stress_test.dart`  
**Result**: 16/16 tests PASSED  

---

## Challenge Summary

**Overall Risk Assessment**: **MEDIUM**

While database operations, stream reactivity, mathematical boundary cases (up to 10M lectures), and 100 concurrent DB write operations are stable and free from deadlocks or database locking errors, an empirical bug was discovered in `dashboardSnapshotProvider`:
When total lectures count is `0`, `SafeBunkCalculator` returns `currentPercentage = 0.0`. `dashboardSnapshotProvider` compares `0.0 < 75.0` and flags a user with zero lectures as **`Critical (0%)`** attendance state instead of returning **`On Track`**.

---

## Empirical Findings & Uncovered Vulnerabilities

### Finding 1: Dashboard Attendance State Misclassification on Zero Lectures [Medium Risk]

- **Location**: `lib/features/dashboard/providers/dashboard_provider.dart` (Line 103-108)
- **Empirical Evidence**:
  - `SafeBunkCalculator.calculate(attended: 0, total: 0)` yields `currentPercentage: 0.0`, `safeBunks: 0`, `mustAttend: 0`.
  - `dashboardSnapshotProvider` evaluates:
    ```dart
    if (safeBunk.currentPercentage < safeBunk.targetPercentage) {
      attendanceState = 'Critical (${safeBunk.currentPercentage.toStringAsFixed(0)}%)';
    }
    ```
  - When `total == 0`, `0.0 < 75.0` evaluates to `true`, setting `attendanceState = 'Critical (0%)'`.
- **Blast Radius**: New users or users with no attendance records logged yet will see an alarming red/critical status on their dashboard home screen.
- **Recommended Fix**: Check if `safeBunk.total == 0` before checking `< targetPercentage`:
  ```dart
  if (safeBunk.total == 0) {
    attendanceState = 'On Track';
  } else if (safeBunk.currentPercentage < safeBunk.targetPercentage) {
    ...
  }
  ```

---

## Detailed Stress Test Results

| Test Category | Scenario | Expected Behavior | Actual Behavior | Result |
|---|---|---|---|---|
| **Stream Reactivity** | `assignmentsStreamProvider` Insert, Update, Soft-delete | Emit updated list on each DB modification | Emitted `[]`, `[1 pending]`, `[1 completed]`, `[]` | **PASS** |
| **Stream Reactivity** | `safeBunkStreamProvider` Attendance Insert (x4), Status Update to Absent, Soft-delete | Emit recalculated `SafeBunkResult` | Emitted `0/0`, `4/4 (100%)`, `3/4 (75%)`, `3/3 (100%)` | **PASS** |
| **Stream Reactivity** | `calendarEventsStreamProvider` Insert, Update Title, Soft-delete | Emit updated list on each DB modification | Emitted `[]`, `[Physics Lab]`, `[Advanced Physics Lab]`, `[]` | **PASS** |
| **Stream Reactivity** | `resourcesStreamProvider` Insert, Update, Soft-delete | Emit updated list on each DB modification | Emitted `[]`, `[Ch1]`, `[Updated Ch1]`, `[]` | **PASS** |
| **Stream Reactivity** | `userSettingsStreamProvider` Insert & Update Theme | Emit updated entity on DB modification | Emitted `null`, `dark`, `light` | **PASS** |
| **Stream Reactivity** | `dashboardSnapshotProvider` Async Multi-stream synthesis | Re-evaluate snapshot on underlying stream update | Dynamically updated snapshot with 1 lecture & 1 assignment due today | **PASS** |
| **SafeBunk Math** | 0 total lectures (0/0) | Handle 0 division gracefully without NaN/Infinity | Returned `currentPercentage: 0.0`, `safeBunks: 0`, `mustAttend: 0` | **PASS** |
| **SafeBunk Math** | 100% attendance (10/10, 100/100) | Calculate safe bunks correctly | `10/10` -> `3 safe bunks`, `100/100` -> `33 safe bunks` | **PASS** |
| **SafeBunk Math** | Exactly 75% target (3/4, 75/100) | `safeBunks: 0`, `mustAttend: 0` | `currentPercentage: 75.0%`, `safeBunks: 0`, `mustAttend: 0` | **PASS** |
| **SafeBunk Math** | < 75% attendance (50/100, 74/100) | Calculate exact required `mustAttend` count | `50/100` -> `mustAttend: 100`, `74/100` -> `mustAttend: 4` | **PASS** |
| **SafeBunk Math** | Custom Target Percentages (85%, 60%) | Adapt `mustAttend` and `safeBunks` to target | `80/100 @ 85%` -> `mustAttend: 34`, `80/100 @ 60%` -> `safeBunks: 33` | **PASS** |
| **SafeBunk Math** | 10 Million Lectures (8M/10M) | No integer/double overflow | Returned `currentPercentage: 80.0%`, `safeBunks: 666666` | **PASS** |
| **Dashboard Synthesis** | Empty database state | Synthesize snapshot with default labels | Produced `0 lectures today`, `Manageable`, `All clear` | **PASS** |
| **Dashboard Synthesis** | > 3 pending assignments | Set workloadState to 'Heavy' | Produced `Heavy`, `5 Due Today` | **PASS** |
| **Dashboard Synthesis** | < 75% attendance | Set attendanceState to 'Critical (X%)' | Produced `Critical (25%)` | **PASS** |
| **Rapid Concurrency** | 100 parallel DB operations across 5 tables | Complete without deadlock, locking errors, or state corruption | All 100 async operations completed; final table counts = 20 each | **PASS** |

---

## Verification Commands Executed

```bash
flutter test test/empirical/stream_reactivity_stress_test.dart
```

**Output**:
```text
00:00 +16: All tests passed!
```
