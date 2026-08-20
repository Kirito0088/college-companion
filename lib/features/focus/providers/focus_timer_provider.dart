import 'dart:async';

import 'package:college_companion/features/focus/models/focus_timer_state.dart';
import 'package:college_companion/features/focus/repositories/focus_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepository();
});

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  FocusTimerNotifier(this._repository) : super(const FocusTimerState()) {
    _init();
  }

  final FocusRepository _repository;
  Timer? _timer;
  FocusTimerStatus _prePauseStatus = FocusTimerStatus.running;

  Future<void> _init() async {
    final history = await _repository.loadSessions();
    final dndEnabled = await _repository.loadDndSetting();

    // Calculate completed sessions today from history
    final now = DateTime.now();
    final todaySessions = history.where((s) {
      return s.completedAt.year == now.year &&
          s.completedAt.month == now.month &&
          s.completedAt.day == now.day;
    }).length;

    state = state.copyWith(
      history: history,
      dndEnabled: dndEnabled,
      completedSessionsToday: todaySessions,
    );
  }

  void start() {
    if (state.status == FocusTimerStatus.running ||
        state.status == FocusTimerStatus.breakMode) {
      return;
    }

    final newStatus = state.status == FocusTimerStatus.paused
        ? _prePauseStatus
        : FocusTimerStatus.running;

    state = state.copyWith(status: newStatus);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void pause() {
    if (state.status == FocusTimerStatus.running ||
        state.status == FocusTimerStatus.breakMode) {
      _prePauseStatus = state.status;
      _timer?.cancel();
      state = state.copyWith(status: FocusTimerStatus.paused);
    }
  }

  void stop() {
    _timer?.cancel();
    final workSeconds = state.workDurationMinutes * 60;
    state = state.copyWith(
      status: FocusTimerStatus.idle,
      totalSeconds: workSeconds,
      remainingSeconds: workSeconds,
    );
  }

  void setPreset(
    String preset, {
    required int workMinutes,
    required int breakMinutes,
  }) {
    _timer?.cancel();
    final totalSecs = workMinutes * 60;
    state = state.copyWith(
      selectedPreset: preset,
      workDurationMinutes: workMinutes,
      breakDurationMinutes: breakMinutes,
      status: FocusTimerStatus.idle,
      totalSeconds: totalSecs,
      remainingSeconds: totalSecs,
    );
  }

  void toggleDnd(bool enabled) {
    state = state.copyWith(dndEnabled: enabled);
    _repository.saveDndSetting(enabled);
  }

  void setSubject(String subject) {
    state = state.copyWith(currentSubject: subject);
  }

  void clearAlertMessage() {
    state = state.copyWith(clearAlert: true);
  }

  void _onTick() {
    if (state.remainingSeconds > 1) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      _onTimerCompleted();
    }
  }

  Future<void> _onTimerCompleted() async {
    _timer?.cancel();

    if (state.status == FocusTimerStatus.running) {
      final session = FocusSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: state.currentSubject,
        durationMinutes: state.workDurationMinutes,
        completedAt: DateTime.now(),
      );

      await _repository.addSession(session);
      final updatedHistory = [session, ...state.history];

      final newCompletedSessions = state.completedSessionsToday + 1;
      final isLongBreak =
          newCompletedSessions > 0 && newCompletedSessions % 4 == 0;
      final breakMinutes = isLongBreak ? 15 : state.breakDurationMinutes;
      final breakSeconds = breakMinutes * 60;

      state = state.copyWith(
        status: FocusTimerStatus.breakMode,
        completedSessionsToday: newCompletedSessions,
        history: updatedHistory,
        totalSeconds: breakSeconds,
        remainingSeconds: breakSeconds,
        completionAlertMessage:
            'Focus session completed! Great job! Time for a $breakMinutes min break.',
      );

      _prePauseStatus = FocusTimerStatus.breakMode;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    } else if (state.status == FocusTimerStatus.breakMode) {
      final workSeconds = state.workDurationMinutes * 60;
      state = state.copyWith(
        status: FocusTimerStatus.idle,
        totalSeconds: workSeconds,
        remainingSeconds: workSeconds,
        completionAlertMessage:
            'Break completed! Ready to start your next focus session?',
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
      final repository = ref.watch(focusRepositoryProvider);
      return FocusTimerNotifier(repository);
    });
