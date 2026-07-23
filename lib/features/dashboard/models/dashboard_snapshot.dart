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
  });

  /// Factory for the Phase 1 mock data (Heavy Academic Day)
  factory DashboardSnapshot.mockHeavyDay() {
    return const DashboardSnapshot(
      greetingContext: '4 lectures today',
      nextAction: HeroAction(
        title: 'Statistics ML',
        timeString: '09:00 AM',
        location: 'Room 305',
        urgencyString: 'Starts in 28m',
      ),
      timelineEvents: [
        TimelineEvent(
          title: 'Data Structures',
          location: 'Room 101',
          timeString: '08:00',
          meridiem: 'AM',
          isNow: false,
          isPast: true,
        ),
        TimelineEvent(
          title: 'Statistics ML',
          location: 'Room 305',
          timeString: '09:00',
          meridiem: 'AM',
          isNow: true,
          isPast: false,
        ),
        TimelineEvent(
          title: 'Artificial Intelligence',
          location: 'Room 302',
          timeString: '10:00',
          meridiem: 'AM',
          isNow: false,
          isPast: false,
        ),
        TimelineEvent(
          title: 'DevOps',
          location: 'Lab 1',
          timeString: '12:00',
          meridiem: 'PM',
          isNow: false,
          isPast: false,
        ),
      ],
      academicSnapshot: AcademicSnapshot(
        attendanceState: 'On Track',
        workloadState: 'Heavy',
        deadlinesState: '1 Due',
        nextBreakState: 'In 2 hrs',
      ),
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
