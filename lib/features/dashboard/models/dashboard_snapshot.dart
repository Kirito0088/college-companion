library;

/// Dashboard Presentation Model
///
/// Encapsulates all synthesized data for the dashboard UI.
/// This prevents widgets from containing business or synthesis logic.
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.greetingContext,
    required this.nextAction,
    required this.timelineEvents,
    required this.academicSnapshot,
    required this.upcomingAssignments,
  });

  /// Factory for an initial/empty state when no database records exist
  factory DashboardSnapshot.empty() {
    return const DashboardSnapshot(
      greetingContext: '0 lectures today',
      nextAction: null,
      timelineEvents: [],
      academicSnapshot: AcademicSnapshot(
        attendanceState: 'No Data',
        workloadState: 'Clear',
        deadlinesState: 'All clear',
        nextBreakState: 'N/A',
      ),
      upcomingAssignments: [],
    );
  }

  /// Contextual greeting (e.g., "4 lectures today")
  final String greetingContext;

  /// The immediate next action required by the student
  final HeroAction? nextAction;

  /// The chronological flow of today's events
  final List<TimelineEvent> timelineEvents;

  /// Macro reassurance snapshot
  final AcademicSnapshot academicSnapshot;

  /// Upcoming assignments
  final List<DashboardAssignment> upcomingAssignments;
}

/// The immediate physical/temporal requirement.
class HeroAction {
  const HeroAction({
    required this.title,
    required this.timeString,
    required this.location,
    required this.urgencyString,
  });

  final String title;
  final String timeString;
  final String location;
  final String urgencyString;
}

/// A scheduled event in the timeline.
class TimelineEvent {
  const TimelineEvent({
    required this.title,
    required this.location,
    required this.timeString,
    required this.meridiem,
    required this.isNow,
    required this.isPast,
  });

  final String title;
  final String location;
  final String timeString;
  final String meridiem;
  final bool isNow;
  final bool isPast;
}

/// Synthesized macro-level academic status.
class AcademicSnapshot {
  const AcademicSnapshot({
    required this.attendanceState,
    required this.workloadState,
    required this.deadlinesState,
    required this.nextBreakState,
  });

  final String attendanceState;
  final String workloadState;
  final String deadlinesState;
  final String nextBreakState;
}

/// Upcoming assignment representation.
class DashboardAssignment {
  const DashboardAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDateString,
    required this.daysLeft,
  });

  final String id;
  final String title;
  final String subject;
  final String dueDateString;
  final int daysLeft;
}
