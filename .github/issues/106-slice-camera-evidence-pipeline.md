# [SLICE]: Local Camera Evidence Capture Pipeline & SHA-256 Hashing

- **Issue:** #106
- **Labels:** `type:slice`, `milestone:2-lecture-ledger`, `layer:ui-ux`, `layer:drift-db`, `priority:p0-blocker`

## 1. Student Context & Problem
Taking an evidence photo in `LectureRecordScreen` is currently stubbed with a floating SnackBar ("Camera support in future update"). Students cannot capture real classroom photo evidence.

## 2. Tracer-Bullet Architecture Scope
- **UI Layer:** Integrate camera capture (Camera source only; gallery strictly prohibited per spec §8).
- **Data Layer:** Save on-device photo to app documents directory, compute SHA-256 cryptographic hash, and insert into `lecture_evidence` table (1:1 with `lecture_records`).
- **Invariants:** Evidence is stored locally only (never synced to Supabase). Enforce midnight local lock window (no photos can be added after 23:59 on lecture day).

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Capture Photo):**
  - **Given** user taps "Take Photo" during the lecture day,
  - **When** camera captures image,
  - **Then** calculate SHA-256 hash, store relative path in `lecture_evidence`, and display photo thumbnail.
- [ ] **Scenario 2 (Gallery Prohibited):**
  - **Given** image picker is configured,
  - **When** selecting source,
  - **Then** only `ImageSource.camera` is allowed (gallery option is non-existent).
- [ ] **Scenario 3 (Midnight Lock):**
  - **Given** lecture date was yesterday,
  - **When** viewing screen,
  - **Then** evidence attachment is locked permanently.

## 4. Verification & Quality Gates
- [ ] `flutter test test/database/immutability_test.dart` passes.
