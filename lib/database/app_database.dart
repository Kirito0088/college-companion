/// App Database (Drift / SQLite)
///
/// SQLite is the local source of truth (per backend/database.md).
/// Database tables will be added as features are implemented.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// The application's local SQLite database.
///
/// Drift is used as the ORM. Tables will be added incrementally
/// as features are implemented.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] with the default native connection.
  AppDatabase() : super(_openConnection());

  /// Creates an [AppDatabase] with a custom [QueryExecutor].
  ///
  /// Useful for testing with in-memory databases.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations will be handled here.
        // Must preserve existing data (per backend/database.md).
      },
    );
  }
}

/// Opens a native SQLite connection.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/college_companion.db');
    return NativeDatabase.createInBackground(file);
  });
}
