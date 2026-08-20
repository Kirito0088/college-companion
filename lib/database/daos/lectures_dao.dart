/// Lectures DAO
///
/// Owns complex queries and joins for the `timetable` table with `subjects` (Phase 4 §4).
/// Never directly imported by UI widgets — accessed via repository layer.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:drift/drift.dart';

/// DAO providing joined queries between `timetable` and `subjects`.
class LecturesDao {
  /// Creates a [LecturesDao] bound to the given [database].
  LecturesDao(this._database);

  final AppDatabase _database;

  /// Watches timetable entries joined with subject data for a specific day of week (0 = Mon, ..., 6 = Sun).
  Stream<List<LectureScheduleItem>> watchLecturesForDay(
    String userId,
    int dayOfWeek, [
    DateTime? customNow,
  ]) {
    final query =
        _database.select(_database.timetable).join([
            innerJoin(
              _database.subjects,
              _database.subjects.id.equalsExp(_database.timetable.subjectId),
            ),
          ])
          ..where(
            _database.timetable.userId.equals(userId) &
                _database.timetable.dayOfWeek.equals(dayOfWeek) &
                _database.timetable.deletedAt.isNull() &
                _database.subjects.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.asc(_database.timetable.startTime)]);

    return query.watch().map((rows) {
      final now = customNow ?? DateTime.now();
      return rows.map((row) {
        final timetable = row.readTable(_database.timetable);
        final subject = row.readTable(_database.subjects);
        final isCurrent = _isLectureCurrent(
          timetable.dayOfWeek,
          timetable.startTime,
          timetable.endTime,
          now,
        );
        return LectureScheduleItem(
          id: timetable.id,
          userId: timetable.userId,
          subjectId: timetable.subjectId,
          subjectName: subject.name,
          faculty: subject.faculty,
          dayOfWeek: timetable.dayOfWeek,
          startTime: timetable.startTime,
          endTime: timetable.endTime,
          room: timetable.room,
          lectureType: timetable.lectureType,
          isCurrent: isCurrent,
        );
      }).toList();
    });
  }

  /// Watches all weekly timetable entries joined with subject data across the entire week.
  Stream<List<LectureScheduleItem>> watchAllWeeklyLectures(
    String userId, [
    DateTime? customNow,
  ]) {
    final query =
        _database.select(_database.timetable).join([
            innerJoin(
              _database.subjects,
              _database.subjects.id.equalsExp(_database.timetable.subjectId),
            ),
          ])
          ..where(
            _database.timetable.userId.equals(userId) &
                _database.timetable.deletedAt.isNull() &
                _database.subjects.deletedAt.isNull(),
          )
          ..orderBy([
            OrderingTerm.asc(_database.timetable.dayOfWeek),
            OrderingTerm.asc(_database.timetable.startTime),
          ]);

    return query.watch().map((rows) {
      final now = customNow ?? DateTime.now();
      return rows.map((row) {
        final timetable = row.readTable(_database.timetable);
        final subject = row.readTable(_database.subjects);
        final isCurrent = _isLectureCurrent(
          timetable.dayOfWeek,
          timetable.startTime,
          timetable.endTime,
          now,
        );
        return LectureScheduleItem(
          id: timetable.id,
          userId: timetable.userId,
          subjectId: timetable.subjectId,
          subjectName: subject.name,
          faculty: subject.faculty,
          dayOfWeek: timetable.dayOfWeek,
          startTime: timetable.startTime,
          endTime: timetable.endTime,
          room: timetable.room,
          lectureType: timetable.lectureType,
          isCurrent: isCurrent,
        );
      }).toList();
    });
  }

  static bool _isLectureCurrent(
    int dayOfWeek,
    String startTime,
    String endTime,
    DateTime now,
  ) {
    final currentDay = now.weekday - 1; // 0 = Mon, 6 = Sun
    if (dayOfWeek != currentDay) return false;

    final startMinutes = _parseToMinutes(startTime);
    final endMinutes = _parseToMinutes(endTime);
    if (startMinutes == null || endMinutes == null) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  static int? _parseToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.isEmpty) return null;
    final hour = int.tryParse(parts[0]);
    if (hour == null) return null;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return hour * 60 + minute;
  }
}
