/// Notification Repository
///
/// Handles CRUD and query operations for notifications.
library;

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:drift/drift.dart';

/// Repository for notification operations.
class NotificationRepository {
  /// Creates a [NotificationRepository] with the given [database] and optional [syncQueueRepository].
  NotificationRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches all non-deleted notifications for the given user, ordered by creation date descending.
  Stream<List<NotificationEntity>> watchAll(String userId) {
    try {
      return (_database.select(_database.notifications)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();
    } catch (e) {
      throw DatabaseException('Failed to watch notifications for user: $userId', e);
    }
  }

  /// Marks a specific notification as read.
  Future<void> markRead(String userId, String id) async {
    try {
      await (_database.update(_database.notifications)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(const NotificationsCompanion(isRead: Value(true)));
      await _syncQueueRepository?.enqueue(
        targetTable: 'notifications',
        recordId: id,
        operation: 'UPDATE',
      );
    } catch (e) {
      throw DatabaseException('Failed to mark notification as read: $id', e);
    }
  }

  /// Marks all unread notifications as read for a given user.
  Future<void> markAllRead(String userId) async {
    try {
      final unreadNotifications = await (_database.select(_database.notifications)
            ..where((t) => t.userId.equals(userId) & t.isRead.equals(false) & t.deletedAt.isNull()))
          .get();

      if (unreadNotifications.isEmpty) return;

      await (_database.update(_database.notifications)
            ..where((t) => t.userId.equals(userId) & t.isRead.equals(false)))
          .write(const NotificationsCompanion(isRead: Value(true)));

      if (_syncQueueRepository != null) {
        for (final notification in unreadNotifications) {
          await _syncQueueRepository.enqueue(
            targetTable: 'notifications',
            recordId: notification.id,
            operation: 'UPDATE',
          );
        }
      }
    } catch (e) {
      throw DatabaseException('Failed to mark all notifications as read', e);
    }
  }

  /// Soft-deletes a notification.
  Future<void> delete(String userId, String id) async {
    try {
      await (_database.update(_database.notifications)
            ..where((t) => t.userId.equals(userId) & t.id.equals(id)))
          .write(
            NotificationsCompanion(
              deletedAt: Value(DateTime.now().toUtc().toIso8601String()),
            ),
          );
      await _syncQueueRepository?.enqueue(
        targetTable: 'notifications',
        recordId: id,
        operation: 'DELETE',
      );
    } catch (e) {
      throw DatabaseException('Failed to soft-delete notification: $id', e);
    }
  }
}
