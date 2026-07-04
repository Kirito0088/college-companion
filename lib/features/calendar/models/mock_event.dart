import 'package:college_companion/theme/color_tokens.dart';
import 'package:flutter/material.dart';

enum EventType { academic, assignment, exam, personal }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.academic:
        return 'Academic';
      case EventType.assignment:
        return 'Assignment';
      case EventType.exam:
        return 'Exam';
      case EventType.personal:
        return 'Personal';
    }
  }

  Color get color {
    switch (this) {
      case EventType.academic:
        return ColorTokens.primary;
      case EventType.assignment:
        return ColorTokens.secondary;
      case EventType.exam:
        return ColorTokens.error;
      case EventType.personal:
        return ColorTokens.tertiary;
    }
  }
}

class MockEvent {
  const MockEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.time,
    this.subject,
    this.location,
    this.notes,
  });

  final String id;
  final String title;
  final EventType type;
  final DateTime date;
  final String? time;
  final String? subject;
  final String? location;
  final String? notes;
}
