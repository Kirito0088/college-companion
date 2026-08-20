/// Calendar Providers
///
/// Riverpod providers for calendar-related dependencies and reactive streams.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/calendar/repositories/calendar_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [CalendarRepository] instance.
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return CalendarRepository(database, syncQueueRepository);
});

/// Watches all non-deleted calendar events for a user.
final calendarEventsStreamProvider =
    StreamProvider.family<List<CalendarEventEntity>, String>((ref, userId) {
      final repo = ref.watch(calendarRepositoryProvider);
      return repo.watchAll(userId);
    });
