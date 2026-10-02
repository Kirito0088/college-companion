/// Resolving an assignment's subject for display (#40).
library;

import 'package:college_companion/database/app_database.dart';

/// Shown when an assignment's subject cannot be resolved.
const String noSubjectLabel = 'No subject';

/// The name of the subject [subjectId] refers to, or null if none does.
///
/// Before #40 the add dialog stored the subject's *name* in `subject_id`
/// (or the literal 'General'). A value equal to an existing subject's name
/// still resolves, so those rows read correctly; nothing else is ever
/// returned, so a raw id can never reach the screen.
String? subjectNameFor(String subjectId, Iterable<SubjectEntity> subjects) {
  for (final s in subjects) {
    if (s.id == subjectId) return s.name;
  }
  for (final s in subjects) {
    if (s.name == subjectId) return s.name;
  }
  return null;
}
