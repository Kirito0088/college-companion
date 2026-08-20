# [SLICE]: Drift SQLite vs Supabase PostgreSQL Ledger Verification Engine

- **Issue:** #110
- **Labels:** `type:slice`, `milestone:4-semester-export`, `layer:drift-db`, `layer:sync-cloud`, `priority:p0-blocker`

## 1. Student Context & Problem
Before compiling the student's canonical semester transcript PDF, the application must cryptographically verify that on-device SQLite records match Supabase PostgreSQL cloud backup records.

## 2. Tracer-Bullet Architecture Scope
- **Service Layer:** Implement `SemesterVerificationService`.
- **Validation Rules:**
  - Verify total lecture count match.
  - Verify attendance status strings match.
  - Verify UTC timestamps match.
  - Verify SHA-256 evidence hashes match between local DB and cloud.

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Successful Verification):**
  - **Given** all local lecture records match cloud rows for `semesterId`,
  - **When** verification completes,
  - **Then** return `VerificationResult.success(merkleRoot)`.
- [ ] **Scenario 2 (Data Discrepancy):**
  - **Given** local record was tampered with or modified offline without sync,
  - **When** verified,
  - **Then** return `VerificationResult.mismatch(details)` and block export.

## 4. Verification & Quality Gates
- [ ] `flutter test test/unit/semester_verification_service_test.dart` passes.
