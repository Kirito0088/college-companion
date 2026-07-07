/// Lecture Records Table
///
/// Immutable ledger of attendance per timetable lecture. One row per
/// timetable slot — 1:1 with `timetable` (UNIQUE on `timetable_id`).
///
/// Business fields (`status_text`, `note`, `recorded_at`, `timetable_id`,
/// `subject_id`, `semester_id`, `user_id`, `device_timezone`,
/// `app_version`, `created_offline`, `created_at`) are immutable,
/// enforced by SQLite triggers created in `app_database.dart`:
/// - `BEFORE UPDATE` → `RAISE(ABORT)` if any business column changes
///   (sync-bookkeeping columns pass).
/// - `BEFORE DELETE` → `RAISE(ABORT)` always.
///
/// The sync-bookkeeping columns inherited from [SyncableColumns]
/// (`updated_at`, `sync_status`, `sync_version`, `last_synced_at`)
/// remain writable for the sync engine (Phase 4 D5 — immutability is
/// business fields only).
///
/// No `deleted_at` — a record is never deleted, only hidden when its
/// parent subject/semester is soft-deleted (spec §4 "No deletion").
library;

import 'package:college_companion/database/syncable_columns.dart';
import 'package:drift/drift.dart';

/// A lecture record — the immutable evidence that a lecture happened
/// (or didn't) for a specific timetable slot.
@DataClassName('LectureRecordEntity')
class LectureRecords extends Table with SyncableColumns {
  /// UUID primary key.
  TextColumn get id => text()();

  /// 1:1 link to the timetable entry; UNIQUE enforces one record per
  /// lecture slot (spec §3).
  TextColumn get timetableId => text()();

  /// Subject for this lecture (from the timetable slot).
  TextColumn get subjectId => text()();

  /// Denormalized from `subjects` for per-semester export/verification.
  TextColumn get semesterId => text()();

  /// Owner — RLS filter key.
  TextColumn get userId => text()();

  /// Encoded primary + secondary status (spec §5). Format:
  /// `"primary|secondary"` (e.g. `"present|"`, `"absent|holiday"`).
  /// The "Other" secondary status carries its custom text after a second
  /// pipe: `"absent|other|Family emergency"`.
  TextColumn get statusText => text()();

  /// Optional immutable note (spec §7).
  TextColumn get note => text().nullable()();

  /// UTC instant the record was created (user-facing "recorded at").
  DateTimeColumn get recordedAt => dateTime()();

  /// Local timezone when the record was created (spec §11; drives the
  /// ≤23:59-local-lecture-day evidence window, spec §9).
  TextColumn get deviceTimezone => text()();

  /// App version that created this record (spec §11).
  TextColumn get appVersion => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {timetableId},
  ];
}
