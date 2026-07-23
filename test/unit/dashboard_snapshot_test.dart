import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardSnapshot Unit Tests', () {
    test('mockHeavyDay returns correct mock model data', () {
      final snapshot = DashboardSnapshot.mockHeavyDay();
      expect(snapshot.greetingContext, equals('4 lectures today'));
      expect(snapshot.nextAction?.title, equals('Statistics ML'));
      expect(snapshot.timelineEvents.length, greaterThan(0));
    });
  });
}
