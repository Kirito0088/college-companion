/// What an assignment's `due_date` means as a point in time (#43).
///
/// The add dialog stores a date only. Parsed naively, "2026-10-09" is 00:00
/// at the *start* of the 9th, a day earlier than a student means by "due on
/// the 9th".
library;

import 'package:college_companion/features/assignments/models/assignment_due.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a date-only deadline is the end of that local day', () {
    expect(assignmentDue('2026-10-09'), DateTime(2026, 10, 9, 23, 59));
  });

  test('a timestamped deadline keeps its time, in local time', () {
    final due = assignmentDue('2026-10-09T10:30:00.000Z')!;
    expect(due.isUtc, isFalse);
    expect(due, DateTime.utc(2026, 10, 9, 10, 30).toLocal());
  });

  test('an unreadable deadline is null', () {
    expect(assignmentDue('next week'), isNull);
    expect(assignmentDue(''), isNull);
  });
}
