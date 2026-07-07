/// Subjects Repository
///
/// Handles CRUD and query operations for subjects
/// (per backend/database.md — subjects table).
///
/// Subjects are the central entity referenced by the timetable, attendance,
/// assignments, and internal_marks tables. Every read filters out soft-deleted
/// rows (`deleted_at` IS NULL) and is scoped to the requesting user's `userId`.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for subject operations.
class SubjectRepository {
  /// Creates a [SubjectRepository] with the given [database].
  SubjectRepository(this._database);

  final AppDatabase _database;

  /// Watches all non-deleted subjects for the given user, alphabetical by name.
  Stream<List<SubjectEntity>> watchAll(String userId) {
    return (_database.select(_database.subjects)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Watches all non-deleted subjects for the given semester, alphabetical.
  Stream<List<SubjectEntity>> watchBySemester(
    String userId,
    String semesterId,
  ) {
    return (_database.select(_database.subjects)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.semesterId.equals(semesterId) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Watches a single non-deleted subject by ID.
  Stream<SubjectEntity?> watchById(String userId, String id) {
    return (_database.select(_database.subjects)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  /// Gets a non-deleted subject by ID (one-time fetch).
  Future<SubjectEntity?> getById(String userId, String id) {
    return (_database.select(_database.subjects)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Creates a new subject. Returns the new row's ID.
  Future<String> create(SubjectsCompanion data) async {
    final result = await _database
        .into(_database.subjects)
        .insertReturning(data);
    return result.id;
  }

  /// Updates an existing subject.
  Future<void> update(String userId, String id, SubjectsCompanion data) {
    return (_database.update(
      _database.subjects,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
  }

  /// Soft-deletes a subject.
  Future<void> delete(String userId, String id) {
    return (_database.update(
      _database.subjects,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
      SubjectsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
