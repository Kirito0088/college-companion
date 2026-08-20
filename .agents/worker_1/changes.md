# Phase 6 StreamProviders and Domain Models Changes

## Summary of Changes
Implemented and restored all Phase 6 Riverpod StreamProviders, calculation domain models (`SafeBunkResult`, `SafeBunkCalculator`), and presentation models (`DashboardSnapshot`, `HeroAction`, `TimelineEvent`, `AcademicSnapshot`) matching the offline-first reactive Drift database architecture.

## Modified & Created Files

### 1. `lib/features/assignments/providers/assignments_provider.dart`
- Retained `assignmentRepositoryProvider`.
- Added `assignmentsStreamProvider`: `StreamProvider.family<List<AssignmentEntity>, String>` calling `watchAll(userId)`.
- Added `pendingAssignmentsStreamProvider`: `StreamProvider.family<List<AssignmentEntity>, String>` calling `watchPending(userId)`.

### 2. `lib/features/attendance/providers/attendance_provider.dart`
- Retained `attendanceRepositoryProvider`.
- Added `SafeBunkResult` data class holding `attended`, `total`, `targetPercentage`, `currentPercentage`, `safeBunks`, and `mustAttend`.
- Added `SafeBunkCalculator` utility performing safe bunk logic (`calculate()`).
- Added `safeBunkStreamProvider`: `StreamProvider.family<SafeBunkResult, String>` watching `attendanceRepositoryProvider.watchAll(userId)` and processing status counts into `SafeBunkCalculator.calculate()`.

### 3. `lib/features/calendar/providers/calendar_provider.dart`
- Retained `calendarRepositoryProvider`.
- Added `calendarEventsStreamProvider`: `StreamProvider.family<List<CalendarEventEntity>, String>` calling `watchAll(userId)`.

### 4. `lib/features/resources/providers/resources_provider.dart`
- Retained `resourcesRepositoryProvider`.
- Added `resourcesStreamProvider`: `StreamProvider.family<List<ResourceEntity>, String>` calling `watchAll(userId)`.

### 5. `lib/features/settings/providers/settings_provider.dart`
- Created file and re-exported `userSettingsRepositoryProvider` from `app_providers.dart`.
- Added `userSettingsStreamProvider`: `StreamProvider.family<UserSettingsEntity?, String>` calling `watchByUserId(userId)`.

### 6. `lib/features/dashboard/providers/dashboard_provider.dart`
- Updated `dashboardSnapshotProvider` to `FutureProvider.family<DashboardSnapshot, String>`.
- Synthesizes values from `calendarEventsStreamProvider(userId).future`, `assignmentsStreamProvider(userId).future`, and `safeBunkStreamProvider(userId).future`.
- Computes today's events, next action, pending deadlines state, and academic snapshot status dynamically.

### 7. Dashboard Widgets Integration (`lib/features/dashboard/widgets/`)
- Updated `welcome_section.dart`, `next_lecture_card.dart`, `today_overview_section.dart`, and `academic_snapshot_section.dart` to read `dashboardSnapshotProvider(userId)` using `authStateProvider`'s `user.uid`.

### 8. Database Table Registrations & DAOs (`lib/database/app_database.dart` & `sync_queue_dao.dart`)
- Added missing `LectureEvidence` and `SyncMetadata` table registrations to `@DriftDatabase`.
- Fixed `DateTime` ISO string serialization in `sync_queue_dao.dart`.
- Ran `build_runner` to generate type-safe code.

## Verification
- Ran `dart analyze lib` -> 0 errors, 0 warnings.
- Ran `flutter test` -> 113 passing tests (100% success).
