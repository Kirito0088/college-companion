/// Dashboard Providers
///
/// Riverpod providers for dashboard data synthesis.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/models/assignment_due.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/models/next_break.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/features/timetable/providers/timetable_provider.dart';
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
      final lectures = await ref.watch(
        todayLecturesStreamProvider(userId).future,
      );

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // 1. Today's blocks: timetable lectures and calendar events together
      // (#42). The dashboard used to read calendar events alone, so a
      // student with a timetable lecture saw "0 lectures today" while its
      // reminder fired from the timetable.
      final today = <_TodayBlock>[
        for (final lecture in lectures)
          if (lecture.startOn(todayStart) case final start?)
            _TodayBlock(
              title: lecture.subjectName,
              location: lecture.room ?? '',
              start: start,
              end: lecture.endOn(todayStart) ?? start.add(_defaultLength),
            ),
        for (final event in calendarEvents)
          // Stored in UTC; compared and displayed in local time.
          if (DateTime.tryParse(event.startDate)?.toLocal() case final start?
              when !start.isBefore(todayStart) && start.isBefore(todayEnd))
            _TodayBlock(
              title: event.title,
              location: event.description ?? '',
              start: start,
              end:
                  DateTime.tryParse(event.endDate)?.toLocal() ??
                  start.add(_defaultLength),
            ),
      ]..sort((a, b) => a.start.compareTo(b.start));

      final timelineEvents = [
        for (final block in today)
          TimelineEvent(
            title: block.title,
            location: block.location,
            timeString: DateFormat('hh:mm').format(block.start),
            meridiem: DateFormat('a').format(block.start),
            isNow: !now.isBefore(block.start) && now.isBefore(block.end),
            isPast: !now.isBefore(block.end),
          ),
      ];

      // 2. Next Action: the block in progress, else the next to start.
      HeroAction? nextAction;
      if (today.where((b) => now.isBefore(b.end)).firstOrNull
          case final next?) {
        final diff = next.start.difference(now);
        final String urgency;
        if (diff.isNegative) {
          urgency = 'Ongoing now';
        } else if (diff.inMinutes < 60) {
          urgency = 'Starts in ${diff.inMinutes}m';
        } else {
          urgency = 'Starts in ${diff.inHours}h';
        }
        nextAction = HeroAction(
          title: next.title,
          timeString: DateFormat('hh:mm a').format(next.start),
          location: next.location,
          urgencyString: urgency,
        );
      }

      // 3. Process Assignments
      final pendingAssignments = assignments
          .where((a) => a.status != 'completed')
          .toList();
      final dueToday = pendingAssignments.where((a) {
        final due = assignmentDue(a.dueDate);
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
          final dateA = assignmentDue(a.dueDate) ?? DateTime(2100);
          final dateB = assignmentDue(b.dueDate) ?? DateTime(2100);
          return dateA.compareTo(dateB);
        });

      final upcomingList = sortedAssignments.take(3).map((a) {
        final dueDate = assignmentDue(a.dueDate);
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
        nextBreakState: describeNextBreak([
          for (final block in today) (start: block.start, end: block.end),
        ], now),
        attendancePercentage: safeBunk.currentPercentage,
        isAttendanceSafe:
            safeBunk.currentPercentage >= safeBunk.targetPercentage,
        hasAttendanceData: safeBunk.total > 0,
      );

      return DashboardSnapshot(
        greetingContext:
            '${today.length} lecture${today.length == 1 ? '' : 's'} today',
        nextAction: nextAction,
        timelineEvents: timelineEvents,
        academicSnapshot: academicSnapshot,
        upcomingAssignments: upcomingList,
      );
    });

/// Assumed length of a block with no readable end time.
const Duration _defaultLength = Duration(hours: 1);

/// One thing on the student's day: a timetable lecture or a calendar event.
class _TodayBlock {
  const _TodayBlock({
    required this.title,
    required this.location,
    required this.start,
    required this.end,
  });

  final String title;

  /// Room or place; empty when unknown, never a placeholder.
  final String location;
  final DateTime start;
  final DateTime end;
}
