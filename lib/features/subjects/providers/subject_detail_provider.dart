/// Subject Detail Provider
///
/// Riverpod providers and state management for the dynamic Subject Details screen.
/// Computes bunk safety metrics and manages attendance log timeline filtering and mutations.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/attendance/services/bunk_calculator.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Filter selection for attendance timeline records.
enum AttendanceFilter { all, present, absent, cancelled }

/// State representation for the Subject Details screen.
class SubjectDetailState {
  const SubjectDetailState({
    this.subject,
    this.allRecords = const [],
    this.selectedFilter = AttendanceFilter.all,
    required this.bunkMetrics,
    this.isLoading = false,
    this.errorMessage,
  });

  final SubjectEntity? subject;
  final List<AttendanceEntity> allRecords;
  final AttendanceFilter selectedFilter;
  final BunkCalculationResult bunkMetrics;
  final bool isLoading;
  final String? errorMessage;

  /// Returns records filtered by [selectedFilter].
  List<AttendanceEntity> get filteredRecords {
    switch (selectedFilter) {
      case AttendanceFilter.all:
        return allRecords;
      case AttendanceFilter.present:
        return allRecords.where((r) => r.primaryStatus == 'present').toList();
      case AttendanceFilter.absent:
        return allRecords.where((r) => r.primaryStatus == 'absent').toList();
      case AttendanceFilter.cancelled:
        return allRecords.where((r) => r.primaryStatus == 'cancelled').toList();
    }
  }

  int get presentCount =>
      allRecords.where((r) => r.primaryStatus == 'present').length;
  int get absentCount =>
      allRecords.where((r) => r.primaryStatus == 'absent').length;
  int get cancelledCount =>
      allRecords.where((r) => r.primaryStatus == 'cancelled').length;
  int get totalHeld => presentCount + absentCount;

  SubjectDetailState copyWith({
    SubjectEntity? subject,
    List<AttendanceEntity>? allRecords,
    AttendanceFilter? selectedFilter,
    BunkCalculationResult? bunkMetrics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubjectDetailState(
      subject: subject ?? this.subject,
      allRecords: allRecords ?? this.allRecords,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      bunkMetrics: bunkMetrics ?? this.bunkMetrics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Parameters for querying subject details state.
typedef SubjectParams = ({String userId, String subjectId});

/// Watches subject entity by [userId] and [subjectId].
final subjectByIdStreamProvider =
    StreamProvider.family<SubjectEntity?, SubjectParams>((ref, params) {
      final repo = ref.watch(subjectRepositoryProvider);
      return repo.watchById(params.userId, params.subjectId);
    });

/// Watches attendance records for subject by [userId] and [subjectId].
final attendanceBySubjectStreamProvider =
    StreamProvider.family<List<AttendanceEntity>, SubjectParams>((ref, params) {
      final repo = ref.watch(attendanceRepositoryProvider);
      return repo.watchBySubject(params.userId, params.subjectId);
    });

/// Active attendance filter state for a subject screen.
final attendanceFilterProvider = StateProvider.family<AttendanceFilter, String>(
  (ref, subjectId) {
    return AttendanceFilter.all;
  },
);

/// Combined state provider for Subject Details screen.
final subjectDetailProvider =
    Provider.family<AsyncValue<SubjectDetailState>, SubjectParams>((
      ref,
      params,
    ) {
      final subjectAsync = ref.watch(subjectByIdStreamProvider(params));
      final recordsAsync = ref.watch(attendanceBySubjectStreamProvider(params));
      final selectedFilter = ref.watch(
        attendanceFilterProvider(params.subjectId),
      );

      if (subjectAsync.isLoading || recordsAsync.isLoading) {
        return const AsyncLoading();
      }

      if (subjectAsync.hasError) {
        return AsyncError(subjectAsync.error!, subjectAsync.stackTrace!);
      }
      if (recordsAsync.hasError) {
        return AsyncError(recordsAsync.error!, recordsAsync.stackTrace!);
      }

      final subject = subjectAsync.value;
      final records = recordsAsync.value ?? [];

      final present = records.where((r) => r.primaryStatus == 'present').length;
      final absent = records.where((r) => r.primaryStatus == 'absent').length;
      final totalHeld = present + absent;

      final bunkMetrics = BunkCalculator.calculate(
        attended: present,
        total: totalHeld,
      );

      return AsyncData(
        SubjectDetailState(
          subject: subject,
          allRecords: records,
          selectedFilter: selectedFilter,
          bunkMetrics: bunkMetrics,
        ),
      );
    });

/// Controller providing mutation actions for attendance records in subject details.
class SubjectDetailController {
  SubjectDetailController({
    required this.attendanceRepository,
    required this.userId,
    required this.subjectId,
  });

  final AttendanceRepository attendanceRepository;
  final String userId;
  final String subjectId;

  /// Records a new attendance entry.
  Future<String> markAttendance({
    required String status,
    DateTime? date,
    String lectureType = 'theory',
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final effectiveDate = date ?? DateTime.now();
    final y = effectiveDate.year.toString().padLeft(4, '0');
    final m = effectiveDate.month.toString().padLeft(2, '0');
    final d = effectiveDate.day.toString().padLeft(2, '0');
    final dateStr = '$y-$m-$d';

    final companion = AttendanceCompanion.insert(
      id: const Uuid().v4(),
      userId: userId,
      subjectId: subjectId,
      date: dateStr,
      primaryStatus: status,
      lectureType: lectureType,
      notes: Value(notes),
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

    return await attendanceRepository.create(companion);
  }

  /// Updates an existing attendance record.
  Future<void> updateAttendance({
    required String id,
    required String status,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final companion = AttendanceCompanion(
      primaryStatus: Value(status),
      notes: Value(notes),
      updatedAt: Value(now.toIso8601String()),
    );
    await attendanceRepository.update(userId, id, companion);
  }

  /// Deletes an attendance record.
  Future<void> deleteAttendance(String id) async {
    await attendanceRepository.delete(userId, id);
  }
}

/// Provider for subject detail actions controller.
final subjectDetailControllerProvider =
    Provider.family<SubjectDetailController, SubjectParams>((ref, params) {
      final attendanceRepo = ref.watch(attendanceRepositoryProvider);
      return SubjectDetailController(
        attendanceRepository: attendanceRepo,
        userId: params.userId,
        subjectId: params.subjectId,
      );
    });
