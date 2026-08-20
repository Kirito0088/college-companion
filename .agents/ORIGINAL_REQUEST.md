# Original User Request

## 2026-07-24T11:19:00Z

# College Companion — Feature Completion & Bug Fix Sprint

Fix 10 broken/placeholder features in the College Companion Flutter app — a local-first student productivity app using Flutter 3.33+, Riverpod 2.x (StateNotifierProvider pattern), Drift 2.34 SQLite, Supabase auth, GoRouter 15.x, and Material 3 dark theme with custom design tokens.

Working directory: c:\Projects\college_companion
Integrity mode: development

## Tech Stack & Architecture Context

- **State Management**: Riverpod 2.x with `StateNotifierProvider`, `StreamProvider`, and `Provider`
- **Database**: Drift 2.34 SQLite with companion pattern (`XxxCompanion`) for inserts, UUID primary keys, soft-delete (`deletedAt`), and sync queue
- **Routing**: GoRouter 15.x with `StatefulShellRoute.indexedStack` for bottom nav tabs
- **Auth**: Supabase Google Sign-In; user ID available via `ref.read(authStateProvider)` as `AuthAuthenticated.userId`
- **Design**: Material 3 dark theme using custom tokens in `lib/theme/` (`ColorTokens`, `SpacingTokens`, `RadiusTokens`, `TypographyTokens`)
- **Existing patterns**: Repositories follow `create(Companion)`, `update(userId, id, data)`, `delete(userId, id)` (soft-delete), `watchAll(userId)`, `watchById(userId, id)` pattern
- **Existing tables**: `semesters`, `subjects`, `timetable`, `attendance`, `assignments`, `calendar_events`, `resources`, `internal_marks`, `lecture_records`, `users`, `user_settings`, `sync_queue`, `sync_metadata`, `lecture_evidence`

## Requirements

### R1. Onboarding — Fix "Continue" Button Label
The last page of the onboarding flow (`_ReadyPage` in `lib/features/onboarding/screens/onboarding_screen.dart`) has a `FilledButton` labeled `'Start'` that calls `_finishOnboarding()`. Rename the button text to `'Get Started'` or `'Continue to App'` so the user understands it exits onboarding. The button already functions correctly — this is a label-only fix.

### R2. Calendar — Delete Event + UI/UX Improvement
The event details screen (`lib/features/calendar/screens/event_details_screen.dart`) displays hardcoded static data and has a delete button that only calls `context.pop()` without actually deleting from the database. Fix this by:
- Accepting the event ID via GoRouter route parameters (e.g., `state.pathParameters['id']`)
- Loading real event data from `CalendarRepository.getById(userId, eventId)` or a stream
- Implementing actual database deletion via `CalendarRepository.delete(userId, eventId)` on confirm
- Improving the delete confirmation dialog UI to follow Material 3 design with proper typography, spacing, and destructive action styling (red accent for delete button)

### R3. Assignments — CRUD Operations + UI/UX Improvement
The assignment details screen (`lib/features/assignments/screens/assignment_details_screen.dart`) is fully hardcoded with TODO callbacks for Mark Complete, Edit, and Delete. Fix this by:
- Accepting assignment ID via GoRouter route parameters
- Loading real assignment data from `AssignmentRepository`
- Implementing Mark Complete via `AssignmentRepository.markCompleted(userId, assignmentId)`
- Implementing Edit (navigate to edit form or inline editing)
- Implementing Delete via `AssignmentRepository.delete(userId, assignmentId)` with confirmation dialog
- Improving overall UI/UX with proper Material 3 styling, status chips that reflect real state, and smooth transitions

### R4. Semester Feature — Complete Implementation
The semester feature needs major completion:
- **Semester Details Screen** (`lib/features/semester/screens/semester_details_screen.dart`): Currently 100% hardcoded. Must accept semester ID via router, load real data from `SemesterRepository`, and display actual subjects, progress, and dates
- **Add Subject Dialog**: Create a dialog/bottom sheet for adding subjects within a semester (fields: name, type [theory/lab/elective], credits, color). Use `SubjectRepository.create(SubjectsCompanion)`
- **Add Timetable Slots**: Allow adding timetable entries per subject (day of week, start time, end time, room). Use `TimetableRepository.create(TimetableCompanion)`
- **Semester Dates**: Add start date and expected completion date fields to semester creation/editing dialogs
- **Important Dates**: Allow adding exam dates and deadlines that can be managed anytime within a semester
- **Edit Semester**: Enable editing existing semester entries (name, dates, subjects)
- **Overall Status Metrics**: Replace the hardcoded "This Week" metrics (Classes, Completed, Remaining) with overall semester progress (total subjects, total credits, overall attendance %, assignment completion rate)

### R5. Notifications — Real Working Feature
The notifications screen (`lib/features/notifications/screens/notifications_screen.dart`) is 100% static placeholder data. Replace with:
- A real notification data model and local storage (can use a Drift table or SharedPreferences)
- Generate notifications from real events: upcoming lectures (from timetable), assignment due dates (from assignments), calendar events, low attendance warnings
- "Mark all as read" functionality
- Individual notification tap should navigate to the relevant screen (e.g., tapping an assignment notification goes to assignment details)

### R6. Push Notifications — System Permission + Lecture Reminders
- Add `flutter_local_notifications` package dependency
- On enabling Push Notifications toggle in Settings, request Android system notification permission (using `flutter_local_notifications` or `permission_handler`)
- Schedule local notifications for:
  - Lecture reminders: 15 minutes before each timetable slot
  - Assignment due date reminders: morning of due date
  - Calendar event reminders: based on event start time
- Persist the lecture reminders toggle to the database (currently only local state)

### R7. Focus/Pomodoro Mode — Full Feature
Move Focus Mode from its current location to `Profile > Focus Mode` in the navigation. Implement a fully functional Pomodoro timer:
- Real countdown timer using `dart:async` Timer
- Configurable work duration (default 25 min) and break duration (default 5 min)
- Session counter tracking completed focus sessions
- Timer state management (running, paused, break, idle)
- Local notification when timer completes
- Session history stored locally (date, duration, subject tag)
- Update the routing in `app_router.dart` and the profile menu to reflect the new location

### R8. Sync Data & Clear Cache — Functional Implementation
In `lib/features/settings/screens/data_sync_screen.dart`:
- **Sync Now**: Trigger `SyncService.syncPendingMutations()` and show real sync progress/status
- **Auto Sync / Wi-Fi Only / Background Sync toggles**: Persist to `UserSettingsRepository`
- **Storage info**: Calculate real storage sizes from SQLite database file
- **Clear Cache**: Implement full cache clearing (delete all local data except user auth, reset sync state, show confirmation)
- **Last synced timestamp**: Store and display the real last sync time

### R9. Attendance — Strip Placeholders, Full Functionality
In `lib/features/attendance/screens/attendance_screen.dart`:
- Remove all hardcoded fallback subject cards ("Operating Systems 84%", "DBMS 96%", etc.)
- When no subjects exist, show an empty state with a prompt to add subjects via the semester feature
- Fix the Overview tab's hardcoded insight text to use real data
- Ensure quick action buttons (Record, History, Safe Bunk) are fully functional
- Zero-attendance subjects should show 0% with appropriate visual indicator, not fake 85%

### R10. Home/Dashboard — Proper Page with Real Data
In `lib/features/dashboard/`:
- Ensure all dashboard widgets show real data from providers (today's classes from timetable, upcoming assignments, attendance summary)
- Remove any remaining placeholder/mock data
- Add functional quick actions (Record Attendance, Add Assignment, etc.)
- Show today's schedule from timetable data
- Show upcoming assignment deadlines from assignment repository
- Display overall attendance percentage from real attendance records

## Acceptance Criteria

### Bug Fixes (R1-R3)
- [ ] Onboarding last page button reads "Get Started" or "Continue to App"
- [ ] Calendar event details screen loads real event data from Drift database
- [ ] Calendar delete event actually removes the event from SQLite and the list updates reactively
- [ ] Assignment details screen loads real assignment data from Drift database
- [ ] Mark Complete changes assignment status to 'completed' in SQLite
- [ ] Edit navigates to an edit form and saves changes to SQLite
- [ ] Delete removes assignment from SQLite with reactive list update
- [ ] All confirmation dialogs follow Material 3 design guidelines

### Semester Feature (R4)
- [ ] Semester details screen displays real data loaded by semester ID
- [ ] Add Subject dialog creates subjects in SQLite via SubjectRepository
- [ ] Timetable slots can be added per subject
- [ ] Semester start date and completion date are editable
- [ ] Important dates can be added and managed within a semester
- [ ] Overall semester metrics (total subjects, attendance %, assignment completion) replace "This Week" section

### Notifications & Push (R5-R6)
- [ ] Notifications screen shows real notification items generated from app data
- [ ] "Mark all as read" clears notification indicators
- [ ] Tapping a notification navigates to the relevant detail screen
- [ ] Enabling push notifications requests Android system permission
- [ ] Lecture reminders fire 15 minutes before timetable slots
- [ ] Assignment due date notifications fire on the morning of the due date

### Focus/Pomodoro (R7)
- [ ] Timer counts down in real-time from configurable duration
- [ ] Play/Pause/Stop controls work correctly
- [ ] Session counter increments on completed focus sessions
- [ ] Break timer starts automatically after work session completes
- [ ] Session history is persisted locally
- [ ] Focus mode is accessible from Profile menu, not from previous location

### Data & Sync (R8)
- [ ] "Sync Now" triggers SyncService and shows real progress
- [ ] Sync preference toggles persist to database
- [ ] Storage info shows real database file sizes
- [ ] Clear Cache removes local data with confirmation dialog

### Attendance (R9)
- [ ] No hardcoded subject cards or fake percentages remain
- [ ] Empty state shows when no subjects exist
- [ ] Zero-attendance subjects display 0% not 85%
- [ ] Quick action buttons navigate to functional screens

### Dashboard (R10)
- [ ] Today's classes come from real timetable data
- [ ] Upcoming assignments come from real assignment data
- [ ] Attendance summary reflects real attendance records
- [ ] Quick actions navigate to functional creation flows
- [ ] No placeholder/mock data remains

### Quality Gate
- [ ] `dart analyze lib` reports 0 errors (warnings/infos acceptable)
- [ ] `flutter test` — all existing tests pass (0 regressions)
- [ ] No new `// TODO` comments introduced without justification
- [ ] All new UI follows existing Material 3 dark theme design tokens
