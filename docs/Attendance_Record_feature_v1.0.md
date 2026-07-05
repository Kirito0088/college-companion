# Attendance Record Specification

**College Companion v1.0**\
**Status:** Locked Specification (Source of Truth)

## 1. Vision

The **Lecture Record** feature is an immutable academic ledger for every
timetable lecture. It records attendance status, timestamp, optional
note, optional camera-captured evidence, and integrity metadata. It is
the foundation for the verified Semester Report.

## 2. Principles

-   Offline-first
-   Local-first
-   Privacy-first
-   Immutable
-   Honest-user focused
-   Evidence, not proof
-   Verification during export

## 3. Ownership

Lecture Records always belong to a **Timetable Lecture**.

Semester → Subject → Timetable Lecture → Lecture Record

One lecture owns exactly one Lecture Record.

## 4. Immutable Rules

After saving:

-   No editing
-   No deletion
-   No second submission
-   No replacing evidence
-   No second photo

## 5. Statuses

Primary: - Present - Absent - Cancelled

Secondary: - Faculty Absent - Holiday - Practical Cancelled - Extra
Lecture - Other (custom text required)

## 6. Mark Entire Day Absent

Creates immutable Absent Lecture Records for every scheduled lecture
that day.

## 7. Notes

Optional and immutable after submission.

## 8. Evidence

-   Camera only
-   Gallery prohibited
-   Maximum one photo
-   Always optional
-   Stored locally only
-   Never synced

Purpose: provide context, not legal proof.

## 9. Evidence Window

Evidence may be attached only until **23:59 local time of the lecture
date**.

Lifecycle:

Scheduled → Recorded → Evidence Available → Evidence Attached / Skipped
→ Locked Forever

## 10. Integrity

Store:

-   SHA-256
-   Width
-   Height
-   Capture timestamp
-   Local path
-   App version
-   Timezone

Recalculate SHA-256 whenever evidence is opened or exported.

States:

-   Original
-   Missing
-   Integrity Check Failed

Only Original evidence is included in exports.

## 11. Metadata

Store:

-   Lecture ID
-   Subject ID
-   Semester ID
-   Status
-   Recorded timestamp
-   Note
-   Evidence path
-   Evidence hash
-   Created offline flag
-   Sync timestamp
-   App version
-   Device timezone

## 12. UI

Lecture Information

↓

Attendance Status

↓

Optional Note

↓

Optional Evidence

↓

Save Lecture Record

## 13. Synchronization

Lecture → Drift → Sync Queue → Supabase → Verified Export

## 14. Semester Export

Requirements:

-   Internet connection
-   Google authenticated user
-   Successful synchronization
-   Verification success

Verification compares:

-   Lecture IDs
-   Status
-   Timestamp
-   Notes
-   Evidence hash
-   Record count

Any mismatch blocks export.

No bypass.

Evidence is rehashed before export.

Only verified evidence appears in the PDF.

## 15. Canonical Report

The exported Semester PDF is the student's canonical verified semester
record.

## 16. Out of Scope

-   GPS
-   Gallery import
-   Multiple photos
-   Editing
-   Deleting
-   Cloud photo storage
-   Anti-cheat mechanisms

## Final Principle

Every timetable lecture should leave behind one trustworthy, immutable
Lecture Record.
