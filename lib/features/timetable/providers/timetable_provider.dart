/// Timetable Providers
///
/// Riverpod providers for timetable-related state and reactive streams.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [TimetableRepository] instance.
final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return TimetableRepository(database, syncQueueRepository);
});

/// Holds the currently selected day of the week (0 = Monday, ..., 6 = Sunday).
/// Defaults to the current day of the week.
final selectedDayProvider = StateProvider<int>((ref) {
  final now = DateTime.now();
  return (now.weekday - 1).clamp(0, 6);
});

/// Watches scheduled lectures for a given day of the week (0 = Monday, ..., 6 = Sunday)
/// for the currently authenticated user.
final timetableForDayProvider =
    StreamProvider.family<List<LectureScheduleItem>, int>((ref, dayOfWeek) {
      final authState = ref.watch(authStateProvider);
      final userId = authState is AuthAuthenticated ? authState.user.uid : '';
      if (userId.isEmpty) {
        return Stream.value(const <LectureScheduleItem>[]);
      }

      final repo = ref.watch(timetableRepositoryProvider);
      return repo.watchLecturesForDay(userId, dayOfWeek);
    });

/// Watches scheduled lectures for today for the currently authenticated user.
final todayTimetableStreamProvider = StreamProvider<List<LectureScheduleItem>>((
  ref,
) {
  final now = DateTime.now();
  final todayOfWeek = (now.weekday - 1).clamp(0, 6);
  final authState = ref.watch(authStateProvider);
  final userId = authState is AuthAuthenticated ? authState.user.uid : '';
  if (userId.isEmpty) {
    return Stream.value(const <LectureScheduleItem>[]);
  }

  final repo = ref.watch(timetableRepositoryProvider);
  return repo.watchLecturesForDay(userId, todayOfWeek);
});

/// Watches all weekly scheduled lectures for the currently authenticated user.
final weeklyTimetableStreamProvider = StreamProvider<List<LectureScheduleItem>>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';
    if (userId.isEmpty) {
      return Stream.value(const <LectureScheduleItem>[]);
    }

    final repo = ref.watch(timetableRepositoryProvider);
    return repo.watchAllWeeklyLectures(userId);
  },
);

/// Watches a single timetable slot by ID for the currently authenticated
/// user (raw entry — subject fields are not joined; combine with
/// `subjectByIdStreamProvider`).
final timetableEntryByIdProvider =
    StreamProvider.family<TimetableEntryEntity?, String>((ref, timetableId) {
      final authState = ref.watch(authStateProvider);
      final userId = authState is AuthAuthenticated ? authState.user.uid : '';
      if (userId.isEmpty) {
        return Stream.value(null);
      }

      final repo = ref.watch(timetableRepositoryProvider);
      return repo.watchById(userId, timetableId);
    });
