/// A [LocalNotificationService] double that records what would have been
/// scheduled with the OS, for scheduler and reminder-sync tests.
library;

import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:college_companion/services/local_notification_service.dart';

class FakeLocalNotificationService implements LocalNotificationService {
  /// What [canNotify] answers: whether the student allowed notifications.
  bool allowed = true;

  /// Reminders the OS would still fire, keyed by notification id.
  final Map<int, PlannedReminder> pending = {};

  int scheduleCalls = 0;
  int cancelAllCalls = 0;

  /// [pending], keyed by reminder key.
  Map<String, PlannedReminder> get byKey => {
    for (final r in pending.values) r.key: r,
  };

  /// The channels that still have something pending.
  Set<ReminderChannel> get channels =>
      pending.values.map((r) => r.channel).toSet();

  @override
  Stream<ReminderTap> get taps => const Stream.empty();

  @override
  Future<ReminderTap?> launchTap() async => null;

  @override
  Future<bool> canNotify() async => allowed;

  @override
  Future<Set<int>> pendingIds() async => pending.keys.toSet();

  @override
  Future<void> schedule(PlannedReminder reminder) async {
    scheduleCalls++;
    pending[reminder.notificationId] = reminder;
  }

  @override
  Future<void> cancel(int id) async => pending.remove(id);

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    pending.clear();
  }
}
