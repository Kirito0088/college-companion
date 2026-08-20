## 2026-07-24T14:09:52Z
<USER_REQUEST>
You are Worker 4. Your task is to fix the empirical edge case bug identified by Challenger 1 in `c:\Projects\college_companion`.
Your working directory is `c:\Projects\college_companion\.agents\worker_4`. Create your directory and files there.

DO NOT CHEAT. All implementations must be genuine.

Task Details:
1. Inspect `lib/features/dashboard/providers/dashboard_provider.dart` around lines 346–352 (Academic Snapshot computation):
   - Currently:
     ```dart
     String attendanceState = 'On Track';
     if (safeBunk.currentPercentage < safeBunk.targetPercentage) {
       attendanceState = 'Critical (${safeBunk.currentPercentage.toStringAsFixed(0)}%)';
     } else if (safeBunk.safeBunks > 0) {
       attendanceState = '${safeBunk.safeBunks} Safe Bunks';
     }
     ```
   - Change to:
     ```dart
     String attendanceState = 'On Track';
     if (safeBunk.total == 0) {
       attendanceState = 'No Data';
     } else if (safeBunk.currentPercentage < safeBunk.targetPercentage) {
       attendanceState = 'Critical (${safeBunk.currentPercentage.toStringAsFixed(0)}%)';
     } else if (safeBunk.safeBunks > 0) {
       attendanceState = '${safeBunk.safeBunks} Safe Bunks';
     }
     ```
2. Update unit tests in `test/unit/restored_stream_providers_test.dart` and `test/empirical/stream_reactivity_stress_test.dart` if needed to expect `'No Data'` when total lectures = 0.
3. Run `dart analyze lib test` using `run_command` in `c:\Projects\college_companion` to confirm 0 errors and 0 warnings.
4. Run `flutter test` using `run_command` in `c:\Projects\college_companion` to confirm 100% pass rate.
5. Document your fix in `c:\Projects\college_companion\.agents\worker_4\changes.md` and `c:\Projects\college_companion\.agents\worker_4\handoff.md`.
6. Send your report back to parent using `send_message`.
</USER_REQUEST>
