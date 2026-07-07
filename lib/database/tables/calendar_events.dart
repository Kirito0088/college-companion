/// Calendar Events Table
///
/// Local source of truth for calendar/agenda events. Replaces the
/// `MockEvent` model used by the calendar UI (Phase 4 §3: "Calendar
/// replaces MockEvent").
///
/// Business columns are grounded in the existing `MockEvent` data shape
/// (id, title, type, date, time, subject, location, notes). Syncs in
/// Phase 5; the Syncable Entity Convention block is applied now to avoid
/// a later column-add migration (Phase 4 §2 / Addendum §3).
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// A calendar/agenda event.
@DataClassName('CalendarEventEntity')
class CalendarEvents extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Owner — RLS filter key.
  TextColumn get userId => text()();

  /// Event title.
  TextColumn get title => text()();

  /// Event type: `academic`, `assignment`, `exam`, or `personal`.
  /// Mirrors the `EventType` enum in `calendar/models/mock_event.dart`.
  TextColumn get type => text()();

  /// The calendar date of the event.
  DateTimeColumn get date => dateTime()();

  /// Local time as `HH:MM`, or NULL for all-day events.
  TextColumn get time => text().nullable()();

  /// Optional link to a subject. NULL for personal events.
  TextColumn get subjectId => text().nullable()();

  /// Optional location (e.g. "Exam Hall 2", "Lab 3").
  TextColumn get location => text().nullable()();

  /// Optional notes.
  TextColumn get notes => text().nullable()();

  /// Soft delete: NULL = active, timestamp = deleted.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (type IN ('academic', 'assignment', 'exam', 'personal'))",
  ];
}
