/// Table Registry
///
/// Central registration point for all Drift tables in the database.
/// `app_database.dart` declares its own `@DriftDatabase(tables: [...])`;
/// this registry mirrors that list for documentation and tooling.
library;

import 'package:college_companion/database/tables/assignments.dart';
import 'package:college_companion/database/tables/calendar_events.dart';
import 'package:college_companion/database/tables/internal_marks.dart';
import 'package:college_companion/database/tables/lecture_evidence.dart';
import 'package:college_companion/database/tables/lecture_records.dart';
import 'package:college_companion/database/tables/semesters.dart';
import 'package:college_companion/database/tables/subjects.dart';
import 'package:college_companion/database/tables/sync_metadata.dart';
import 'package:college_companion/database/tables/sync_queue.dart';
import 'package:college_companion/database/tables/timetable.dart';
import 'package:college_companion/database/tables/user_settings.dart';
import 'package:college_companion/database/tables/users.dart';

/// All table classes registered in one place.
final allTables = [
  // Syncable business tables
  Semesters(),
  Subjects(),
  Timetable(),
  LectureRecords(),
  Assignments(),
  InternalMarks(),
  UserSettings(),
  CalendarEvents(),
  // Local-only evidence (never synced)
  LectureEvidence(),
  // Users — download-only projection (no sync block)
  Users(),
  // Internal local-only tracking (no sync block, never synced)
  SyncQueueItems(),
  SyncMetadata(),
];
