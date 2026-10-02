/// Reminder Scheduler (#10)
///
/// Applies a reminder plan (see `reminder_planner.dart`) to two places at
/// once: the OS notification schedule, via [LocalNotificationService], and
/// the `notifications` table, which the Notifications screen reads.
///
/// Each planned reminder is stored as a row dated to its fire time. The
/// repository only surfaces rows whose time has come, so a row appears in
/// the student's history exactly when the OS shows the notification, and
/// the table doubles as the ledger of what is scheduled.
library;

import 'dart:async';

import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:college_companion/features/notifications/repositories/notification_repository.dart';
import 'package:college_companion/services/local_notification_service.dart';

typedef _Request = ({String userId, List<PlannedReminder> plan, DateTime now});

/// Keeps the OS schedule and the notifications table in step with a plan.
class ReminderScheduler {
  ReminderScheduler(this._localNotifications, this._notificationRepository);

  final LocalNotificationService _localNotifications;
  final NotificationRepository _notificationRepository;

  Future<void>? _inFlight;
  _Request? _queued;

  /// Makes the schedule match [plan] as of [now].
  ///
  /// Runs are serialized: a call made while one is in progress waits for it
  /// and then applies the most recent plan only, since an older plan is
  /// already stale. Failures propagate to the caller.
  Future<void> reconcile({
    required String userId,
    required List<PlannedReminder> plan,
    required DateTime now,
  }) {
    _queued = (userId: userId, plan: plan, now: now);
    return _inFlight ??= _drain();
  }

  /// Cancels everything pending, e.g. on sign-out.
  Future<void> clear() async {
    await _inFlight;
    await _localNotifications.cancelAll();
  }

  Future<void> _drain() async {
    try {
      for (var request = _queued; request != null; request = _queued) {
        _queued = null;
        await _apply(request);
      }
    } finally {
      _queued = null;
      _inFlight = null;
    }
  }

  Future<void> _apply(_Request request) async {
    final (:userId, :plan, :now) = request;

    var wanted = plan.where((r) => r.fireAt.isAfter(now)).toList();
    // Without permission nothing would be shown, so nothing may be recorded
    // as delivered either.
    if (wanted.isNotEmpty && !await _localNotifications.canNotify()) {
      wanted = const [];
    }

    final wantedByKey = {for (final r in wanted) r.key: r};
    final stored = await _notificationRepository.getScheduledReminders(
      userId,
      now,
    );
    final storedByKey = {for (final row in stored) row.id: row};
    final pending = await _localNotifications.pendingIds();

    for (final row in stored) {
      if (wantedByKey.containsKey(row.id)) continue;
      await _localNotifications.cancel(PlannedReminder.idForKey(row.id));
      await _notificationRepository.removeScheduledReminder(userId, row.id);
    }

    // Anything else the OS holds that the plan does not want, e.g. rows
    // lost with cleared app data while their alarms survived.
    final wantedIds = {for (final r in wanted) r.notificationId};
    for (final id in pending.difference(wantedIds)) {
      await _localNotifications.cancel(id);
    }

    for (final reminder in wanted) {
      final fireIso = reminder.fireAt.toUtc().toIso8601String();
      final row = storedByKey[reminder.key];
      final unchanged =
          row != null &&
          row.createdAt == fireIso &&
          row.title == reminder.title &&
          row.message == reminder.body;
      if (unchanged && pending.contains(reminder.notificationId)) continue;

      await _localNotifications.schedule(reminder);
      await _notificationRepository.saveScheduledReminder(userId, reminder);
    }
  }
}
