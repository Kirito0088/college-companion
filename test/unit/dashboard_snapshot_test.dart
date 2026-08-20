import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardSnapshot Unit Tests', () {
    test('empty returns correct initial state model data', () {
      final snapshot = DashboardSnapshot.empty();
      expect(snapshot.greetingContext, equals('0 lectures today'));
      expect(snapshot.nextAction, isNull);
      expect(snapshot.timelineEvents, isEmpty);
      expect(snapshot.academicSnapshot.attendanceState, equals('No Data'));
    });
  });
}
