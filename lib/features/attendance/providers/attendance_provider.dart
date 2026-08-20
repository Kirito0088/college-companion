/// Attendance Providers
///
/// Riverpod providers for attendance-related dependencies.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/attendance_dao.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [AttendanceDao] instance.
final attendanceDaoProvider = Provider<AttendanceDao>((ref) {
  final database = ref.watch(databaseProvider);
  return AttendanceDao(database);
});

/// Provides the [AttendanceRepository] instance.
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return AttendanceRepository(database, syncQueueRepository);
});

/// Result of a safe bunk calculation.
class SafeBunkResult {
  const SafeBunkResult({
    required this.attended,
    required this.total,
    required this.targetPercentage,
    required this.currentPercentage,
    required this.safeBunks,
    required this.mustAttend,
  });

  final int attended;
  final int total;
  final double targetPercentage;
  final double currentPercentage;
  final int safeBunks;
  final int mustAttend;
}

/// Helper utility for safe bunk calculations.
class SafeBunkCalculator {
  static SafeBunkResult calculate({
    required int attended,
    required int total,
    double targetPercentage = 75.0,
  }) {
    if (total <= 0) {
      return SafeBunkResult(
        attended: attended,
        total: total,
        targetPercentage: targetPercentage,
        currentPercentage: 0.0,
        safeBunks: 0,
        mustAttend: 0,
      );
    }

    final currentPct = (attended / total) * 100.0;
    if (currentPct >= targetPercentage) {
      final maxBunks =
          ((attended * 100.0 - targetPercentage * total) / targetPercentage)
              .floor();
      return SafeBunkResult(
        attended: attended,
        total: total,
        targetPercentage: targetPercentage,
        currentPercentage: currentPct,
        safeBunks: maxBunks < 0 ? 0 : maxBunks,
        mustAttend: 0,
      );
    } else {
      final needed =
          ((targetPercentage * total - 100.0 * attended) /
                  (100.0 - targetPercentage))
              .ceil();
      return SafeBunkResult(
        attended: attended,
        total: total,
        targetPercentage: targetPercentage,
        currentPercentage: currentPct,
        safeBunks: 0,
        mustAttend: needed < 0 ? 0 : needed,
      );
    }
  }
}

/// Stream provider for user attendance safe bunk calculation.
final safeBunkStreamProvider = StreamProvider.family<SafeBunkResult, String>((
  ref,
  userId,
) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.watchAll(userId).map((list) {
    int attended = 0;
    int total = 0;
    for (final record in list) {
      if (record.primaryStatus == 'present') {
        attended++;
        total++;
      } else if (record.primaryStatus == 'absent') {
        total++;
      }
    }
    return SafeBunkCalculator.calculate(attended: attended, total: total);
  });
});

/// Represents aggregated attendance insights across all subjects.
class AttendanceInsights {
  const AttendanceInsights({
    required this.highestSubject,
    required this.lowestSubject,
    required this.highestPercentage,
    required this.lowestPercentage,
    required this.subjectsBelowTarget,
    required this.averagePercentage,
  });

  final String highestSubject;
  final String lowestSubject;
  final double highestPercentage;
  final double lowestPercentage;
  final int subjectsBelowTarget;
  final double averagePercentage;
}

/// Watches all non-deleted attendance records for a user.
final attendanceRecordsStreamProvider =
    StreamProvider.family<List<AttendanceEntity>, String>((ref, userId) {
      final repo = ref.watch(attendanceRepositoryProvider);
      return repo.watchAll(userId);
    });

/// Computes attendance insights based on records and subjects.
final attendanceInsightsProvider =
    Provider.family<AsyncValue<AttendanceInsights>, String>((ref, userId) {
      final subjectsAsync = ref.watch(subjectsStreamProvider(userId));
      final recordsAsync = ref.watch(attendanceRecordsStreamProvider(userId));

      if (subjectsAsync.isLoading || recordsAsync.isLoading) {
        return const AsyncLoading();
      }

      if (subjectsAsync.hasError) {
        return AsyncError(subjectsAsync.error!, subjectsAsync.stackTrace!);
      }
      if (recordsAsync.hasError) {
        return AsyncError(recordsAsync.error!, recordsAsync.stackTrace!);
      }

      final subjects = subjectsAsync.value ?? [];
      final records = recordsAsync.value ?? [];

      if (subjects.isEmpty) {
        return const AsyncData(
          AttendanceInsights(
            highestSubject: 'N/A',
            lowestSubject: 'N/A',
            highestPercentage: 0.0,
            lowestPercentage: 0.0,
            subjectsBelowTarget: 0,
            averagePercentage: 0.0,
          ),
        );
      }

      String highestSubject = 'N/A';
      String lowestSubject = 'N/A';
      double highestPercentage = -1.0;
      double lowestPercentage = 101.0;
      int subjectsBelowTarget = 0;
      double totalPercentage = 0.0;

      for (final subject in subjects) {
        final subjRecords = records
            .where((r) => r.subjectId == subject.id)
            .toList();
        final present = subjRecords
            .where((x) => x.primaryStatus == 'present')
            .length;
        final total = subjRecords.length;

        final pct = total > 0 ? (present / total) * 100 : 0.0;
        if (pct > highestPercentage) {
          highestPercentage = pct;
          highestSubject = subject.name;
        }
        if (pct < lowestPercentage) {
          lowestPercentage = pct;
          lowestSubject = subject.name;
        }
        if (pct < 75.0) {
          subjectsBelowTarget++;
        }
        totalPercentage += pct;
      }

      return AsyncData(
        AttendanceInsights(
          highestSubject: highestSubject,
          lowestSubject: lowestSubject,
          highestPercentage: highestPercentage == -1.0
              ? 0.0
              : highestPercentage,
          lowestPercentage: lowestPercentage == 101.0 ? 0.0 : lowestPercentage,
          subjectsBelowTarget: subjectsBelowTarget,
          averagePercentage: subjects.isNotEmpty
              ? totalPercentage / subjects.length
              : 0.0,
        ),
      );
    });
