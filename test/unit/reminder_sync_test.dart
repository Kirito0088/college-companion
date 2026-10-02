/// End-to-end chain for #11's acceptance criterion: turning off Lecture
/// Reminders cancels every pending lecture alarm.
///
/// The write goes through [UserSettingsRepository] into a real in-memory
/// Drift database; the real `userSettingsStreamProvider` watch picks it up;
/// [reminderPlanProvider] re-plans; [reminderSyncProvider] hands the plan to
/// the scheduler, which cancels the dropped reminders with the OS. Only the
/// OS and the timetable stream are faked. (The Settings widget test covers
/// the tap → write half.)
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:college_companion/features/notifications/providers/reminder_provider.dart';
import 'package:college_companion/features/timetable/models/lecture_schedule_item.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_local_notification_service.dart';

const _uid = 'u1';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: _uid, email: 'e@x.test', displayName: 'Test'),
  );
}

Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 400 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(done(), isTrue, reason: 'condition not reached');
}

void main() {
  test('turning Lecture Reminders off cancels every pending lecture '
      'alarm and keeps the rest', () async {
    SharedPreferences.setMockInitialValues({'has_completed_onboarding': true});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final os = FakeLocalNotificationService();

    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(_SignedIn.new),
        databaseProvider.overrideWithValue(db),
        localNotificationServiceProvider.overrideWithValue(os),
        weeklyTimetableStreamProvider.overrideWith(
          (ref) => Stream.value([
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
          ]),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    container.listen(reminderSyncProvider, (_, _) {});

    await _until(() => os.channels.contains(ReminderChannel.lectures));
    expect(os.channels, contains(ReminderChannel.briefing));

    // What the Lecture Reminders switch does.
    await container
        .read(userSettingsRepositoryProvider)
        .updateNotificationPreferences(_uid, lectureRemindersEnabled: false);

    await _until(() => !os.channels.contains(ReminderChannel.lectures));
    expect(os.channels, contains(ReminderChannel.briefing));
  });
}
