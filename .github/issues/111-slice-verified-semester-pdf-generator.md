# [SLICE]: Verified Semester Report PDF Generator

- **Issue:** #111
- **Labels:** `type:slice`, `milestone:4-semester-export`, `layer:ui-ux`, `layer:drift-db`, `priority:p0-blocker`

## 1. Student Context & Problem
Students need a tamper-evident, official PDF document summarizing their semester attendance and grades for submission to college administration or personal records.

## 2. Tracer-Bullet Architecture Scope
- Implement `PdfExportService` using `pdf` and `printing` packages.
- Layout: University & Student Header, Semester Attendance Breakdown, Chronological Lecture Ledger, Verified Local Photo Evidence Thumbnails, Verification UUID & QR Code.

## 3. Acceptance Criteria
- [ ] **Scenario 1 (Valid PDF Generation):**
  - **Given** verified semester data,
  - **When** generating PDF,
  - **Then** produce an A4 PDF document formatted with M3 dark-accent branding and high-resolution typography.
- [ ] **Scenario 2 (Corrupted Local Photo):**
  - **Given** an on-device photo whose SHA-256 no longer matches `lecture_evidence`,
  - **When** generating PDF,
  - **Then** render an "Integrity Check Failed" placeholder without crashing the document builder.

## 4. Verification
- [ ] `flutter test test/unit/pdf_export_service_test.dart` passes.
