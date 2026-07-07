/// Lecture Evidence Table (LOCAL-ONLY — never synced)
///
/// Stores the classroom photo captured for a lecture record. One-to-one
/// with `lecture_records` (UNIQUE on `lecture_record_id`).
///
/// Carries **no** sync columns — evidence is local-only and never enters
/// the sync queue (Phase 4 D7, spec §8/§16). The file path is stored
/// **relative** to the app documents directory and resolved at runtime
/// (Phase 4 §A2) so it survives reinstalls and OS doc-dir changes.
///
/// `lecture_records` cannot be deleted (its `BEFORE DELETE` trigger aborts),
/// so evidence rows live as long as their record — the 1:1 UNIQUE constraint
/// is the only relationship needed locally. The cloud has **no** evidence
/// table; evidence is embedded into the Phase 8 export PDF directly from
/// local storage, only if integrity re-verifies (spec §10/§13).
library;

import 'package:drift/drift.dart';

/// A local-only evidence row for a lecture record.
@DataClassName('LectureEvidenceEntity')
class LectureEvidence extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// 1:1 link to the lecture record; UNIQUE enforces one evidence row
  /// per record.
  TextColumn get lectureRecordId => text()();

  /// Path **relative** to the app documents directory (Phase 4 §A2).
  /// Resolve against `getApplicationDocumentsDirectory()` at runtime.
  TextColumn get localPathRelative => text()();

  /// SHA-256 of the evidence file, re-verified on open/export (spec §10).
  TextColumn get sha256 => text()();

  /// Captured image width in pixels.
  IntColumn get width => integer()();

  /// Captured image height in pixels.
  IntColumn get height => integer()();

  /// UTC instant the evidence was captured.
  DateTimeColumn get captureTimestamp => dateTime()();

  /// App version that captured this evidence (spec §11).
  TextColumn get appVersion => text()();

  /// Device timezone at capture (spec §11).
  TextColumn get timezone => text()();

  /// Integrity state: `original` | `missing` | `integrity_failed` (spec §10).
  /// Defaults to `original`; the integrity verifier flips it on re-check.
  TextColumn get state => text().withDefault(const Constant('original'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {lectureRecordId},
  ];
}
