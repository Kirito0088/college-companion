import 'package:flutter/foundation.dart';

enum FocusTimerStatus { idle, running, paused, breakMode }

@immutable
class FocusSession {
  const FocusSession({
    required this.id,
    required this.subject,
    required this.durationMinutes,
    required this.completedAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'] as String,
    subject: json['subject'] as String,
    durationMinutes: json['durationMinutes'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
  final String id;
  final String subject;
  final int durationMinutes;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'durationMinutes': durationMinutes,
    'completedAt': completedAt.toIso8601String(),
  };
}

@immutable
class FocusTimerState {
  const FocusTimerState({
    this.status = FocusTimerStatus.idle,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.workDurationMinutes = 25,
    this.breakDurationMinutes = 5,
    this.completedSessionsToday = 0,
    this.selectedPreset = '25 min',
    this.currentSubject = 'General Focus',
    this.dndEnabled = true,
    this.history = const [],
    this.completionAlertMessage,
  });
  final FocusTimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int workDurationMinutes;
  final int breakDurationMinutes;
  final int completedSessionsToday;
  final String selectedPreset;
  final String currentSubject;
  final bool dndEnabled;
  final List<FocusSession> history;
  final String? completionAlertMessage;

  String get formattedTime {
    final mins = remainingSeconds ~/ 60;
    final secs = remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds <= 0) return 0.0;
    final elapsed = totalSeconds - remainingSeconds;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  bool get isRunning =>
      status == FocusTimerStatus.running ||
      status == FocusTimerStatus.breakMode;
  bool get isPaused => status == FocusTimerStatus.paused;
  bool get isBreak => status == FocusTimerStatus.breakMode;

  FocusTimerState copyWith({
    FocusTimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? workDurationMinutes,
    int? breakDurationMinutes,
    int? completedSessionsToday,
    String? selectedPreset,
    String? currentSubject,
    bool? dndEnabled,
    List<FocusSession>? history,
    String? completionAlertMessage,
    bool clearAlert = false,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      completedSessionsToday:
          completedSessionsToday ?? this.completedSessionsToday,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      currentSubject: currentSubject ?? this.currentSubject,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      history: history ?? this.history,
      completionAlertMessage: clearAlert
          ? null
          : (completionAlertMessage ?? this.completionAlertMessage),
    );
  }
}
