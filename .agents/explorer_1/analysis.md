# Riverpod StreamProviders & State Management Analysis: `backup/glass-ui`

## Executive Summary
This document provides a comprehensive, read-only analysis of the Riverpod state management implementation in the `backup/glass-ui` branch of `c:\Projects\college_companion`. 

The `backup/glass-ui` branch contains a fully realized offline-first reactive data architecture built on top of Drift (SQLite) repositories, Supabase Auth, and Riverpod 2.x providers. It exposes **6 StreamProviders**, **1 FutureProvider**, **1 NotifierProvider**, and **16 Repository/Service Providers**.

---

## 1. Catalog of StreamProviders & Async Data Providers

### 1.1 `assignmentsStreamProvider`
* **File Path**: `lib/features/assignments/providers/assignments_provider.dart`
* **Provider Type**: `StreamProvider.family<List<AssignmentEntity>, String>`
* **Return Type**: `Stream<List<AssignmentEntity>>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Repository Call**: `repo.watchAll(userId)` on `AssignmentRepository`
* **Imports**:
  ```dart
  import 'package:college_companion/database/app_database.dart';
  import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
  import 'package:college_companion/providers/app_providers.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  ```
* **Exact Code**:
  ```dart
  final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
    final database = ref.watch(databaseProvider);
    final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
    return AssignmentRepository(database, syncQueueRepository);
  });

  /// Watches all assignments for a user.
  final assignmentsStreamProvider = StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) {
    final repo = ref.watch(assignmentRepositoryProvider);
    return repo.watchAll(userId);
  });
  ```

---

### 1.2 `pendingAssignmentsStreamProvider`
* **File Path**: `lib/features/assignments/providers/assignments_provider.dart`
* **Provider Type**: `StreamProvider.family<List<AssignmentEntity>, String>`
* **Return Type**: `Stream<List<AssignmentEntity>>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Repository Call**: `repo.watchPending(userId)` on `AssignmentRepository`
* **Imports**: Same as `assignmentsStreamProvider`
* **Exact Code**:
  ```dart
  /// Watches pending assignments for a user.
  final pendingAssignmentsStreamProvider = StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) {
    final repo = ref.watch(assignmentRepositoryProvider);
    return repo.watchPending(userId);
  });
  ```

---

### 1.3 `safeBunkStreamProvider`
* **File Path**: `lib/features/attendance/providers/attendance_provider.dart`
* **Provider Type**: `StreamProvider.family<SafeBunkResult, String>`
* **Return Type**: `Stream<SafeBunkResult>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Repository Call**: `repo.watchAll(userId)` on `AttendanceRepository`
* **Domain Calculation**: Processes `List<AttendanceEntity>` to compute attended/total counts, then delegates to `SafeBunkCalculator.calculate()`.
* **Imports**:
  ```dart
  import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
  import 'package:college_companion/providers/app_providers.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  ```
* **Helper Structures**:
  ```dart
  /// Result of a safe bunk calculation.
  class SafeBunkResult {
    const SafeBunkResult({
      required this.attended,
      required this.total,
      required this.targetPercentage,
      required this.currentPercentage,
      required this.safeBunks,
      required this.mustAttend,
    });

    final int attended;
    final int total;
    final double targetPercentage;
    final double currentPercentage;
    final int safeBunks;
    final int mustAttend;
  }

  /// Helper utility for safe bunk calculations.
  class SafeBunkCalculator {
    static SafeBunkResult calculate({
      required int attended,
      required int total,
      double targetPercentage = 75.0,
    }) {
      if (total <= 0) {
        return SafeBunkResult(
          attended: attended,
          total: total,
          targetPercentage: targetPercentage,
          currentPercentage: 0.0,
          safeBunks: 0,
          mustAttend: 0,
        );
      }

      final currentPct = (attended / total) * 100.0;
      if (currentPct >= targetPercentage) {
        final maxBunks = ((attended * 100.0 - targetPercentage * total) / targetPercentage).floor();
        return SafeBunkResult(
          attended: attended,
          total: total,
          targetPercentage: targetPercentage,
          currentPercentage: currentPct,
          safeBunks: maxBunks < 0 ? 0 : maxBunks,
          mustAttend: 0,
        );
      } else {
        final needed = ((targetPercentage * total - 100.0 * attended) / (100.0 - targetPercentage)).ceil();
        return SafeBunkResult(
          attended: attended,
          total: total,
          targetPercentage: targetPercentage,
          currentPercentage: currentPct,
          safeBunks: 0,
          mustAttend: needed < 0 ? 0 : needed,
        );
      }
    }
  }
  ```
* **Exact Code**:
  ```dart
  final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
    final database = ref.watch(databaseProvider);
    final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
    return AttendanceRepository(database, syncQueueRepository);
  });

  /// Stream provider for user attendance safe bunk calculation.
  final safeBunkStreamProvider = StreamProvider.family<SafeBunkResult, String>((ref, userId) {
    final repo = ref.watch(attendanceRepositoryProvider);
    return repo.watchAll(userId).map((list) {
      int attended = 0;
      int total = 0;
      for (final record in list) {
        if (record.primaryStatus == 'present') {
          attended++;
          total++;
        } else if (record.primaryStatus == 'absent') {
          total++;
        }
      }
      return SafeBunkCalculator.calculate(attended: attended, total: total);
    });
  });
  ```

---

### 1.4 `calendarEventsStreamProvider`
* **File Path**: `lib/features/calendar/providers/calendar_provider.dart`
* **Provider Type**: `StreamProvider.family<List<CalendarEventEntity>, String>`
* **Return Type**: `Stream<List<CalendarEventEntity>>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Repository Call**: `repo.watchAll(userId)` on `CalendarRepository`
* **Imports**:
  ```dart
  import 'package:college_companion/database/app_database.dart';
  import 'package:college_companion/features/calendar/repositories/calendar_repository.dart';
  import 'package:college_companion/providers/app_providers.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  ```
* **Exact Code**:
  ```dart
  final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
    final database = ref.watch(databaseProvider);
    final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
    return CalendarRepository(database, syncQueueRepository);
  });

  final calendarEventsStreamProvider = StreamProvider.family<List<CalendarEventEntity>, String>((ref, userId) {
    final repo = ref.watch(calendarRepositoryProvider);
    return repo.watchAll(userId);
  });
  ```

---

### 1.5 `resourcesStreamProvider`
* **File Path**: `lib/features/resources/providers/resources_provider.dart`
* **Provider Type**: `StreamProvider.family<List<ResourceEntity>, String>`
* **Return Type**: `Stream<List<ResourceEntity>>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Repository Call**: `repo.watchAll(userId)` on `ResourcesRepository`
* **Imports**:
  ```dart
  import 'package:college_companion/database/app_database.dart';
  import 'package:college_companion/features/resources/repositories/resources_repository.dart';
  import 'package:college_companion/providers/app_providers.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  ```
* **Exact Code**:
  ```dart
  final resourcesRepositoryProvider = Provider<ResourcesRepository>((ref) {
    final database = ref.watch(databaseProvider);
    final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
    return ResourcesRepository(database, syncQueueRepository);
  });

  final resourcesStreamProvider = StreamProvider.family<List<ResourceEntity>, String>((ref, userId) {
    final repo = ref.watch(resourcesRepositoryProvider);
    return repo.watchAll(userId);
  });
  ```

---

### 1.6 `userSettingsStreamProvider`
* **File Path**: `lib/features/settings/providers/settings_provider.dart`
* **Provider Type**: `StreamProvider.family<UserSettingsEntity?, String>`
* **Return Type**: `Stream<UserSettingsEntity?>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Repository Call**: `repo.watchByUserId(userId)` on `UserSettingsRepository`
* **Imports**:
  ```dart
  import 'package:college_companion/database/app_database.dart';
  import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
  import 'package:college_companion/providers/app_providers.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  ```
* **Exact Code**:
  ```dart
  final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
    final database = ref.watch(databaseProvider);
    final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
    return UserSettingsRepository(database, syncQueueRepository);
  });

  final userSettingsStreamProvider = StreamProvider.family<UserSettingsEntity?, String>((ref, userId) {
    final repo = ref.watch(userSettingsRepositoryProvider);
    return repo.watchByUserId(userId);
  });
  ```

---

### 1.7 `dashboardSnapshotProvider`
* **File Path**: `lib/features/dashboard/providers/dashboard_provider.dart`
* **Provider Type**: `FutureProvider.family<DashboardSnapshot, String>`
* **Return Type**: `Future<DashboardSnapshot>`
* **Parameters**: `ref` (`Ref`), `userId` (`String`)
* **Streams Listened**: Combines `.future` of `calendarEventsStreamProvider(userId)`, `assignmentsStreamProvider(userId)`, and `safeBunkStreamProvider(userId)`.
* **Associated Presentation Model**: `lib/features/dashboard/models/dashboard_snapshot.dart` (`DashboardSnapshot`, `HeroAction`, `TimelineEvent`, `AcademicSnapshot`)
* **Imports**:
  ```dart
  import 'package:college_companion/database/app_database.dart';
  import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
  import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
  import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
  import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:intl/intl.dart';
  ```
* **Exact Code**:
  ```dart
  final dashboardSnapshotProvider = FutureProvider.family<DashboardSnapshot, String>((ref, userId) async {
    // Watch the streams
    final calendarEvents = await ref.watch(calendarEventsStreamProvider(userId).future);
    final assignments = await ref.watch(assignmentsStreamProvider(userId).future);
    final safeBunk = await ref.watch(safeBunkStreamProvider(userId).future);

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    // 1. Process Calendar Events
    final todayEvents = calendarEvents.where((e) {
      final start = DateTime.parse(e.startDate);
      return start.isAfter(todayStart) && start.isBefore(todayEnd);
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

    CalendarEventEntity? nextEvent;
    final timelineEvents = <TimelineEvent>[];
    
    for (final event in todayEvents) {
      final start = DateTime.parse(event.startDate);
      final end = DateTime.parse(event.endDate);
      final isPast = now.isAfter(end);
      final isNow = now.isAfter(start) && now.isBefore(end);
      
      if (nextEvent == null && (isNow || now.isBefore(start))) {
        nextEvent = event;
      }
      
      timelineEvents.add(TimelineEvent(
        title: event.title,
        location: event.description ?? 'TBD',
        timeString: DateFormat('hh:mm').format(start),
        meridiem: DateFormat('a').format(start),
        isNow: isNow,
        isPast: isPast,
      ));
    }

    // 2. Next Action
    HeroAction? nextAction;
    if (nextEvent != null) {
      final start = DateTime.parse(nextEvent.startDate);
      final diff = start.difference(now);
      String urgency;
      if (diff.isNegative) {
        urgency = 'Ongoing now';
      } else if (diff.inMinutes < 60) {
        urgency = 'Starts in ${diff.inMinutes}m';
      } else {
        urgency = 'Starts in ${diff.inHours}h';
      }
      nextAction = HeroAction(
        title: nextEvent.title,
        timeString: DateFormat('hh:mm a').format(start),
        location: nextEvent.description ?? 'TBD',
        urgencyString: urgency,
      );
    }

    // 3. Process Assignments
    final pendingAssignments = assignments.where((a) => a.status != 'completed').toList();
    final dueToday = pendingAssignments.where((a) {
      final due = DateTime.parse(a.dueDate);
      return due.isAfter(todayStart) && due.isBefore(todayEnd);
    }).length;
    
    String deadlinesState = 'All clear';
    if (dueToday > 0) {
      deadlinesState = '$dueToday Due Today';
    } else if (pendingAssignments.isNotEmpty) {
      deadlinesState = '${pendingAssignments.length} Pending';
    }

    // 4. Academic Snapshot
    String attendanceState = 'On Track';
    if (safeBunk.currentPercentage < safeBunk.targetPercentage) {
      attendanceState = 'Critical (${safeBunk.currentPercentage.toStringAsFixed(0)}%)';
    } else if (safeBunk.safeBunks > 0) {
      attendanceState = '${safeBunk.safeBunks} Safe Bunks';
    }

    final workloadState = pendingAssignments.length > 3 ? 'Heavy' : 'Manageable';

    final academicSnapshot = AcademicSnapshot(
      attendanceState: attendanceState,
      workloadState: workloadState,
      deadlinesState: deadlinesState,
      nextBreakState: 'In 2 hrs', // Simplified for now
    );

    return DashboardSnapshot(
      greetingContext: '${todayEvents.length} lectures today',
      nextAction: nextAction,
      timelineEvents: timelineEvents,
      academicSnapshot: academicSnapshot,
    );
  });
  ```

---

### 1.8 `authStateProvider`
* **File Path**: `lib/features/authentication/providers/auth_provider.dart`
* **Provider Type**: `NotifierProvider<AuthStateNotifier, AuthState>`
* **Return Type**: `AuthState` (`AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`)
* **Dependencies**: `authServiceProvider`, `userRepositoryProvider`
* **Exact Code**:
  ```dart
  final authServiceProvider = Provider<AuthService>((ref) {
    return AuthService();
  });

  final userRepositoryProvider = Provider<UserRepository>((ref) {
    final database = ref.watch(databaseProvider);
    final client = ref.watch(supabaseClientProvider);
    final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
    return UserRepository(database, client, syncQueueRepository);
  });

  final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(
    AuthStateNotifier.new,
  );
  ```

---

## 2. Core Global & Feature Repository Providers

| Provider Name | File Path | Signature | Return Type | Key Dependencies |
| --- | --- | --- | --- | --- |
| `databaseProvider` | `lib/providers/app_providers.dart` | `Provider<AppDatabase>` | `AppDatabase` | `AppDatabase()` (with `ref.onDispose(database.close)`) |
| `connectivityServiceProvider` | `lib/providers/app_providers.dart` | `Provider<ConnectivityService>` | `ConnectivityService` | `ConnectivityService()` |
| `supabaseClientProvider` | `lib/providers/app_providers.dart` | `Provider<SupabaseClient>` | `SupabaseClient` | `SupabaseService.client` |
| `syncQueueRepositoryProvider` | `lib/providers/app_providers.dart` | `Provider<SyncQueueRepository>` | `SyncQueueRepository` | `databaseProvider` |
| `userSettingsRepositoryProvider` | `lib/providers/app_providers.dart` | `Provider<UserSettingsRepository>` | `UserSettingsRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `syncServiceProvider` | `lib/providers/app_providers.dart` | `Provider<SyncService>` | `SyncService` | `syncQueueRepositoryProvider`, `databaseProvider`, `connectivityServiceProvider`, `supabaseClientProvider` |
| `authServiceProvider` | `lib/features/authentication/providers/auth_provider.dart` | `Provider<AuthService>` | `AuthService` | `AuthService()` |
| `userRepositoryProvider` | `lib/features/authentication/providers/auth_provider.dart` | `Provider<UserRepository>` | `UserRepository` | `databaseProvider`, `supabaseClientProvider`, `syncQueueRepositoryProvider` |
| `assignmentRepositoryProvider` | `lib/features/assignments/providers/assignments_provider.dart` | `Provider<AssignmentRepository>` | `AssignmentRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `attendanceRepositoryProvider` | `lib/features/attendance/providers/attendance_provider.dart` | `Provider<AttendanceRepository>` | `AttendanceRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `calendarRepositoryProvider` | `lib/features/calendar/providers/calendar_provider.dart` | `Provider<CalendarRepository>` | `CalendarRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `internalMarksRepositoryProvider` | `lib/features/internal_marks/providers/internal_marks_provider.dart` | `Provider<InternalMarksRepository>` | `InternalMarksRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `resourcesRepositoryProvider` | `lib/features/resources/providers/resources_provider.dart` | `Provider<ResourcesRepository>` | `ResourcesRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `semesterRepositoryProvider` | `lib/features/semester/providers/semester_provider.dart` | `Provider<SemesterRepository>` | `SemesterRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `subjectRepositoryProvider` | `lib/features/subjects/providers/subjects_provider.dart` | `Provider<SubjectRepository>` | `SubjectRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |
| `timetableRepositoryProvider` | `lib/features/timetable/providers/timetable_provider.dart` | `Provider<TimetableRepository>` | `TimetableRepository` | `databaseProvider`, `syncQueueRepositoryProvider` |

---

## 3. Data Provider Logic vs Visual/Styling Code

### 3.1 Data Provider Logic (WHAT TO KEEP & PRESERVE)
1. **StreamProvider Definitions & Reactive Plumbing**:
   - `assignmentsStreamProvider` & `pendingAssignmentsStreamProvider`
   - `safeBunkStreamProvider` & `SafeBunkCalculator`
   - `calendarEventsStreamProvider`
   - `resourcesStreamProvider`
   - `userSettingsStreamProvider`
   - `dashboardSnapshotProvider` (FutureProvider snapshot synthesizer)
   - `authStateProvider` (`AuthStateNotifier`)
2. **Domain Models & Calculation Helpers**:
   - `SafeBunkResult` and `SafeBunkCalculator` in `attendance_provider.dart`
   - `DashboardSnapshot`, `HeroAction`, `TimelineEvent`, `AcademicSnapshot` in `dashboard_snapshot.dart`
3. **Repository Reactive Watch Calls**:
   - Drift `select().watch()` bindings that expose live database updates directly through Riverpod streams.

### 3.2 Prohibited Glassmorphism & Neon Visual Styling (WHAT MUST NOT BE COPIED OVER)
The `backup/glass-ui` branch introduced a custom dark glassmorphic visual layer that has been rejected in favor of standard Material 3 / design token widgets. The following visual elements **MUST NOT** be copied over to current implementation branches:

1. **Glassmorphic Container Components**:
   - `GlassCard` / `GlassContainer` (`lib/shared/widgets/glass_card.dart`): Uses `BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12))` and semi-transparent backgrounds (`Colors.white.withValues(alpha: 0.05)`).
   - `GlassAppBar` (`lib/shared/widgets/glass_app_bar.dart`): Custom glassmorphic navigation header with backdrop blur.
   - `GlassChip` (`lib/shared/widgets/glass_chip.dart`): Glassmorphic chip styling.
2. **Translucent Glass Fills & Borders (`ColorTokens`)**:
   - `glassSurface`, `glassSurfaceHover`, `glassSurfaceLight`, `glassSurfaceSubtle`
   - `glassBorder`, `glassBorderHigh`, `glassBorderSubtle`
   - `glassSurfaceConst`, `glassSurfaceHoverConst`, `glassBorderConst`, `glassBorderHighConst`
   - `glassSurfaceGradient`, `glassSurfaceGradientSubtle`
3. **High-Contrast Neon Accent Colors & Radial Glow Gradients (`ColorTokens`)**:
   - `#00F2FE` (`primaryCyan`), `#4FACFE` (`primaryCyanGlow`), `primaryCyanGradient`
   - `#7F00FF` (`secondaryViolet`), `#8E2DE2` (`secondaryVioletGlow`), `secondaryVioletGradient`
   - `#00F5A0` (`accentEmerald`), `#00D2FF` (`accentEmeraldGlow`), `accentEmeraldGradient`
   - `cyanRadialGlow`, `violetRadialGlow`, `emeraldRadialGlow`
   - Glowing box shadows (`BoxShadow(color: glowColor.withValues(alpha: 0.3), blurRadius: 16)`)

---

## 4. Integration Guidelines for Downstream Feature Engineers
1. **Use Standard `CCCard` & Design Tokens**: Replace any `GlassCard` or `GlassContainer` usages with `CCCard` (`lib/shared/widgets/cc_card.dart`).
2. **Consume Streams via ConsumerWidget**:
   ```dart
   final assignmentsAsync = ref.watch(assignmentsStreamProvider(userId));
   return assignmentsAsync.when(
     data: (list) => ...,
     loading: () => const CCLoadingIndicator(),
     error: (err, stack) => CCErrorWidget(error: err),
   );
   ```
3. **Preserve `SafeBunkCalculator` & Presentation Models**: All calculation algorithms (`SafeBunkCalculator.calculate`) and presentation data structures (`DashboardSnapshot`) in `backup/glass-ui` are pure Dart logic and should be retained verbatim.
