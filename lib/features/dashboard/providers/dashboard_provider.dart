/// Dashboard Providers
///
/// Riverpod providers for dashboard data synthesis.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Aggregates data from calendar, assignments, and attendance streams into a [DashboardSnapshot].
final dashboardSnapshotProvider =
    FutureProvider.family<DashboardSnapshot, String>((ref, userId) async {
      if (userId.isEmpty) {
        return DashboardSnapshot.empty();
      }

      // Watch the streams
      final calendarEvents = await ref.watch(
        calendarEventsStreamProvider(userId).future,
      );
      final assignments = await ref.watch(
        assignmentsStreamProvider(userId).future,
      );
      final safeBunk = await ref.watch(safeBunkStreamProvider(userId).future);
      final subjects = await ref.watch(subjectsStreamProvider(userId).future);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // 1. Process Calendar Events
      final todayEvents = calendarEvents.where((e) {
        final start = DateTime.tryParse(e.startDate);
        if (start == null) return false;
        return start.isAfter(todayStart) && start.isBefore(todayEnd);
      }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

      CalendarEventEntity? nextEvent;
      final timelineEvents = <TimelineEvent>[];

      for (final event in todayEvents) {
        final start = DateTime.tryParse(event.startDate) ?? now;
        final end =
            DateTime.tryParse(event.endDate) ??
            start.add(const Duration(hours: 1));
        final isPast = now.isAfter(end);
        final isNow = now.isAfter(start) && now.isBefore(end);

        if (nextEvent == null && (isNow || now.isBefore(start))) {
          nextEvent = event;
        }

        timelineEvents.add(
          TimelineEvent(
            title: event.title,
            location: event.description ?? 'TBD',
            timeString: DateFormat('hh:mm').format(start),
            meridiem: DateFormat('a').format(start),
            isNow: isNow,
            isPast: isPast,
          ),
        );
      }

      // 2. Next Action
      HeroAction? nextAction;
      if (nextEvent != null) {
        final start = DateTime.tryParse(nextEvent.startDate) ?? now;
        final diff = start.difference(now);
        String urgency;
        if (diff.isNegative) {
          urgency = 'Ongoing now';
        } else if (diff.inMinutes < 60) {
          urgency = 'Starts in ${diff.inMinutes}m';
        } else {
          urgency = 'Starts in ${diff.inHours}h';
        }
        nextAction = HeroAction(
          title: nextEvent.title,
          timeString: DateFormat('hh:mm a').format(start),
          location: nextEvent.description ?? 'TBD',
          urgencyString: urgency,
        );
      }

      // 3. Process Assignments
      final pendingAssignments = assignments
          .where((a) => a.status != 'completed')
          .toList();
      final dueToday = pendingAssignments.where((a) {
        final due = DateTime.tryParse(a.dueDate);
        if (due == null) return false;
        return due.isAfter(todayStart) && due.isBefore(todayEnd);
      }).length;

      String deadlinesState = 'All clear';
      if (dueToday > 0) {
        deadlinesState = '$dueToday Due Today';
      } else if (pendingAssignments.isNotEmpty) {
        deadlinesState = '${pendingAssignments.length} Pending';
      }

      // Sort and map upcoming assignments
      final sortedAssignments = List<AssignmentEntity>.from(pendingAssignments)
        ..sort((a, b) {
          final dateA = DateTime.tryParse(a.dueDate) ?? DateTime(2100);
          final dateB = DateTime.tryParse(b.dueDate) ?? DateTime(2100);
          return dateA.compareTo(dateB);
        });

      final upcomingList = sortedAssignments.take(3).map((a) {
        final dueDate = DateTime.tryParse(a.dueDate);
        final daysLeft = dueDate != null ? dueDate.difference(now).inDays : 0;

        // Find subject name
        final subj = subjects.where((s) => s.id == a.subjectId).firstOrNull;
        final subjectName = subj?.name ?? 'Unknown';

        return DashboardAssignment(
          id: a.id,
          title: a.title,
          subject: subjectName,
          dueDateString: dueDate != null
              ? DateFormat('MMM d, yyyy').format(dueDate)
              : 'No due date',
          daysLeft: daysLeft < 0 ? 0 : daysLeft,
        );
      }).toList();

      // 4. Academic Snapshot
      String attendanceState = 'On Track';
      if (safeBunk.total == 0) {
        attendanceState = 'No Data';
      } else if (safeBunk.currentPercentage < safeBunk.targetPercentage) {
        attendanceState =
            'Critical (${safeBunk.currentPercentage.toStringAsFixed(0)}%)';
      } else if (safeBunk.safeBunks > 0) {
        attendanceState = '${safeBunk.safeBunks} Safe Bunks';
      }

      final workloadState = pendingAssignments.length > 3
          ? 'Heavy'
          : 'Manageable';

      final academicSnapshot = AcademicSnapshot(
        attendanceState: attendanceState,
        workloadState: workloadState,
        deadlinesState: deadlinesState,
        nextBreakState: 'In 2 hrs',
      );

      return DashboardSnapshot(
        greetingContext: '${todayEvents.length} lectures today',
        nextAction: nextAction,
        timelineEvents: timelineEvents,
        academicSnapshot: academicSnapshot,
        upcomingAssignments: upcomingList,
      );
    });
