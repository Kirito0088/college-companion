import 'package:college_companion/features/focus/models/focus_timer_state.dart';
import 'package:college_companion/features/focus/providers/focus_timer_provider.dart';
import 'package:college_companion/features/focus/repositories/focus_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FocusTimerState Tests', () {
    test('initial state formats time correctly as 25:00', () {
      const state = FocusTimerState();
      expect(state.formattedTime, equals('25:00'));
      expect(state.progress, equals(0.0));
      expect(state.status, equals(FocusTimerStatus.idle));
    });

    test('progress calculates correctly during timer tick', () {
      const state = FocusTimerState(totalSeconds: 100, remainingSeconds: 25);
      expect(state.progress, equals(0.75));
      expect(state.formattedTime, equals('00:25'));
    });
  });

  group('FocusRepository Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'loads default initial session history if preferences empty',
      () async {
        final repo = FocusRepository();
        final history = await repo.loadSessions();
        expect(history.length, equals(3));
        expect(history.first.subject, equals('Mathematics'));
      },
    );

    test('adds new session and persists to SharedPreferences', () async {
      final repo = FocusRepository();
      final newSession = FocusSession(
        id: 'test_123',
        subject: 'Compiler Design',
        durationMinutes: 30,
        completedAt: DateTime.now(),
      );

      await repo.addSession(newSession);
      final history = await repo.loadSessions();
      expect(history.first.subject, equals('Compiler Design'));
      expect(history.first.durationMinutes, equals(30));
    });
  });

  group('FocusTimerNotifier Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('start changes status to running and ticks timer', () async {
      final repo = FocusRepository();
      final notifier = FocusTimerNotifier(repo);

      expect(notifier.state.status, equals(FocusTimerStatus.idle));
      notifier.start();
      expect(notifier.state.status, equals(FocusTimerStatus.running));

      notifier.pause();
      expect(notifier.state.status, equals(FocusTimerStatus.paused));

      notifier.stop();
      expect(notifier.state.status, equals(FocusTimerStatus.idle));
      expect(notifier.state.remainingSeconds, equals(25 * 60));
    });

    test('setPreset updates work and break durations', () async {
      final repo = FocusRepository();
      final notifier = FocusTimerNotifier(repo);

      notifier.setPreset('45 min', workMinutes: 45, breakMinutes: 10);
      expect(notifier.state.selectedPreset, equals('45 min'));
      expect(notifier.state.workDurationMinutes, equals(45));
      expect(notifier.state.breakDurationMinutes, equals(10));
      expect(notifier.state.formattedTime, equals('45:00'));
    });
  });
}
