# Project: College Companion Feature Completion & Bug Fix Sprint

## Architecture
- **Framework**: Flutter 3.33+ with Dart
- **State Management**: Riverpod 2.x (`StateNotifierProvider`, `StreamProvider`, `Provider`)
- **Database**: Drift 2.34 SQLite (`companion` pattern for mutations, UUID primary keys, soft-delete `deletedAt`, sync queue)
- **Routing**: GoRouter 15.x with `StatefulShellRoute.indexedStack`
- **Auth**: Supabase Google Sign-In (`ref.read(authStateProvider)`)
- **Design System**: Material 3 dark theme (`lib/theme/` tokens)

## Milestones

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Onboarding, Calendar & Assignment CRUD | R1, R2, R3 | None | PLANNED |
| M2 | Semester Complete Feature & Attendance Cleanup | R4, R9 | M1 | PLANNED |
| M3 | Notifications & Push Reminders System | R5, R6 | M1 | PLANNED |
| M4 | Focus / Pomodoro Mode & Profile Routing | R7 | M1 | PLANNED |
| M5 | Data Sync & Dashboard Integration | R8, R10 | M1, M2 | PLANNED |
| M6 | Quality Gate & Verification | All (R1-R10) | M1-M5 | PLANNED |

## Interface Contracts & Data Models
- Repositories: `create(Companion)`, `update(userId, id, data)`, `delete(userId, id)` (soft-delete), `watchAll(userId)`, `watchById(userId, id)`
- Tables: `semesters`, `subjects`, `timetable`, `attendance`, `assignments`, `calendar_events`, `resources`, `internal_marks`, `lecture_records`, `users`, `user_settings`, `sync_queue`, `sync_metadata`, `lecture_evidence`

## Code Layout
- `lib/features/onboarding/`
- `lib/features/calendar/`
- `lib/features/assignments/`
- `lib/features/semester/`
- `lib/features/attendance/`
- `lib/features/notifications/`
- `lib/features/focus/`
- `lib/features/settings/`
- `lib/features/dashboard/`
- `lib/theme/`
