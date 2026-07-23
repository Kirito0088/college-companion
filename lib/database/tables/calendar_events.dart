/// Calendar Events Table
///
/// Stores calendar events and schedules.
library;

import 'package:drift/drift.dart';

@TableIndex(name: 'idx_calendar_events_user_date', columns: {#userId, #startDate, #deletedAt})
@DataClassName('CalendarEventEntity')
class CalendarEvents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  
  TextColumn get eventType => text()();
  
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
