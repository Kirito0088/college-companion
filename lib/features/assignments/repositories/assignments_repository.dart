/// Assignments Repository
///
/// Handles CRUD and query operations for assignments
/// (per backend/database.md — assignments table).
///
/// Status is stored as text (`pending`/`completed`); the
/// [AssignmentStatus] enum's `name` matches the stored literals, so query
/// comparisons reference the enum without a [TypeConverter].
/// Every read filters out soft-deleted rows and is scoped to `userId`.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/tables/assignments.dart';
import 'package:drift/drift.dart';

/// Repository for assignment operations.
class AssignmentRepository {
  /// Creates an [AssignmentRepository] with the given [database].
  AssignmentRepository(this._database);

  final AppDatabase _database;

  /// Watches all non-deleted assignments for the given user,
  /// soonest due first.
  Stream<List<AssignmentEntity>> watchAll(String userId) {
    return (_database.select(_database.assignments)
          ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Watches pending assignments, soonest due first.
  Stream<List<AssignmentEntity>> watchPending(String userId) {
    return (_database.select(_database.assignments)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals(AssignmentStatus.pending.name) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Watches completed assignments, most recently completed first.
  Stream<List<AssignmentEntity>> watchCompleted(String userId) {
    return (_database.select(_database.assignments)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals(AssignmentStatus.completed.name) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .watch();
  }

  /// Watches assignments due on a specific calendar date.
  Stream<List<AssignmentEntity>> watchDueOn(String userId, DateTime date) {
    return (_database.select(_database.assignments)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.dueDate.equals(_dayKey(date)) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Watches pending assignments due on or before [end], soonest first.
  Stream<List<AssignmentEntity>> watchUpcoming(String userId, DateTime end) {
    return (_database.select(_database.assignments)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals(AssignmentStatus.pending.name) &
                t.deletedAt.isNull() &
                t.dueDate.isSmallerOrEqualValue(_dayKey(end)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Watches a single non-deleted assignment by ID.
  Stream<AssignmentEntity?> watchById(String userId, String id) {
    return (_database.select(_database.assignments)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .watchSingleOrNull();
  }

  /// Gets a non-deleted assignment by ID (one-time fetch).
  Future<AssignmentEntity?> getById(String userId, String id) {
    return (_database.select(_database.assignments)..where(
          (t) =>
              t.userId.equals(userId) & t.id.equals(id) & t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Creates a new assignment. Returns the new row's ID.
  Future<String> create(AssignmentsCompanion data) async {
    final result = await _database
        .into(_database.assignments)
        .insertReturning(data);
    return result.id;
  }

  /// Updates an existing assignment.
  Future<void> update(String userId, String id, AssignmentsCompanion data) {
    return (_database.update(
      _database.assignments,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(data);
  }

  /// Marks an assignment as completed now.
  Future<void> markCompleted(String userId, String id) {
    return (_database.update(
      _database.assignments,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
      AssignmentsCompanion(
        status: Value(AssignmentStatus.completed.name),
        completedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  /// Soft-deletes an assignment.
  Future<void> delete(String userId, String id) {
    return (_database.update(
      _database.assignments,
    )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
      AssignmentsCompanion(
        deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  /// Formats a [DateTime] as an ISO 8601 calendar date (`YYYY-MM-DD`).
  static String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
