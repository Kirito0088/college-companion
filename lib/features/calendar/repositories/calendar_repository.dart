/// Calendar Repository
///
/// Handles CRUD and query operations for calendar events.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for calendar event operations.
class CalendarRepository {
  /// Creates a [CalendarRepository] with the given [database] and optional [syncQueueRepository].
  CalendarRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted calendar events for the given user, ordered by start date.
  Stream<List<CalendarEventEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.calendarEvents)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch calendar events for user: $userId', e);
    }
  }

  /// Watches a single non-deleted calendar event by ID.
  Stream<CalendarEventEntity?> watchById(String userId, String id) {
    try {
      return (_database.select(_database.calendarEvents)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .watchSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to watch calendar event: $id', e);
    }
  }

  /// Gets a non-deleted calendar event by ID (one-time fetch).
  Future<CalendarEventEntity?> getById(String userId, String id) async {
    try {
      return await (_database.select(_database.calendarEvents)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseException('Failed to get calendar event: $id', e);
    }
  }

  /// Watches calendar events within a date range (inclusive).
  Stream<List<CalendarEventEntity>> watchByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    try {
      final startStr = start.toUtc().toIso8601String();
      final endStr = end.toUtc().toIso8601String();
      return (_database.select(_database.calendarEvents)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.deletedAt.isNull() &
                  t.startDate.isBetweenValues(startStr, endStr),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch calendar events by date range', e);
    }
  }

  /// Watches upcoming calendar events starting on or before [end].
  Stream<List<CalendarEventEntity>> watchUpcoming(
    String userId,
    DateTime end,
  ) {
    try {
      final endStr = end.toUtc().toIso8601String();
      return (_database.select(_database.calendarEvents)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.deletedAt.isNull() &
                  t.startDate.isSmallerOrEqualValue(endStr),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch upcoming calendar events', e);
    }
  }

  /// Creates a new calendar event. Returns the new row's ID.
  Future<String> create(CalendarEventsCompanion data) async {
    try {
      final result =
          await _database.into(_database.calendarEvents).insertReturning(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'calendar_events',
        recordId: result.id,
        operation: 'INSERT',
      );
      return result.id;
    } catch (e) {
      throw DatabaseException('Failed to create calendar event', e);
    }
  }

  /// Updates an existing calendar event.
  Future<void> update(
    String userId,
    String id,
    CalendarEventsCompanion data,
  ) async {
    try {
      await (_database.update(_database.calendarEvents)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(data);
      await _syncQueueRepository?.enqueue(
        targetTable: 'calendar_events',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to update calendar event: $id', e);
    }
  }

  /// Soft-deletes a calendar event.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(_database.calendarEvents)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            CalendarEventsCompanion(
              deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'calendar_events',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete calendar event: $id', e);
    }
  }
}
