/// Resources Table
///
/// Stores study materials and links.
library;

import 'package:drift/drift.dart';

@TableIndex(name: 'idx_resources_subject', columns: {#subjectId, #deletedAt})
@DataClassName('ResourceEntity')
class Resources extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get url => text()();
  
  TextColumn get subjectId => text().nullable()();
  TextColumn get category => text()(); // e.g., past_papers, notes, syllabus
  
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
