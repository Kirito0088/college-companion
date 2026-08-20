/// Domain model representing a scheduled lecture item in the timetable.
library;

import 'package:flutter/foundation.dart';

/// Presentation/Domain model for a timetable slot joined with subject data.
@immutable
class LectureScheduleItem {
  /// Creates a [LectureScheduleItem].
  const LectureScheduleItem({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    this.faculty,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.lectureType = 'theory',
    this.isCurrent = false,
  });

  /// Unique identifier of the timetable slot.
  final String id;

  /// Denormalized user ID owning this timetable slot.
  final String userId;

  /// Foreign key referencing the subject.
  final String subjectId;

  /// Resolved subject name (from joined subjects table).
  final String subjectName;

  /// Faculty / Professor name (from joined subjects table or override).
  final String? faculty;

  /// ISO 8601 day of week: 0 = Monday ... 6 = Sunday.
  final int dayOfWeek;

  /// Start time in format HH:MM:SS or HH:MM.
  final String startTime;

  /// End time in format HH:MM:SS or HH:MM.
  final String endTime;

  /// Classroom, hall, or lab identifier.
  final String? room;

  /// Type of lecture: 'theory', 'practical', or 'tutorial'.
  final String lectureType;

  /// Whether this lecture is currently ongoing right now.
  final bool isCurrent;

  /// Formats time string (e.g., "09:00:00" or "09:00") to human-readable 12-hour format (e.g. "9:00 AM").
  static String formatTimeSlot(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.isEmpty) return timeStr;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  /// Formatted time range string (e.g., "9:00 AM - 10:00 AM").
  String get formattedTimeRange =>
      '${formatTimeSlot(startTime)} - ${formatTimeSlot(endTime)}';

  /// Returns full weekday name.
  String get dayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (dayOfWeek >= 0 && dayOfWeek < days.length) {
      return days[dayOfWeek];
    }
    return 'Day $dayOfWeek';
  }

  /// Returns short weekday abbreviation.
  String get dayShortName {
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (dayOfWeek >= 0 && dayOfWeek < shortDays.length) {
      return shortDays[dayOfWeek];
    }
    return 'D$dayOfWeek';
  }

  /// Creates a copy of this [LectureScheduleItem] with specified fields replaced.
  LectureScheduleItem copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? subjectName,
    String? faculty,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? lectureType,
    bool? isCurrent,
  }) {
    return LectureScheduleItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      faculty: faculty ?? this.faculty,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      lectureType: lectureType ?? this.lectureType,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LectureScheduleItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          subjectId == other.subjectId &&
          subjectName == other.subjectName &&
          faculty == other.faculty &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          room == other.room &&
          lectureType == other.lectureType &&
          isCurrent == other.isCurrent;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      subjectId.hashCode ^
      subjectName.hashCode ^
      faculty.hashCode ^
      dayOfWeek.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      room.hashCode ^
      lectureType.hashCode ^
      isCurrent.hashCode;
}
