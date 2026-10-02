/// Next Break derivation for the dashboard's Academic Snapshot (#38).
///
/// Replaces a literal 'In 2 hrs' that showed regardless of the day's
/// schedule — including on days with no classes at all.
library;

/// A scheduled block of time today, e.g. a lecture.
typedef ScheduledBlock = ({DateTime start, DateTime end});

/// A gap shorter than this between two classes is a changeover, not a break.
const Duration minimumBreak = Duration(minutes: 15);

/// Describes when the student's next break starts, given [today]'s blocks.
///
/// - `No classes` — nothing is scheduled today.
/// - `Done today` — every block has ended.
/// - `Now` — the student is between classes (or before the first one).
/// - `In 25 min` / `In 1h 30m` — the student is in a run of classes whose
///   changeovers are all shorter than [minimumBreak]; counts down to the end
///   of the run, not of the current class.
String describeNextBreak(List<ScheduledBlock> today, DateTime now) {
  if (today.isEmpty) return 'No classes';

  final blocks = [...today]..sort((a, b) => a.start.compareTo(b.start));
  if (!blocks.any((b) => b.end.isAfter(now))) return 'Done today';

  final current = blocks
      .where((b) => !b.start.isAfter(now) && b.end.isAfter(now))
      .firstOrNull;
  final next = blocks.where((b) => b.start.isAfter(now)).firstOrNull;

  // Between classes, a changeover too short to be a break means the student
  // is effectively already in the next class's run.
  final anchor =
      current ??
      (next != null && next.start.difference(now) < minimumBreak ? next : null);
  if (anchor == null) return 'Now';

  var runEnd = anchor.end;
  for (final block in blocks) {
    if (!block.end.isAfter(runEnd)) continue;
    if (block.start.isBefore(runEnd.add(minimumBreak))) {
      runEnd = block.end;
    } else {
      break;
    }
  }
  return _inDuration(runEnd.difference(now));
}

String _inDuration(Duration d) {
  // Round up so a class ending at 10:00 reads "In 1 min" at 9:59:30, not 0.
  final minutes = (d.inSeconds + 59) ~/ 60;
  if (minutes < 60) return 'In $minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (rest == 0) return hours == 1 ? 'In 1 hr' : 'In $hours hrs';
  return 'In ${hours}h ${rest}m';
}
