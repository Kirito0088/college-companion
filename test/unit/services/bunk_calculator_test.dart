import 'package:college_companion/features/attendance/services/bunk_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BunkCalculator Unit Tests', () {
    test(
      'Edge Case: 0 classes held (0/0) results in 0% attendance, 0 safe bunks, 0 to attend, and onTrack status',
      () {
        final result = BunkCalculator.calculate(
          attended: 0,
          total: 0,
          targetPercentage: 75.0,
        );

        expect(result.attended, 0);
        expect(result.total, 0);
        expect(result.currentPercentage, 0.0);
        expect(result.targetPercentage, 75.0);
        expect(result.safeBunks, 0);
        expect(result.classesToAttend, 0);
        expect(result.status, AttendanceStatus.onTrack);
        expect(result.isSafe, isTrue);
      },
    );

    test(
      'Edge Case: 100% attendance (10/10 attended with 75% target) calculates 3 safe bunks and 0 to attend',
      () {
        final result = BunkCalculator.calculate(
          attended: 10,
          total: 10,
          targetPercentage: 75.0,
        );

        expect(result.attended, 10);
        expect(result.total, 10);
        expect(result.currentPercentage, 100.0);
        expect(result.safeBunks, 3);
        expect(result.classesToAttend, 0);
        expect(result.status, AttendanceStatus.onTrack);
        expect(result.isSafe, isTrue);
      },
    );

    test(
      'Edge Case: Exactly 75% attendance (6/8 attended with 75% target) calculates 0 safe bunks and 0 to attend',
      () {
        final result = BunkCalculator.calculate(
          attended: 6,
          total: 8,
          targetPercentage: 75.0,
        );

        expect(result.attended, 6);
        expect(result.total, 8);
        expect(result.currentPercentage, 75.0);
        expect(result.safeBunks, 0);
        expect(result.classesToAttend, 0);
        expect(result.status, AttendanceStatus.onTrack);
        expect(result.isSafe, isTrue);
      },
    );

    test(
      'Edge Case: Critical deficit (<50%, e.g. 4/10 attended with 75% target) calculates 14 classes to attend and critical status',
      () {
        final result = BunkCalculator.calculate(
          attended: 4,
          total: 10,
          targetPercentage: 75.0,
        );

        expect(result.attended, 4);
        expect(result.total, 10);
        expect(result.currentPercentage, 40.0);
        expect(result.safeBunks, 0);
        expect(result.classesToAttend, 14);
        expect(result.status, AttendanceStatus.critical);
        expect(result.isSafe, isFalse);
      },
    );

    test(
      'Warning deficit (50% to 74.9%, e.g. 6/10 attended with 75% target) calculates 6 classes to attend and warning status',
      () {
        final result = BunkCalculator.calculate(
          attended: 6,
          total: 10,
          targetPercentage: 75.0,
        );

        expect(result.attended, 6);
        expect(result.total, 10);
        expect(result.currentPercentage, 60.0);
        expect(result.safeBunks, 0);
        expect(result.classesToAttend, 6);
        expect(result.status, AttendanceStatus.warning);
        expect(result.isSafe, isFalse);
      },
    );

    test(
      'Custom target percentage (80% target) calculates safe bunks and recovery correctly',
      () {
        // 9/10 attended with 80% target -> 90%, 1 safe bunk (9/11 = 81.8%)
        final safeResult = BunkCalculator.calculate(
          attended: 9,
          total: 10,
          targetPercentage: 80.0,
        );
        expect(safeResult.safeBunks, 1);
        expect(safeResult.classesToAttend, 0);
        expect(safeResult.status, AttendanceStatus.onTrack);

        // 7/10 attended with 80% target -> 70%, 5 to attend (12/15 = 80%)
        final deficitResult = BunkCalculator.calculate(
          attended: 7,
          total: 10,
          targetPercentage: 80.0,
        );
        expect(deficitResult.safeBunks, 0);
        expect(deficitResult.classesToAttend, 5);
        expect(deficitResult.status, AttendanceStatus.warning);
      },
    );

    test(
      'Attendance status categories partition correctly based on thresholds',
      () {
        // >= 75%: onTrack
        expect(
          BunkCalculator.calculate(attended: 15, total: 20).status,
          AttendanceStatus.onTrack,
        );
        // 50% <= pct < 75%: warning
        expect(
          BunkCalculator.calculate(attended: 10, total: 20).status,
          AttendanceStatus.warning,
        );
        // < 50%: critical
        expect(
          BunkCalculator.calculate(attended: 9, total: 20).status,
          AttendanceStatus.critical,
        );
      },
    );
  });
}
