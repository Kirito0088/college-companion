/// Attendance Repository — Derived Read-Model
///
/// Phase 4 §D2 / §6: Attendance is a **derived read-model only**.
/// Owns **no persistence** — no table, no `create()`/`update()`/`delete()`.
///
/// All attendance percentages, safe-bunk estimates, trends, dashboard
/// summaries, and analytics are computed from the immutable
/// `lecture_records` ledger via [LectureRecordDao] read streams.
///
/// The status→math policy (which statuses count toward attendance,
/// which are excluded from the denominator, etc.) lives here — business
/// logic outside widgets.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/lecture_record_dao.dart';
import 'package:college_companion/shared/models/lecture_status.dart';
import 'package:flutter/foundation.dart';

/// Computed attendance statistics for a subject (or overall).
@immutable
class AttendanceStats {
  const AttendanceStats({
    required this.totalLectures,
    required this.attended,
    required this.absent,
    required this.excluded,
    required this.percentage,
    this.thresholdPercentage = 75.0,
    this.lecturesCanSkip = 0,
    this.lecturesRemainingToSafeBunk = 0,
  });

  /// Total lectures tracked (denominator — present + absent counts).
  final int totalLectures;

  /// Lectures attended (present).
  final int attended;

  /// Lectures missed (absent — counts against attendance).
  final int absent;

  /// Lectures excluded from calculation (cancelled, holiday,
  /// faculty_absent).
  final int excluded;

  /// Attendance percentage (attended / totalLectures * 100).
  final double percentage;

  /// The minimum attendance threshold (default 75%).
  final double thresholdPercentage;

  /// Estimated lectures that can be safely skipped while staying above
  /// the threshold.
  final int lecturesCanSkip;

  /// Lectures remaining until the safe-bunk margin is used up.
  final int lecturesRemainingToSafeBunk;

  /// Whether the current attendance is above the threshold.
  bool get isAboveThreshold => percentage >= thresholdPercentage;

  @override
  String toString() =>
      'AttendanceStats($attended/$totalLectures=${percentage.toStringAsFixed(1)}%, '
      'skip=$lecturesCanSkip, excluded=$excluded)';
}

/// Read-model repository — derives attendance statistics from
/// `lecture_records`.
class AttendanceRepository {
  AttendanceRepository(this._dao);

  final LectureRecordDao _dao;

  // ── Status-counting policy (spec §5) ────────────────────────────────

  /// Statuses that count as "attended" — contribute to the numerator.
  static const _presentPrefixes = ['present'];

  /// Statuses that count as "missed" — reduce the numerator.
  static const _absentPrefixes = ['absent'];

  /// Statuses excluded from the denominator entirely (cancelled,
  /// holiday, faculty_absent). These are treated as if the lecture
  /// never happened for attendance-calculation purposes.
  static const _excludedPrefixes = ['cancelled'];

  /// Determines whether a lecture status counts toward attendance.
  static bool _countsAsAttended(LectureRecordEntity record) {
    final status = LectureStatus.decode(record.statusText);
    return _presentPrefixes.contains(status.primary) &&
        status.secondary != 'other';
  }

  /// Determines whether a lecture status counts as missed.
  static bool _countsAsAbsent(LectureRecordEntity record) {
    final status = LectureStatus.decode(record.statusText);
    return _absentPrefixes.contains(status.primary) &&
        status.secondary != 'holiday' &&
        status.secondary != 'faculty_absent';
  }

  /// Determines whether a lecture is excluded entirely from calculation.
  static bool _isExcluded(LectureRecordEntity record) {
    final status = LectureStatus.decode(record.statusText);
    if (_excludedPrefixes.contains(status.primary)) return true;
    if (status.secondary == 'holiday' || status.secondary == 'faculty_absent')
      return true;
    return false;
  }

  // ── Public computed streams ──────────────────────────────────────────

  /// Computes attendance statistics for a specific subject as a reactive
  /// stream — updates whenever new lecture_records arrive.
  Stream<AttendanceStats> watchSubjectStats(String userId, String subjectId) {
    return _dao
        .watchAll(userId)
        .map((records) => _computeStats(records, subjectId));
  }

  /// Computes attendance statistics across all subjects.
  Stream<AttendanceStats> watchOverallStats(String userId) {
    return _dao.watchAll(userId).map((records) => _computeStats(records, null));
  }

  /// Computes stats once (one-shot fetch).
  Future<AttendanceStats> getSubjectStats(
    String userId,
    String subjectId,
  ) async {
    final records = await _dao.getAll(userId);
    return _computeStats(records, subjectId);
  }

  /// Fetches the attendance trend as a list of daily attendance counts.
  /// Returns pairs of (date, presentCount, absentCount) ordered by date.
  Future<List<({String date, int present, int absent})>> getTrend(
    String userId,
    String subjectId,
  ) async {
    final records = await _dao.getByStatusPrefix(userId, subjectId, 'present');
    final absentRecords = await _dao.getByStatusPrefix(
      userId,
      subjectId,
      'absent',
    );

    // Group by date (recordedAt date part).
    final Map<String, Map<String, int>> byDate = {};
    for (final r in records) {
      final dateKey = _dateKey(r.recordedAt);
      byDate.putIfAbsent(dateKey, () => {'present': 0, 'absent': 0});
      if (_countsAsAttended(r)) {
        byDate[dateKey]!['present'] = byDate[dateKey]!['present']! + 1;
      }
    }
    for (final r in absentRecords) {
      final dateKey = _dateKey(r.recordedAt);
      byDate.putIfAbsent(dateKey, () => {'present': 0, 'absent': 0});
      if (_countsAsAbsent(r)) {
        byDate[dateKey]!['absent'] = byDate[dateKey]!['absent']! + 1;
      }
    }

    final sortedDates = byDate.keys.toList()..sort();
    return sortedDates.map((d) {
      final counts = byDate[d]!;
      return (date: d, present: counts['present']!, absent: counts['absent']!);
    }).toList();
  }

  // ── Core computation ────────────────────────────────────────────────

  AttendanceStats _computeStats(
    List<LectureRecordEntity> records,
    String? subjectId,
  ) {
    final filtered = subjectId != null
        ? records.where((r) => r.subjectId == subjectId).toList()
        : records;

    int attended = 0;
    int absent = 0;
    int excluded = 0;

    for (final r in filtered) {
      if (_isExcluded(r)) {
        excluded++;
        continue;
      }
      if (_countsAsAttended(r)) {
        attended++;
      } else if (_countsAsAbsent(r)) {
        absent++;
      }
      // Any other status (e.g., present|other) falls through
      // uncounted — conservatively excluded from both numerator
      // and denominator.
    }

    final total = attended + absent;
    final percentage = total > 0 ? (attended / total) * 100.0 : 100.0;
    const threshold = 75.0;

    // Safe-bunk: how many lectures can be skipped while staying above
    // the threshold. Formula: floor((attended / threshold * 100) - total)
    // — but capped at 0 if no lectures.
    int canSkip = 0;
    int remaining = 0;
    if (total > 0) {
      // Minimum attended needed: ceil(total * threshold / 100)
      final minAttended = (total * threshold / 100.0).ceil();
      canSkip = attended - minAttended;
      if (canSkip < 0) canSkip = 0;
      // Lectures remaining to safe-bunk: how many more can be skipped
      // within the threshold. This is the same as canSkip.
      remaining = canSkip;
    }

    return AttendanceStats(
      totalLectures: total,
      attended: attended,
      absent: absent,
      excluded: excluded,
      percentage: percentage,
      thresholdPercentage: threshold,
      lecturesCanSkip: canSkip,
      lecturesRemainingToSafeBunk: remaining,
    );
  }

  /// Extracts a YYYY-MM-DD key from a DateTime for grouping by day.
  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
