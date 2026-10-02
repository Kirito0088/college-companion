/// Tests for wiring the reminder planner to the student's live data (#10).
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:college_companion/features/notifications/providers/reminder_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _uid = 'u1';
const _iso = '2026-10-01T00:00:00.000Z';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: _uid, email: 'e@x.test', displayName: 'Test'),
  );
}

class _SignedOut extends AuthStateNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

final _lectures = [
  for (var day = 0; day < 7; day++)
    LectureScheduleItem(
      id: 'tt$day',
      userId: _uid,
      subjectId: 's1',
      subjectName: 'Compilers',
      dayOfWeek: day,
      startTime: '23:50',
      endTime: '23:59',
    ),
];

AssignmentEntity _assignmentDueIn(Duration d) => AssignmentEntity(
  id: 'a1',
  userId: _uid,
  subjectId: 's1',
  title: 'Lab Report',
  dueDate: DateTime.now().add(d).toUtc().toIso8601String(),
  status: 'pending',
  createdAt: _iso,
  updatedAt: _iso,
);

UserSettingsEntity _settings({bool lectures = true, bool all = true}) =>
    UserSettingsEntity(
      id: 'settings_$_uid',
      userId: _uid,
      notificationsEnabled: all,
      lectureRemindersEnabled: lectures,
      enabledModules: '{}',
      theme: 'system',
      preferences: '{}',
      createdAt: _iso,
      updatedAt: _iso,
    );

Future<ProviderContainer> _container({
  bool signedIn = true,
  bool onboarded = true,
  Stream<List<LectureScheduleItem>>? lectures,
  Stream<UserSettingsEntity?>? settings,
  List<AssignmentEntity>? assignments,
}) async {
  SharedPreferences.setMockInitialValues({
    'has_completed_onboarding': onboarded,
  });
  final container = ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(signedIn ? _SignedIn.new : _SignedOut.new),
      weeklyTimetableStreamProvider.overrideWith(
        (ref) => lectures ?? Stream.value(_lectures),
      ),
      pendingAssignmentsStreamProvider.overrideWith(
        (ref, u) => Stream.value(
          assignments ?? [_assignmentDueIn(const Duration(days: 3))],
        ),
      ),
      subjectsStreamProvider.overrideWith(
        (ref, u) => Stream.value([
          const SubjectEntity(
            id: 's1',
            userId: _uid,
            semesterId: 'sem',
            name: 'Databases',
            type: 'theory',
            createdAt: _iso,
            updatedAt: _iso,
          ),
        ]),
      ),
      userSettingsStreamProvider.overrideWith(
        (ref, u) => settings ?? Stream.value(_settings()),
      ),
    ],
  );
  container.listen(reminderPlanProvider, (_, _) {});
  // Let SharedPreferences and the streams deliver.
  await pumpEventQueue();
  return container;
}

void main() {
  test('signed out: reminders are off', () async {
    final c = await _container(signedIn: false);
    addTearDown(c.dispose);
    expect(c.read(reminderPlanProvider), isA<RemindersOff>());
  });

  test('not onboarded yet: reminders are off', () async {
    final c = await _container(onboarded: false);
    addTearDown(c.dispose);
    expect(c.read(reminderPlanProvider), isA<RemindersOff>());
  });

  test('an input still loading means wait, not an empty plan', () async {
    final c = await _container(lectures: const Stream.empty());
    addTearDown(c.dispose);
    expect(c.read(reminderPlanProvider), isA<RemindersWaiting>());
  });

  test('a failed input means wait, never wiping the schedule', () async {
    final c = await _container(
      settings: Stream.error(StateError('no such table: user_settings')),
    );
    addTearDown(c.dispose);
    expect(c.read(reminderPlanProvider), isA<RemindersWaiting>());
  });

  test('ready: plans from timetable, assignments and settings', () async {
    final c = await _container();
    addTearDown(c.dispose);

    final state = c.read(reminderPlanProvider);
    expect(state, isA<RemindersReady>());
    final ready = state as RemindersReady;
    expect(ready.userId, _uid);

    final channels = ready.plan.map((r) => r.channel).toSet();
    expect(channels, containsAll(ReminderChannel.values));
    final assignment = ready.plan.firstWhere(
      (r) => r.channel == ReminderChannel.assignments,
    );
    // The subject name comes from the subjects stream.
    expect(assignment.body, contains('Lab Report (Databases)'));
  });

  test('lecture reminders follow the stored setting', () async {
    final c = await _container(
      settings: Stream.value(_settings(lectures: false)),
    );
    addTearDown(c.dispose);

    final ready = c.read(reminderPlanProvider) as RemindersReady;
    expect(
      ready.plan.where((r) => r.channel == ReminderChannel.lectures),
      isEmpty,
    );
  });

  test('no settings row yet means the defaults: everything on', () async {
    final c = await _container(settings: Stream.value(null));
    addTearDown(c.dispose);

    final ready = c.read(reminderPlanProvider) as RemindersReady;
    expect(
      ready.plan.where((r) => r.channel == ReminderChannel.lectures),
      isNotEmpty,
    );
  });

  test('a date-only deadline is reminded the evening before (#43)', () async {
    final today = DateTime.now();
    final dueDay = DateTime(today.year, today.month, today.day + 3);
    final dueDate =
        '${dueDay.year.toString().padLeft(4, '0')}-'
        '${dueDay.month.toString().padLeft(2, '0')}-'
        '${dueDay.day.toString().padLeft(2, '0')}';
    final c = await _container(
      assignments: [
        AssignmentEntity(
          id: 'a1',
          userId: _uid,
          subjectId: 's1',
          title: 'Lab Report',
          dueDate: dueDate,
          status: 'pending',
          createdAt: _iso,
          updatedAt: _iso,
        ),
      ],
    );
    addTearDown(c.dispose);

    final ready = c.read(reminderPlanProvider) as RemindersReady;
    final dayBefore = ready.plan.firstWhere(
      (r) => r.key.endsWith('assignment:a1:24h'),
    );
    expect(
      dayBefore.fireAt,
      DateTime(dueDay.year, dueDay.month, dueDay.day - 1, 23, 59),
    );
    expect(dayBefore.body, contains('11:59 PM'));
  });
}
