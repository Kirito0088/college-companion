/// Table Registry
///
/// Central registration point for all Drift tables in the database.
library;

import 'package:college_companion/database/tables/assignments.dart';
import 'package:college_companion/database/tables/attendance.dart';
import 'package:college_companion/database/tables/calendar_events.dart';
import 'package:college_companion/database/tables/internal_marks.dart';
import 'package:college_companion/database/tables/lecture_evidence.dart';
import 'package:college_companion/database/tables/lecture_records.dart';
import 'package:college_companion/database/tables/notifications.dart';
import 'package:college_companion/database/tables/resources.dart';
import 'package:college_companion/database/tables/semesters.dart';
import 'package:college_companion/database/tables/subjects.dart';
import 'package:college_companion/database/tables/sync_metadata.dart';
import 'package:college_companion/database/tables/sync_queue.dart';
import 'package:college_companion/database/tables/timetable.dart';
import 'package:college_companion/database/tables/user_settings.dart';
import 'package:college_companion/database/tables/users.dart';

/// All 15 table classes registered in one place.
final allTables = [
  // User profile
  Users(),
  // Business tables
  Semesters(),
  Subjects(),
  Timetable(),
  Attendance(),
  LectureRecords(),
  Assignments(),
  InternalMarks(),
  UserSettings(),
  CalendarEvents(),
  Resources(),
  LectureEvidence(),
  Notifications(),
  // Internal tracking
  SyncQueueItems(),
  SyncMetadata(),
];
