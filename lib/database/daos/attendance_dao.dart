/// Attendance DAO
///
/// Owns queries and operations for the `attendance` table.
/// Layer 2 DAO: Provides read queries and aggregations.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Aggregated attendance summary for a subject.
class SubjectAttendanceSummary {
  const SubjectAttendanceSummary({
    required this.totalLectures,
    required this.presentCount,
    required this.absentCount,
    required this.cancelledCount,
  });

  final int totalLectures;
  final int presentCount;
  final int absentCount;
  final int cancelledCount;

  /// Total lectures actually conducted (present + absent).
  int get heldLectures => presentCount + absentCount;

  /// Attendance percentage over conducted lectures.
  double get percentage =>
      heldLectures > 0 ? (presentCount / heldLectures) * 100.0 : 0.0;
}

/// DAO providing specialized queries and aggregations for attendance records.
class AttendanceDao {
  AttendanceDao(this._database);

  final AppDatabase _database;

  /// Watches all non-deleted attendance records for a specific subject,
  /// ordered chronologically (most recent first).
  Stream<List<AttendanceEntity>> watchAttendanceForSubject(
    String subjectId, {
    String? userId,
  }) {
    return (_database.select(_database.attendance)
          ..where((t) {
            var predicate =
                t.subjectId.equals(subjectId) & t.deletedAt.isNull();
            if (userId != null) {
              predicate = predicate & t.userId.equals(userId);
            }
            return predicate;
          })
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// Fetches non-deleted attendance records for a subject as a one-time query.
  Future<List<AttendanceEntity>> getAttendanceForSubject(
    String subjectId, {
    String? userId,
  }) {
    return (_database.select(_database.attendance)
          ..where((t) {
            var predicate =
                t.subjectId.equals(subjectId) & t.deletedAt.isNull();
            if (userId != null) {
              predicate = predicate & t.userId.equals(userId);
            }
            return predicate;
          })
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  /// Watches aggregated attendance metrics for a subject.
  Stream<SubjectAttendanceSummary> watchSubjectSummary(
    String subjectId, {
    String? userId,
  }) {
    return watchAttendanceForSubject(subjectId, userId: userId).map((records) {
      int present = 0;
      int absent = 0;
      int cancelled = 0;

      for (final record in records) {
        switch (record.primaryStatus) {
          case 'present':
            present++;
            break;
          case 'absent':
            absent++;
            break;
          case 'cancelled':
            cancelled++;
            break;
        }
      }

      return SubjectAttendanceSummary(
        totalLectures: records.length,
        presentCount: present,
        absentCount: absent,
        cancelledCount: cancelled,
      );
    });
  }

  /// Inserts a new attendance record and returns its ID.
  Future<String> createAttendance(AttendanceCompanion data) {
    return _database
        .into(_database.attendance)
        .insertReturning(data)
        .then((r) => r.id);
  }

  /// Updates an existing attendance record by ID.
  Future<void> updateAttendance(
    String userId,
    String id,
    AttendanceCompanion data,
  ) {
    return (_database.update(
      _database.attendance,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
  }

  /// Soft deletes an attendance record by setting `deletedAt`.
  Future<void> deleteAttendance(String userId, String id) {
    final now = DateTime.now().toUtc().toIso8601String();
    return (_database.update(_database.attendance)
          ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
        .write(AttendanceCompanion(deletedAt: Value(now)));
  }
}
