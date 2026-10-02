/// Tests for applying a reminder plan to the OS and the notifications
/// table (#10).
///
/// The OS side sits behind [ReminderGateway] so a fake can record what was
/// scheduled; the table side runs on a real in-memory Drift database.
///
/// The notifications table is the read surface for reminders: each planned
/// reminder is stored as a row dated to its fire time, and the screen only
/// shows rows whose time has come. The table is therefore also the ledger
/// of what is scheduled, and no parallel store is needed.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/notifications/repositories/notification_repository.dart';
import 'package:college_companion/features/notifications/services/reminder_planner.dart';
import 'package:college_companion/features/notifications/services/reminder_scheduler.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = 'u1';

class _FakeGateway implements ReminderGateway {
  bool allowed = true;
  final Map<int, PlannedReminder> pending = {};
  int scheduleCalls = 0;
  int cancelAllCalls = 0;

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

  /// What the OS would fire, keyed by reminder key.
  Map<String, PlannedReminder> get byKey => {
    for (final r in pending.values) r.key: r,
  };
}

PlannedReminder _reminder(
  String key,
  DateTime fireAt, {
  String title = 'Upcoming Class',
  String body = 'Compilers in Room 302 in 10m',
}) => PlannedReminder(
  key: '${PlannedReminder.keyPrefix}$key',
  fireAt: fireAt,
  title: title,
  body: body,
  channel: ReminderChannel.lectures,
  type: 'lecture_reminder',
  targetRoute: '/timetable',
);

void main() {
  late AppDatabase db;
  late NotificationRepository repo;
  late _FakeGateway gateway;
  late ReminderScheduler scheduler;
  final now = DateTime(2026, 10, 5, 8);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NotificationRepository(db);
    gateway = _FakeGateway();
    scheduler = ReminderScheduler(gateway, repo);
  });

  tearDown(() => db.close());

  Future<List<NotificationEntity>> rows() =>
      (db.select(db.notifications)..where((t) => t.deletedAt.isNull())).get();

  test(
    'schedules each reminder and stores a row dated to its fire time',
    () async {
      final r = _reminder(
        'lecture:tt1:2026-10-05',
        now.add(const Duration(minutes: 50)),
      );

      await scheduler.reconcile(userId: _user, plan: [r], now: now);

      expect(gateway.byKey.keys, [r.key]);
      final stored = (await rows()).single;
      expect(stored.id, r.key);
      expect(stored.title, 'Upcoming Class');
      expect(stored.message, 'Compilers in Room 302 in 10m');
      expect(stored.type, 'lecture_reminder');
      expect(stored.targetRoute, '/timetable');
      expect(DateTime.parse(stored.createdAt), r.fireAt.toUtc());
    },
  );

  test('re-applying the same plan schedules nothing new', () async {
    final plan = [_reminder('a', now.add(const Duration(hours: 1)))];
    await scheduler.reconcile(userId: _user, plan: plan, now: now);
    await scheduler.reconcile(userId: _user, plan: plan, now: now);

    expect(gateway.scheduleCalls, 1);
  });

  test(
    'a reminder dropped from the plan is cancelled and its row removed',
    () async {
      final keep = _reminder('keep', now.add(const Duration(hours: 1)));
      final drop = _reminder('drop', now.add(const Duration(hours: 2)));
      await scheduler.reconcile(userId: _user, plan: [keep, drop], now: now);

      await scheduler.reconcile(userId: _user, plan: [keep], now: now);

      expect(gateway.byKey.keys, [keep.key]);
      expect((await rows()).map((r) => r.id), [keep.key]);
    },
  );

  test('a changed reminder is rescheduled under the same id', () async {
    final before = _reminder('a', now.add(const Duration(hours: 1)));
    final after = _reminder(
      'a',
      now.add(const Duration(hours: 3)),
      body: 'Moved',
    );
    await scheduler.reconcile(userId: _user, plan: [before], now: now);

    await scheduler.reconcile(userId: _user, plan: [after], now: now);

    expect(gateway.pending, hasLength(1));
    expect(gateway.byKey[after.key]!.fireAt, after.fireAt);
    final stored = (await rows()).single;
    expect(stored.message, 'Moved');
    expect(DateTime.parse(stored.createdAt), after.fireAt.toUtc());
  });

  test('a reminder the OS lost is scheduled again', () async {
    final r = _reminder('a', now.add(const Duration(hours: 1)));
    await scheduler.reconcile(userId: _user, plan: [r], now: now);
    gateway.pending.clear(); // e.g. cleared by the system

    await scheduler.reconcile(userId: _user, plan: [r], now: now);

    expect(gateway.byKey.keys, [r.key]);
  });

  test(
    'without notification permission nothing is scheduled or stored',
    () async {
      final r = _reminder('a', now.add(const Duration(hours: 1)));
      await scheduler.reconcile(userId: _user, plan: [r], now: now);
      gateway.allowed = false;

      await scheduler.reconcile(userId: _user, plan: [r], now: now);

      expect(gateway.pending, isEmpty);
      expect(await rows(), isEmpty);
    },
  );

  test(
    'delivered reminders stay in the history when the plan changes',
    () async {
      final early = _reminder('early', now.add(const Duration(minutes: 5)));
      await scheduler.reconcile(userId: _user, plan: [early], now: now);

      // An hour later the reminder has fired and the plan no longer has it.
      final later = now.add(const Duration(hours: 1));
      await scheduler.reconcile(userId: _user, plan: const [], now: later);

      expect((await rows()).map((r) => r.id), [early.key]);
    },
  );

  test('clear() cancels everything the OS still has pending', () async {
    await scheduler.reconcile(
      userId: _user,
      plan: [_reminder('a', now.add(const Duration(hours: 1)))],
      now: now,
    );

    await scheduler.clear();

    expect(gateway.pending, isEmpty);
    expect(gateway.cancelAllCalls, 1);
  });

  test('overlapping reconciles settle on the latest plan', () async {
    final a = _reminder('a', now.add(const Duration(hours: 1)));
    final b = _reminder('b', now.add(const Duration(hours: 2)));

    await Future.wait([
      scheduler.reconcile(userId: _user, plan: [a], now: now),
      scheduler.reconcile(userId: _user, plan: [b], now: now),
    ]);

    expect(gateway.byKey.keys, [b.key]);
    expect((await rows()).map((r) => r.id), [b.key]);
  });

  group('NotificationRepository delivered-only reads', () {
    test('watchAll hides reminders until their time comes', () async {
      var clock = now;
      final r = _reminder('a', now.add(const Duration(minutes: 30)));
      await scheduler.reconcile(userId: _user, plan: [r], now: now);

      final seen = <List<String>>[];
      final sub = repo
          .watchAll(
            _user,
            clock: () => clock,
            refresh: const Duration(milliseconds: 20),
          )
          .listen((list) => seen.add(list.map((n) => n.id).toList()));
      addTearDown(sub.cancel);

      await pumpEventQueue();
      expect(seen.last, isEmpty);

      clock = now.add(const Duration(minutes: 31));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(seen.last, [r.key]);
    });

    test('markAllRead leaves undelivered reminders unread', () async {
      final future = _reminder('future', now.add(const Duration(hours: 1)));
      await scheduler.reconcile(userId: _user, plan: [future], now: now);
      await db
          .into(db.notifications)
          .insert(
            NotificationsCompanion.insert(
              id: 'delivered',
              userId: _user,
              title: 'Hello',
              message: 'Delivered earlier',
              createdAt: now
                  .subtract(const Duration(hours: 1))
                  .toUtc()
                  .toIso8601String(),
            ),
          );

      await repo.markAllRead(_user, now: now);

      final byId = {for (final r in await rows()) r.id: r};
      expect(byId['delivered']!.isRead, isTrue);
      expect(byId[future.key]!.isRead, isFalse);
    });
  });

  test('reminder rows are never queued for cloud sync', () async {
    await scheduler.reconcile(
      userId: _user,
      plan: [_reminder('a', now.add(const Duration(hours: 1)))],
      now: now,
    );

    expect(await db.select(db.syncQueueItems).get(), isEmpty);
  });

  test('a gateway failure is reported, not swallowed silently', () async {
    final failing = _ThrowingGateway();
    final s = ReminderScheduler(failing, repo);

    await expectLater(
      s.reconcile(
        userId: _user,
        plan: [_reminder('a', now.add(const Duration(hours: 1)))],
        now: now,
      ),
      throwsA(isA<StateError>()),
    );
    // And the scheduler recovers for the next run.
    final ok = ReminderScheduler(gateway, repo);
    await ok.reconcile(
      userId: _user,
      plan: [_reminder('b', now.add(const Duration(hours: 1)))],
      now: now,
    );
    expect(gateway.pending, hasLength(1));
  });
}

class _ThrowingGateway extends _FakeGateway {
  @override
  Future<void> schedule(PlannedReminder reminder) async =>
      throw StateError('plugin unavailable');
}
