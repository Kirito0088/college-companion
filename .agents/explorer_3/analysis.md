# Static Analysis and Test Suite Audit Analysis Report

**Project**: `c:\Projects\college_companion`  
**Explorer**: Explorer 3 (Test & Static Analysis Explorer)  
**Date**: 2026-07-24  

---

## Executive Summary

1. **Static Analysis (`dart analyze lib` & `dart analyze`)**:  
   - `dart analyze lib` found **40 issues** (18 errors, 8 warnings, 14 infos).  
   - Whole-project `dart analyze` found **95 issues** (errors in DAO files + test directory compilation errors).
   - Main compilation errors in `lib/` reside in `lib/database/daos/` (`lecture_evidence_dao.dart`, `sync_metadata_dao.dart`, `sync_queue_dao.dart`).
   - Main errors in `test/` reside in `test/features/provider_graph_test.dart`, `test/support/test_db.dart`, and `test/database/` tests due to missing required schema fields (`createdAt`, `updatedAt`) and undefined providers/DAOs.

2. **Test Suite (`flutter test`)**:  
   - **113 unit/widget/repository tests PASSED**.
   - **8 test files FAILED** due to compile-time errors (database schema tests, provider graph test, attendance read model test, lecture record repository test).
   - Core repository unit tests (`assignments`, `attendance`, `calendar`, `internal_marks`, `resources`, `semesters`, `subjects`, `sync_queue`, `timetable`, `user`, `user_settings`), sync service tests, stress tests, and snapshot tests pass cleanly.

3. **Coverage Overview**:  
   - **Providers**: 6 covered in unit/graph tests (`databaseProvider`, DAO providers, repository providers, `authStateProvider`, `connectivityServiceProvider`, `syncServiceProvider`). 8 feature repository providers lack dedicated provider graph unit tests.
   - **Screens**: 3/29 screens covered by widget tests (`LoginScreen`, `OnboardingScreen`, `DashboardScreen` components). 26 screens currently lack widget test coverage.

---

## Section 1: Static Analysis Status (`dart analyze lib` & `dart analyze`)

### 1.1 Breakdown of `lib/` Errors (18 errors, 8 warnings, 14 infos)
- **`lib/database/daos/lecture_evidence_dao.dart`** (9 errors, 5 warnings):
  - Undefined class `LectureEvidenceCompanion` (lines 33, 45, 58).
  - Undefined getter `lectureEvidence` on `AppDatabase` (lines 35, 43, 56).
  - Undefined getter `id` on `Table` (lines 44, 57).
  - Return type mismatch for `create` (`dynamic` vs `Future<String>`) (line 37).
- **`lib/database/daos/sync_metadata_dao.dart`** (7 errors, 3 warnings):
  - Undefined getter `syncMetadata` on `AppDatabase` (lines 20, 28, 41).
  - Undefined getter `key` on `HasResultSet` / `Table` (lines 21, 42).
  - Undefined method `SyncMetadataCompanion` (line 30).
  - Return type mismatch for `get` (`dynamic` vs `Future<String?>`) (line 22).
- **`lib/database/daos/sync_queue_dao.dart`** (2 errors):
  - Line 74: `lastAttempt: Value(DateTime.now().toUtc())` — `DateTime` passed to `String?` parameter.
  - Line 83: `t.createdAt.isSmallerThanValue(before)` — `DateTime` passed to `String` parameter.

### 1.2 Breakdown of `test/` Errors (55 issues across test files)
- **`test/features/provider_graph_test.dart`**:
  - Undefined provider names: `lectureEvidenceDaoProvider`, `syncQueueDaoProvider`, `syncMetadataDaoProvider`, `syncRepositoryProvider`, `lectureRecordRepositoryProvider`.
  - Undefined method `getSubjectStats` on `AttendanceRepository`.
- **`test/support/test_db.dart`**:
  - Argument type `LectureRecordDao` cannot be assigned to `AppDatabase` when constructing `AttendanceRepository`.
  - Missing required named arguments `createdAt` and `updatedAt` on `UsersCompanion.insert`, `SemestersCompanion.insert`, `SubjectsCompanion.insert`, `TimetableCompanion.insert`.
- **`test/database/` files (`constraints_test.dart`, `immutability_test.dart`, `persistence_test.dart`, `schema_test.dart`)**:
  - Missing required named argument `createdAt` across companion `insert()` calls.

---

## Section 2: Test Suite Execution (`flutter test`)

Execution of `flutter test` resulted in:
- **113 Passing Tests**
- **8 Failing Test Files** (Compilation level failures)

### 2.1 Test Directory Structure & Files Inventory

```
test/
├── database/
│   ├── constraints_test.dart            (FAIL - compilation error: missing createdAt)
│   ├── immutability_test.dart           (FAIL - compilation error: missing createdAt)
│   ├── persistence_test.dart            (FAIL - compilation error: missing createdAt)
│   └── schema_test.dart                 (FAIL - compilation error: missing createdAt)
├── features/
│   ├── attendance_read_model_test.dart  (FAIL - compilation error)
│   ├── lecture_record_repository_test.dart (FAIL - compilation error)
│   └── provider_graph_test.dart         (FAIL - compilation error: unresolvable DAO providers)
├── support/
│   └── test_db.dart                     (FAIL helper - argument type mismatch for AttendanceRepository)
├── unit/
│   ├── app_constants_test.dart          (PASS)
│   ├── dashboard_snapshot_test.dart     (PASS)
│   ├── edge_cases_test.dart             (PASS)
│   ├── database/
│   │   ├── assignments_repository_test.dart               (PASS)
│   │   ├── attendance_repository_test.dart                (PASS)
│   │   ├── calendar_repository_test.dart                  (PASS)
│   │   ├── database_migration_test.dart                   (PASS)
│   │   ├── drift_phase4_empirical_stress_test.dart        (PASS)
│   │   ├── internal_marks_repository_test.dart            (PASS)
│   │   ├── resources_repository_test.dart                 (PASS)
│   │   ├── semesters_repository_test.dart                 (PASS)
│   │   ├── subjects_repository_test.dart                  (PASS)
│   │   ├── sync_queue_repository_test.dart                (PASS)
│   │   ├── timetable_repository_test.dart                 (PASS)
│   │   ├── user_repository_test.dart                      (PASS)
│   │   └── user_settings_repository_test.dart             (PASS)
│   └── services/
│       ├── sync_service_empirical_stress_test.dart        (PASS)
│       └── sync_service_test.dart                         (PASS)
└── widget/
    ├── app_theme_test.dart              (PASS)
    ├── dashboard_widgets_test.dart      (PASS)
    ├── login_screen_test.dart           (PASS)
    └── onboarding_screen_test.dart      (PASS)
```

---

## Section 3: Screen & Provider Test Coverage Inventory

### 3.1 Riverpod Providers Coverage

| Provider Name | Location | Coverage Status | Test Location / Notes |
|---|---|---|---|
| `databaseProvider` | `lib/providers/app_providers.dart` | Covered | `provider_graph_test.dart` (overridden with `NativeDatabase.memory()`) |
| `connectivityServiceProvider` | `lib/providers/app_providers.dart` | Covered | Tested via `FakeConnectivityService` in `sync_service_test.dart` |
| `supabaseClientProvider` | `lib/providers/app_providers.dart` | Covered | Tested via `FakeSupabaseClient` in `sync_service_test.dart` |
| `syncQueueRepositoryProvider` | `lib/providers/app_providers.dart` | Covered | Tested in `sync_queue_repository_test.dart` |
| `userSettingsRepositoryProvider` | `lib/providers/app_providers.dart` | Covered | Tested in `user_settings_repository_test.dart` |
| `syncServiceProvider` | `lib/providers/app_providers.dart` | Covered | Tested in `sync_service_test.dart` |
| `authStateProvider` | `lib/features/authentication/providers/auth_provider.dart` | Covered | Overridden via `_FakeAuthStateNotifier` in widget tests |
| `attendanceRepositoryProvider` | `lib/features/attendance/providers/attendance_provider.dart` | Covered | `attendance_repository_test.dart`, `provider_graph_test.dart` |
| `assignmentRepositoryProvider` | `lib/features/assignments/providers/assignments_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |
| `calendarRepositoryProvider` | `lib/features/calendar/providers/calendar_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |
| `dashboardSnapshotProvider` | `lib/features/dashboard/providers/dashboard_provider.dart` | **Missing** | Model tested in `dashboard_snapshot_test.dart`, provider omitted |
| `internalMarksRepositoryProvider` | `lib/features/internal_marks/providers/internal_marks_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |
| `resourcesRepositoryProvider` | `lib/features/resources/providers/resources_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |
| `semesterRepositoryProvider` | `lib/features/semester/providers/semester_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |
| `subjectRepositoryProvider` | `lib/features/subjects/providers/subjects_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |
| `timetableRepositoryProvider` | `lib/features/timetable/providers/timetable_provider.dart` | **Missing** | Repository tested directly, provider graph omitted |

### 3.2 Screen Widget Test Coverage

| Screen Name | Path | Widget Test Status | Test File |
|---|---|---|---|
| `LoginScreen` | `lib/features/authentication/screens/login_screen.dart` | Covered | `test/widget/login_screen_test.dart` |
| `OnboardingScreen` | `lib/features/onboarding/screens/onboarding_screen.dart` | Covered | `test/widget/onboarding_screen_test.dart` |
| `DashboardScreen` (widgets) | `lib/features/dashboard/screens/dashboard_screen.dart` | Covered | `test/widget/dashboard_widgets_test.dart` |
| `SplashScreen` | `lib/features/authentication/screens/splash_screen.dart` | **Missing** | None |
| `AssignmentDetailsScreen` | `lib/features/assignments/screens/assignment_details_screen.dart` | **Missing** | None |
| `AssignmentsScreen` | `lib/features/assignments/screens/assignments_screen.dart` | **Missing** | None |
| `AttendanceScreen` | `lib/features/attendance/screens/attendance_screen.dart` | **Missing** | None |
| `LectureRecordScreen` | `lib/features/attendance/screens/lecture_record_screen.dart` | **Missing** | None |
| `SafeBunkScreen` | `lib/features/attendance/screens/safe_bunk_screen.dart` | **Missing** | None |
| `AddEditEventScreen` | `lib/features/calendar/screens/add_edit_event_screen.dart` | **Missing** | None |
| `CalendarScreen` | `lib/features/calendar/screens/calendar_screen.dart` | **Missing** | None |
| `EventDetailsScreen` | `lib/features/calendar/screens/event_details_screen.dart` | **Missing** | None |
| `FocusScreen` | `lib/features/focus/screens/focus_screen.dart` | **Missing** | None |
| `NotificationsScreen` | `lib/features/notifications/screens/notifications_screen.dart` | **Missing** | None |
| `AboutScreen` | `lib/features/profile/screens/about_screen.dart` | **Missing** | None |
| `AccountInformationScreen` | `lib/features/profile/screens/account_information_screen.dart` | **Missing** | None |
| `HelpSupportScreen` | `lib/features/profile/screens/help_support_screen.dart` | **Missing** | None |
| `ProfileScreen` | `lib/features/profile/screens/profile_screen.dart` | **Missing** | None |
| `ResourceDetailsScreen` | `lib/features/resources/screens/resource_details_screen.dart` | **Missing** | None |
| `ResourcesScreen` | `lib/features/resources/screens/resources_screen.dart` | **Missing** | None |
| `SemesterDetailsScreen` | `lib/features/semester/screens/semester_details_screen.dart` | **Missing** | None |
| `SemestersListScreen` | `lib/features/semester/screens/semesters_list_screen.dart` | **Missing** | None |
| `DataSyncScreen` | `lib/features/settings/screens/data_sync_screen.dart` | **Missing** | None |
| `OpenSourceLicensesScreen` | `lib/features/settings/screens/open_source_licenses_screen.dart` | **Missing** | None |
| `PrivacyPolicyScreen` | `lib/features/settings/screens/privacy_policy_screen.dart` | **Missing** | None |
| `SettingsScreen` | `lib/features/settings/screens/settings_screen.dart` | **Missing** | None |
| `TermsConditionsScreen` | `lib/features/settings/screens/terms_conditions_screen.dart` | **Missing** | None |
| `SubjectDetailsScreen` | `lib/features/subjects/screens/subject_details_screen.dart` | **Missing** | None |
| `PlaceholderScreen` | `lib/shared/widgets/placeholder_screen.dart` | **Missing** | None |

**Total Screens**: 29  
**Covered Screens**: 3 (10.3%)  
**Missing Screens**: 26 (89.7%)  

---

## Section 4: Riverpod Mocking & Override Patterns in Existing Tests

In the codebase, Riverpod providers are tested and overridden using three distinct patterns:

### Pattern 1: `ProviderContainer` with In-Memory Overrides (Graph & Integration Unit Tests)
Used in `test/features/provider_graph_test.dart` to instantiate providers in isolation without Flutter UI bindings:
```dart
late ProviderContainer container;
late AppDatabase db;

setUp(() {
  db = AppDatabase.forTesting(NativeDatabase.memory());
  container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );
});

tearDown(() async {
  container.dispose();
  await db.close();
});
```

### Pattern 2: `ProviderScope` with Subclassed Fake Notifiers (Widget Tests)
Used in `test/widget/login_screen_test.dart` and `test/widget/dashboard_widgets_test.dart` to isolate widget tree rendering from async auth/state logic:
```dart
class _FakeAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      authStateProvider.overrideWith(_FakeAuthStateNotifier.new),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    ),
  ),
);
```

### Pattern 3: Custom Fake / Mock Class Implementations for Dependencies
Used in `test/unit/services/sync_service_test.dart` and `test/unit/services/sync_service_empirical_stress_test.dart` where concrete dependencies (`ConnectivityService`, `SupabaseClient`) are mocked via `Fake` classes:
```dart
class FakeConnectivityService implements ConnectivityService { ... }
class FakeSupabaseClient extends Fake implements SupabaseClient { ... }
```

---

## Section 5: Recommendations & Action Items

1. **Fix DAO compilation errors in `lib/`**:
   - Update `lib/database/daos/lecture_evidence_dao.dart` and `lib/database/daos/sync_metadata_dao.dart` to match updated schema or regenerate `app_database.g.dart`.
   - Fix `DateTime` string conversions in `lib/database/daos/sync_queue_dao.dart`.
2. **Fix schema drift in test database companions**:
   - Update companion calls in `test/database/constraints_test.dart`, `test/database/immutability_test.dart`, `test/database/persistence_test.dart`, `test/database/schema_test.dart`, and `test/support/test_db.dart` to include required `createdAt` and `updatedAt` values.
   - Fix `AttendanceRepository` instantiation in `test/support/test_db.dart`.
3. **Expand Widget Test Coverage**:
   - Add widget tests for key user flows (`AttendanceScreen`, `AssignmentsScreen`, `CalendarScreen`, `SettingsScreen`).
4. **Expand Provider Graph Tests**:
   - Add provider verification tests for remaining feature repository providers in `test/features/provider_graph_test.dart`.
