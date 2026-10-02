/// Reminder Providers (#10)
///
/// Wires the reminder planner to the student's live data. The plan is a
/// pure derivation ([reminderPlanProvider]); [reminderSyncProvider] applies
/// it to the OS, and the app root keeps that provider alive (see
/// `lib/app.dart`).
library;

import 'dart:async';

import 'package:college_companion/features/assignments/models/assignment_due.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/notifications/models/reminder_planner.dart';
import 'package:college_companion/features/notifications/providers/notification_provider.dart';
import 'package:college_companion/features/onboarding/providers/onboarding_provider.dart';
import 'package:college_companion/features/settings/models/notification_preferences.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
import 'package:college_companion/services/local_notification_service.dart';
import 'package:college_companion/services/reminder_scheduler.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The plugin-backed notification service; overridden with a fake in tests.
final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

/// Applies reminder plans to the OS and the notifications table.
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ReminderScheduler(
    ref.watch(localNotificationServiceProvider),
    ref.watch(notificationRepositoryProvider),
  ),
);

/// What the reminder schedule should currently be.
sealed class ReminderPlanState {
  const ReminderPlanState();
}

/// No one to remind: signed out, or onboarding not finished.
final class RemindersOff extends ReminderPlanState {
  const RemindersOff();
}

/// An input is still loading or failed to load. The schedule is left as it
/// is: a failed read must never be mistaken for "nothing to remind", which
/// would cancel every reminder the student has.
final class RemindersWaiting extends ReminderPlanState {
  const RemindersWaiting();
}

/// The schedule the student's data calls for, as of [now].
final class RemindersReady extends ReminderPlanState {
  const RemindersReady({
    required this.userId,
    required this.plan,
    required this.now,
  });

  final String userId;
  final List<PlannedReminder> plan;
  final DateTime now;
}

/// Plans reminders from the signed-in student's timetable, pending
/// assignments and notification settings.
///
/// Recomputes whenever any input changes. Invalidate it to re-plan against
/// the current time, e.g. when the app returns to the foreground, so the
/// seven-day window keeps rolling forward.
final reminderPlanProvider = Provider<ReminderPlanState>((ref) {
  final auth = ref.watch(authStateProvider);
  if (auth is! AuthAuthenticated || !ref.watch(onboardingCompletedProvider)) {
    return const RemindersOff();
  }
  final userId = auth.user.uid;

  final lectures = ref.watch(weeklyTimetableStreamProvider);
  final assignments = ref.watch(pendingAssignmentsStreamProvider(userId));
  final subjects = ref.watch(subjectsStreamProvider(userId));
  final settings = ref.watch(userSettingsStreamProvider(userId));

  final inputs = <AsyncValue<Object?>>[
    lectures,
    assignments,
    subjects,
    settings,
  ];
  if (inputs.any((input) => input.hasError || !input.hasValue)) {
    return const RemindersWaiting();
  }

  final subjectNames = {for (final s in subjects.requireValue) s.id: s.name};
  final now = DateTime.now();

  return RemindersReady(
    userId: userId,
    now: now,
    plan: planReminders(
      lectures: lectures.requireValue,
      assignments: [
        for (final a in assignments.requireValue)
          if (assignmentDue(a.dueDate) case final due?)
            ReminderAssignment(
              id: a.id,
              title: a.title,
              subjectName: subjectNames[a.subjectId],
              due: due,
            ),
      ],
      preferences: notificationPreferencesFrom(settings.requireValue),
      now: now,
    ),
  );
});

/// Applies [reminderPlanProvider] to the OS for as long as it is listened
/// to: reconciles on every new plan and clears on sign-out.
///
/// A provider rather than code in the app widget so the whole chain, from
/// a settings write through re-plan to an OS cancel, is testable without a
/// widget tree.
final reminderSyncProvider = Provider<void>((ref) {
  ref.listen<ReminderPlanState>(reminderPlanProvider, (previous, next) {
    final scheduler = ref.read(reminderSchedulerProvider);
    final Future<void> work;
    switch (next) {
      case RemindersReady(:final userId, :final plan, :final now):
        work = scheduler.reconcile(userId: userId, plan: plan, now: now);
      // Only a transition out of a live schedule (sign-out) clears it. A
      // cold start also begins Off while onboarding state loads, and must
      // not wipe reminders that are about to be re-planned anyway.
      case RemindersOff() when previous is RemindersReady:
        work = scheduler.clear();
      case RemindersOff() || RemindersWaiting():
        return;
    }
    unawaited(
      work.catchError((Object error, StackTrace stackTrace) {
        AppLogger.error(
          'Reminder scheduling failed',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }, fireImmediately: true);
});
