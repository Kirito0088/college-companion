/// Notifications Table
///
/// Stores per-user application notifications and alerts.
library;

import 'package:drift/drift.dart';

/// Notifications table definition.
@TableIndex(name: 'idx_notifications_user', columns: {#userId})
@DataClassName('NotificationEntity')
class Notifications extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Owner user ID.
  TextColumn get userId => text()();

  /// Notification title.
  TextColumn get title => text()();

  /// Notification detail message.
  TextColumn get message => text()();

  /// Category type (e.g. 'academic_alert', 'upcoming', 'insight').
  TextColumn get type => text().withDefault(const Constant('upcoming'))();

  /// Optional navigation target route (e.g. '/attendance', '/assignments', '/calendar', '/timetable').
  TextColumn get targetRoute => text().nullable()();

  /// Unread or read status.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  /// ISO 8601 UTC timestamp of creation.
  TextColumn get createdAt => text()();

  /// ISO 8601 UTC timestamp of soft deletion.
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
