# Manual QA — Redesign Slices 4–7

Covers the app-wide visual redesign (ADR-011: `CCTokens` `ThemeExtension`, light+dark themes,
selectable jade/sand/azure accent) for Slices 4–7, which have not been manually verified since
Slice 4. Automated coverage exists for Slices 4–7 (see `test/widget/attendance_redesign_test.dart`,
`calendar_timetable_redesign_test.dart`, `subject_details_redesign_test.dart`,
`slice7_redesign_test.dart`) — this checklist is for what automated widget tests can't catch:
actual visual rendering, animation, and cross-accent readability.

## How to run this

1. Switch theme/accent at **Settings → Appearance** (`/settings`). Note: the first tap on a
   brand-new account creates the settings row on the fly (get-or-create) — test that path once,
   don't assume it's pre-seeded.
2. **Full pass**: walk every screen below in **Dark / Jade** (the app's current default). This is
   the pass that must be defect-free.
3. **Fast sweep**: repeat only a glance at each screen in **Light / Jade** and **Dark / Azure** —
   you're only looking for unreadable text, invisible borders, and chips that didn't change color
   with the accent.
4. Flag anything found against the file/line noted in the row, or as new if not listed.

---

## Slice 4 — Attendance

| Screen | Route | Verify | Force these states |
|---|---|---|---|
| AttendanceScreen | `/attendance` | Header, `OverallGauge`, `SegmentedControl`, Overview/Subjects tabs | No records at all; below target %; above target % |
| SafeBunkScreen | `/safe-bunk` (tap the gauge) | `SafeBunkRing` shows real `safeBunks` count and "to stay above N%" — confirm the old hardcoded 82%/180/148 never appear | — |
| LectureRecordScreen | `/lecture-record` | Evidence capture/preview/thumbnail flow | Capture, preview, delete |

> ⚠️ **Known gap, not a new bug**: `evidence_capture_sheet.dart`, `evidence_preview_dialog.dart`,
> `evidence_thumbnail_strip.dart` still hold ~63 un-migrated `ColorTokens`/`RadiusTokens` refs —
> expect them to look wrong in Light mode and ignore accent entirely. Don't re-file this, it's
> tracked as issue **E** below.
>
> Also: Attendance has **no error-state path** — an `AsyncValue.error` currently falls through
> silently. Confirm this (e.g. by forcing a DB read failure) rather than assuming it's handled.

## Slice 5 — Calendar + Timetable

| Screen | Route | Verify | Force these states |
|---|---|---|---|
| CalendarScreen | `/calendar` | Agenda list, event-type chips (academic/assignment/exam/personal must render as 4 visually distinct colors) | `SkeletonList` (loading), `NetworkErrorWidget` (error), `EmptyCalendar` (no events) |
| AddEditEventScreen | `/calendar/add-edit` | Form fields, event-type picker | — |
| EventDetailsScreen | `/calendar/event-details/:id` | Detail layout | — |
| TimetableScreen | `/timetable` | `LectureCard`, `DaySelectorSegmentedButton`, add/edit dialog | `CcEmptyState` (no lectures this day) |

> ⚠️ Timetable has **no error-state path** — same gap as Attendance.

## Slice 6 — Subject Details

| Screen | Route | Verify | Force these states |
|---|---|---|---|
| SubjectDetailsScreen | `/subject-details/:id` | Identity card, metric overview (bunk %), tabs, attendance timeline, quick actions grid, mark-attendance sheet | Filter by All/Present/Absent/Cancelled |

> ⚠️ 56 un-migrated refs live in `subjects/widgets` — this screen should be scrutinized hardest in
> Light mode of everything in this checklist. `SubjectDetailsScreen` itself is migrated (verified
> by `subject_details_redesign_test.dart`'s accent-reactivity test on the FAB) but its child
> widgets are not. No error-state path exists here either.

## Slice 7 — Assignments, Focus, Resources, Semester, Notifications

| Screen | Route | Verify | Force these states |
|---|---|---|---|
| AssignmentsScreen | `/assignments` | List, filter chips (All/Pending/Due Today/Overdue/Completed), FAB, add dialog | `SkeletonList`, `NetworkErrorWidget`, `EmptyAssignments` |
| AssignmentDetailsScreen | `/assignment-details/:id` | Detail layout | — |
| FocusScreen | `/profile/focus` | Timer states, preset chips, environment selector | Running, paused, completed (confirm the completion `SnackBar` uses `cc.pri`, not a hardcoded color) |
| ResourcesScreen | `/resources` | List, category filter, search | `SkeletonList`, `NetworkErrorWidget`, `EmptyResources` |
| ResourceDetailsScreen | `/resource-details` | Detail layout | — |
| SemestersListScreen | `/semesters` **and** `/internal-marks` | Both routes render the same screen — verify both independently | `EmptySubjects` (no semesters) |
| SemesterDetailsScreen | `/semester-details/:id` | Score card, marks table, subject header | See defect below |
| NotificationsScreen | `/notifications` | List, "mark all read" action | Empty list — **no empty-state widget is wired** (`EmptyNotifications` exists but is unused); confirm it doesn't look broken, just incomplete |

> 🚩 **Confirm this defect while you're here**: on `SemesterDetailsScreen`, force a query failure
> (e.g. disconnect the DB briefly if feasible, or check the code path at
> `semester_details_screen.dart:373`) and confirm it shows the *empty* state (`EmptySubjects`)
> rather than an error — meaning a real failure currently looks identical to "no data yet". This
> is asserted (skipped, pending fix) in `test/widget/slice7_redesign_test.dart`.
>
> Focus and Notifications also have no error-state path.

---

## Cross-cutting checks (do these once, not per-screen)

- [ ] **Offline first launch, no font cache**: uninstall/clear app data, disable network, launch.
      Do Plus Jakarta Sans / Newsreader / IBM Plex Mono render, or does everything fall back to
      Roboto? `google_fonts` fetches these at runtime with no bundled assets — this is expected
      to fail today (tracked as defect **A**).
- [ ] Every dialog in `lib/shared/widgets/dialogs/cc_dialogs.dart` (14 un-migrated refs) — open
      each one under Light mode.
- [ ] Every skeleton loader in `lib/shared/widgets/loading/cc_skeletons.dart` under Light mode.
- [ ] Nav bar pill/dot indicator across all 5 tabs (`ScaffoldWithNavBar`), both brightnesses.
- [ ] Android system text scale at 2.0× on the busiest screens (Dashboard, Attendance, Subject
      Details, Semester Details) — check for overflow. This pre-stages issue #15's re-scoped audit.

---

## Defect reference

These were found during exploration and are tracked as separate GitHub issues (see Phase 5 of the
QA/reconciliation plan) rather than fixed as part of this QA pass:

| Ref | Defect | Issue |
|---|---|---|
| A | Fonts fetched at runtime, no offline fallback — breaks offline-first on first launch | [#22](https://github.com/Kirito0088/college-companion/issues/22) |
| B | `EmptyNotifications` built but never wired into `NotificationsScreen` | [#23](https://github.com/Kirito0088/college-companion/issues/23) |
| C | `SemesterDetailsScreen` shows its empty state on query error | [#24](https://github.com/Kirito0088/college-companion/issues/24) |
| D | No error-state path on Attendance / Timetable / Subject Details / Focus / Notifications | [#25](https://github.com/Kirito0088/college-companion/issues/25) |
| E | ~317 un-migrated `ColorTokens.`/`RadiusTokens.` refs outside `lib/theme/` (worst: attendance evidence flow, `subjects/widgets`, `semester/screens`, shared `cc_dialogs.dart`/`cc_skeletons.dart`) | [#26](https://github.com/Kirito0088/college-companion/issues/26) |
| F | `AppTheme.darkTheme`/`lightTheme` legacy aliases hardcode `Accent.jade` | [#27](https://github.com/Kirito0088/college-companion/issues/27) |
