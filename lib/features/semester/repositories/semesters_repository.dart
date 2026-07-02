/// Semester Repository
///
/// Handles CRUD operations for semesters.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for semester operations.
class SemesterRepository {
  /// Creates a [SemesterRepository] with the given [database].
  SemesterRepository(this._database);

  final AppDatabase _database;

  /// Watches all non-deleted semesters for the given user.
  Stream<List<SemesterEntity>> watchAll(String userId) {
    return (_database.select(_database.semesters)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Watches a single non-deleted semester by ID.
  Stream<SemesterEntity?> watchById(String userId, String id) {
    return (_database.select(_database.semesters)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  /// Gets a non-deleted semester by ID (one-time fetch).
  Future<SemesterEntity?> getById(String userId, String id) {
    return (_database.select(_database.semesters)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Creates a new semester.
  Future<String> create(SemestersCompanion data) async {
    final result = await _database
        .into(_database.semesters)
        .insertReturning(data);
    return result.id;
  }

  /// Updates an existing semester.
  Future<void> update(String userId, String id, SemestersCompanion data) {
    return (_database.update(
      _database.semesters,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
  }

  /// Soft-deletes a semester.
  Future<void> delete(String userId, String id) {
    return (_database.update(
      _database.semesters,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
      SemestersCompanion(deletedAt: Value(DateTime.now().toIso8601String())),
    );
  }

  /// Watches the current (active) semester.
  Stream<SemesterEntity?> watchCurrent(String userId) {
    return (_database.select(_database.semesters)..where(
          (t) =>
              t.userId.equals(userId) &
              t.isCurrent.equals(true) &
              t.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  /// Sets a semester as current (unsets others first).
  ///
  /// Verifies the requested semester exists before modifying any rows.
  /// The entire operation is transactional.
  Future<void> setCurrent(String userId, String id) async {
    // Verify the semester exists and is not deleted.
    final semester =
        await (_database.select(_database.semesters)..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.id.equals(id) &
                  t.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    if (semester == null) return;

    await _database.transaction(() async {
      // Unset all current semesters for this user (only non-deleted ones).
      await (_database.update(_database.semesters)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull()))
          .write(const SemestersCompanion(isCurrent: Value(false)));

      // Set the specified semester as current.
      await (_database.update(_database.semesters)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.equals(id) &
                t.deletedAt.isNull(),
          ))
          .write(const SemestersCompanion(isCurrent: Value(true)));
    });
  }
}
