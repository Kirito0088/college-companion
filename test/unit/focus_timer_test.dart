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

  group('FocusTimerState history statistics (#36)', () {
    final now = DateTime(2026, 10, 2, 15);
    FocusSession at(DateTime when, {int minutes = 25}) => FocusSession(
      id: '${when.millisecondsSinceEpoch}',
      subject: 'Focus',
      durationMinutes: minutes,
      completedAt: when,
    );

    test('empty history means a zero streak and no focus time', () {
      const state = FocusTimerState();
      expect(state.streakDays(now: now), 0);
      expect(state.focusMinutesToday(now: now), 0);
    });

    test('streak counts consecutive days ending today', () {
      final state = FocusTimerState(
        history: [
          at(DateTime(2026, 10, 2, 9)),
          at(DateTime(2026, 10, 2, 11)),
          at(DateTime(2026, 10, 1, 20)),
          at(DateTime(2026, 9, 29, 8)), // gap on Sep 30 ends the run
        ],
      );
      expect(state.streakDays(now: now), 2);
    });

    test('a streak ending yesterday is still alive before the first '
        'session today', () {
      final state = FocusTimerState(
        history: [at(DateTime(2026, 10, 1, 9)), at(DateTime(2026, 9, 30, 9))],
      );
      expect(state.streakDays(now: now), 2);
    });

    test('a streak that ended before yesterday is broken', () {
      final state = FocusTimerState(history: [at(DateTime(2026, 9, 30, 9))]);
      expect(state.streakDays(now: now), 0);
    });

    test('focus time counts only sessions completed today', () {
      final state = FocusTimerState(
        history: [
          at(DateTime(2026, 10, 2, 9), minutes: 25),
          at(DateTime(2026, 10, 2, 11), minutes: 45),
          at(DateTime(2026, 10, 1, 20), minutes: 60),
        ],
      );
      expect(state.focusMinutesToday(now: now), 70);
    });
  });

  group('FocusRepository Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('a fresh install has no session history (#36)', () async {
      final repo = FocusRepository();
      final history = await repo.loadSessions();
      expect(history, isEmpty);

      // Nothing synthetic may be written back either.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('focus_session_history'), isNull);
    });

    test('purges the three sessions earlier builds seeded, keeping real '
        'ones (#36)', () async {
      FocusSession session(String id, String subject) => FocusSession(
        id: id,
        subject: subject,
        durationMinutes: 25,
        completedAt: DateTime(2026, 9, 30, 10),
      );
      final repo = FocusRepository();
      await repo.saveSessions([
        session('1759222800000', 'Compiler Design'),
        session('sess_1', 'Mathematics'),
        session('sess_2', 'Operating Systems'),
        session('sess_3', 'DBMS Revision'),
      ]);

      final history = await repo.loadSessions();
      expect(history.map((s) => s.id), ['1759222800000']);

      // The purge is persisted, not just filtered on read.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('focus_session_history'), hasLength(1));
    });

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
