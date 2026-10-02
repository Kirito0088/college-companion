/// What an assignment's `due_date` means as a point in time (#43).
library;

/// The local instant [dueDate] refers to, or null if it cannot be read.
///
/// The add dialog stores a date only (`yyyy-MM-dd`). A student reads "due on
/// the 9th" as due by the end of the 9th, so a date-only value is 23:59 local
/// time that day, not the 00:00 that `DateTime.parse` would give, which
/// fires reminders and "due today" checks a day early. A value with a time
/// keeps it, converted to local time.
DateTime? assignmentDue(String dueDate) {
  final parsed = DateTime.tryParse(dueDate);
  if (parsed == null) return null;
  final dateOnly = !dueDate.contains('T') && !dueDate.contains(' ');
  if (dateOnly) {
    return DateTime(parsed.year, parsed.month, parsed.day, 23, 59);
  }
  return parsed.toLocal();
}
