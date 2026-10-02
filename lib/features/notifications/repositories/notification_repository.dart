/// Notification Repository
///
/// Handles CRUD and query operations for notifications.
library;

import 'dart:async';

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show listEquals;

/// Prefix of the ids of rows written by the reminder scheduler (#10).
const String reminderIdPrefix = PlannedReminder.keyPrefix;

/// Repository for notification operations.
class NotificationRepository {
  /// Creates a [NotificationRepository] with the given [database] and optional [syncQueueRepository].
  NotificationRepository(this._database, [this._syncQueueRepository]);

  final AppDatabase _database;
  final SyncQueueRepository? _syncQueueRepository;

  /// Watches the user's delivered, non-deleted notifications, newest first.
  ///
  /// Scheduled reminders are stored ahead of time with `createdAt` set to
  /// their fire time (#10), so "delivered" means `createdAt <= now`. Time
  /// passing is not a table change and does not re-run a Drift watch, so the
  /// visible set is re-evaluated every [refresh] as well as on every write.
  /// [clock] exists for tests.
  Stream<List<NotificationEntity>> watchAll(
    String userId, {
    DateTime Function() clock = DateTime.now,
    Duration refresh = const Duration(minutes: 1),
  }) {
    final Stream<List<NotificationEntity>> rows;
    try {
      rows =
          (_database.select(_database.notifications)
                ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
              .watch();
    } catch (e) {
      throw DatabaseException(
        'Failed to watch notifications for user: $userId',
        e,
      );
    }

    List<NotificationEntity>? latest;
    List<String>? lastEmittedIds;
    StreamSubscription<List<NotificationEntity>>? subscription;
    Timer? ticker;
    late final StreamController<List<NotificationEntity>> controller;

    void emitDelivered({bool force = false}) {
      final all = latest;
      if (all == null) return;
      final nowIso = clock().toUtc().toIso8601String();
      final delivered = all
          .where((n) => n.createdAt.compareTo(nowIso) <= 0)
          .toList();
      final ids = delivered.map((n) => n.id).toList();
      // A tick only matters when a reminder crossed into view.
      if (!force && listEquals(ids, lastEmittedIds)) return;
      lastEmittedIds = ids;
      controller.add(delivered);
    }

    controller = StreamController<List<NotificationEntity>>(
      onListen: () {
        subscription = rows.listen(
          (all) {
            latest = all;
            emitDelivered(force: true);
          },
          onError: controller.addError,
          onDone: () {
            ticker?.cancel();
            controller.close();
          },
        );
        ticker = Timer.periodic(refresh, (_) => emitDelivered());
      },
      onCancel: () async {
        ticker?.cancel();
        await subscription?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  /// Future-dated reminder rows for [userId]: those scheduled with the OS
  /// that have not fired yet as of [now].
  Future<List<NotificationEntity>> getScheduledReminders(
    String userId,
    DateTime now,
  ) async {
    try {
      final nowIso = now.toUtc().toIso8601String();
      return await (_database.select(_database.notifications)..where(
            (t) =>
                t.userId.equals(userId) &
                t.id.like('$reminderIdPrefix%') &
                t.createdAt.isBiggerThanValue(nowIso) &
                t.deletedAt.isNull(),
          ))
          .get();
    } catch (e) {
      throw DatabaseException('Failed to read scheduled reminders', e);
    }
  }

  /// Stores (or updates) a scheduled reminder's row.
  ///
  /// Not queued for cloud sync: reminder rows are derived on each device
  /// from data that does sync (timetable, assignments, settings), and the
  /// cloud schema has no notifications table.
  Future<void> saveScheduledReminder(
    String userId,
    PlannedReminder reminder,
  ) async {
    try {
      await _database
          .into(_database.notifications)
          .insertOnConflictUpdate(
            NotificationsCompanion(
              id: Value(reminder.key),
              userId: Value(userId),
              title: Value(reminder.title),
              message: Value(reminder.body),
              type: Value(reminder.type),
              targetRoute: Value(reminder.targetRoute),
              isRead: const Value(false),
              // Delivery time: the row stays out of watchAll until then.
              createdAt: Value(reminder.fireAt.toUtc().toIso8601String()),
            ),
          );
    } catch (e) {
      throw DatabaseException('Failed to save scheduled reminder', e);
    }
  }

  /// Removes a reminder row that was scheduled but will no longer fire.
  ///
  /// A hard delete: the row was never delivered or synced, so there is no
  /// history to keep and nothing for the cloud to learn.
  Future<void> removeScheduledReminder(String userId, String id) async {
    try {
      await (_database.delete(
        _database.notifications,
      )..where((t) => t.userId.equals(userId) & t.id.equals(id))).go();
    } catch (e) {
      throw DatabaseException('Failed to remove scheduled reminder: $id', e);
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

  /// Marks every delivered, unread notification as read for a given user.
  ///
  /// Reminders still waiting to fire are left alone: the student has not
  /// seen them yet. [now] exists for tests.
  Future<void> markAllRead(String userId, {DateTime? now}) async {
    try {
      final nowIso = (now ?? DateTime.now()).toUtc().toIso8601String();
      Expression<bool> unreadDelivered($NotificationsTable t) =>
          t.userId.equals(userId) &
          t.isRead.equals(false) &
          t.deletedAt.isNull() &
          t.createdAt.isSmallerOrEqualValue(nowIso);

      final unreadNotifications = await (_database.select(
        _database.notifications,
      )..where(unreadDelivered)).get();

      if (unreadNotifications.isEmpty) return;

      await (_database.update(_database.notifications)..where(unreadDelivered))
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
      await (_database.update(
        _database.notifications,
      )..where((t) => t.userId.equals(userId) & t.id.equals(id))).write(
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
