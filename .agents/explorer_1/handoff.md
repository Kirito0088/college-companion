# Handoff Report: StreamProviders Analysis in `backup/glass-ui`

## 1. Observation
We executed git commands (`git branch -a`, `git ls-tree -r --name-only backup/glass-ui`, `git grep -n -E "(StreamProvider|Provider<|StateNotifierProvider|NotifierProvider|StateProvider)" backup/glass-ui -- lib/`, `git show 09ebc52 --stat`, and `git show backup/glass-ui:<file>`) in `c:\Projects\college_companion`.

Key observations from branch `backup/glass-ui`:

1. **StreamProviders & Async Providers Discovered**:
   - `assignmentsStreamProvider` (`lib/features/assignments/providers/assignments_provider.dart:14`): `StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) => ref.watch(assignmentRepositoryProvider).watchAll(userId))`
   - `pendingAssignmentsStreamProvider` (`lib/features/assignments/providers/assignments_provider.dart:20`): `StreamProvider.family<List<AssignmentEntity>, String>((ref, userId) => ref.watch(assignmentRepositoryProvider).watchPending(userId))`
   - `safeBunkStreamProvider` (`lib/features/attendance/providers/attendance_provider.dart:80`): `StreamProvider.family<SafeBunkResult, String>((ref, userId) => ref.watch(attendanceRepositoryProvider).watchAll(userId).map(...))`
   - `calendarEventsStreamProvider` (`lib/features/calendar/providers/calendar_provider.dart:12`): `StreamProvider.family<List<CalendarEventEntity>, String>((ref, userId) => ref.watch(calendarRepositoryProvider).watchAll(userId))`
   - `resourcesStreamProvider` (`lib/features/resources/providers/resources_provider.dart:12`): `StreamProvider.family<List<ResourceEntity>, String>((ref, userId) => ref.watch(resourcesRepositoryProvider).watchAll(userId))`
   - `userSettingsStreamProvider` (`lib/features/settings/providers/settings_provider.dart:12`): `StreamProvider.family<UserSettingsEntity?, String>((ref, userId) => ref.watch(userSettingsRepositoryProvider).watchByUserId(userId))`
   - `dashboardSnapshotProvider` (`lib/features/dashboard/providers/dashboard_provider.dart:10`): `FutureProvider.family<DashboardSnapshot, String>((ref, userId) async => ...)` aggregating streams from calendar, assignments, and attendance.
   - `authStateProvider` (`lib/features/authentication/providers/auth_provider.dart:36`): `NotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new)`

2. **Domain Logic Helpers & Models Discovered**:
   - `SafeBunkCalculator` & `SafeBunkResult` (`lib/features/attendance/providers/attendance_provider.dart:20-77`)
   - `DashboardSnapshot`, `HeroAction`, `TimelineEvent`, `AcademicSnapshot` (`lib/features/dashboard/models/dashboard_snapshot.dart:1-130`)

3. **Prohibited Styling Code Discovered**:
   - `GlassCard` (`lib/shared/widgets/glass_card.dart`): BackdropFilter blur (sigma 12), semi-transparent glass fills (`Colors.white.withValues(alpha: 0.05)`).
   - `GlassAppBar` (`lib/shared/widgets/glass_app_bar.dart`) & `GlassChip` (`lib/shared/widgets/glass_chip.dart`).
   - Neon color tokens & radial glow gradients (`lib/theme/color_tokens.dart`): `primaryCyan` (`#00F2FE`), `secondaryViolet` (`#7F00FF`), `accentEmerald` (`#00F5A0`), `cyanRadialGlow`, `violetRadialGlow`, `emeraldRadialGlow`.

---

## 2. Logic Chain
1. **Observation**: `git grep` and `git show` revealed 6 StreamProviders (`assignmentsStreamProvider`, `pendingAssignmentsStreamProvider`, `safeBunkStreamProvider`, `calendarEventsStreamProvider`, `resourcesStreamProvider`, `userSettingsStreamProvider`) and 1 FutureProvider (`dashboardSnapshotProvider`).
2. **Logic Step**: Each StreamProvider maps directly to a Drift repository method (`watchAll`, `watchPending`, `watchByUserId`). This establishes an offline-first reactive data flow where database mutations automatically trigger UI re-renders via Riverpod streams.
3. **Observation**: `safeBunkStreamProvider` calculates safe bunks dynamically using `SafeBunkCalculator.calculate()`, and `dashboardSnapshotProvider` aggregates data from three stream providers into a `DashboardSnapshot` presentation model.
4. **Logic Step**: The calculation and snapshot models are pure Dart business/presentation logic independent of any visual rendering. They must be preserved and reused by feature engineers.
5. **Observation**: Commit `09ebc52` introduced glassmorphism widgets (`GlassCard`, `GlassAppBar`, `GlassChip`) and neon glow tokens (`primaryCyan`, `cyanRadialGlow`) alongside the data providers.
6. **Logic Step**: The data provider logic is distinct and decoupled from the visual layer. The glassmorphism and neon elements are UI styling code that MUST NOT be copied into feature branches. Standard `CCCard` and Material 3 design tokens must be used instead.

---

## 3. Caveats
- `dashboardSnapshotProvider` currently simplifies `nextBreakState` as `'In 2 hrs'` as a placeholder.
- Repository providers depend on `databaseProvider` and `syncQueueRepositoryProvider` from `lib/providers/app_providers.dart`.

---

## 4. Conclusion
The `backup/glass-ui` branch contains a complete, working set of 6 Riverpod StreamProviders, 1 snapshot FutureProvider, 1 Auth NotifierProvider, and 16 Repository providers. 

Feature UI Engineers should adopt the exact provider definitions, `SafeBunkCalculator` logic, and `DashboardSnapshot` models documented in `c:\Projects\college_companion\.agents\explorer_1\analysis.md`. However, they MUST NOT copy over any glassmorphic widgets (`GlassCard`, `GlassAppBar`, `GlassChip`) or neon glow color tokens (`primaryCyan`, `cyanRadialGlow`, etc.), relying instead on `CCCard` and standard design tokens.

---

## 5. Verification Method

### 5.1 Commands to Verify
1. **Inspect Provider Declarations**:
   ```powershell
   git show backup/glass-ui:lib/features/assignments/providers/assignments_provider.dart
   git show backup/glass-ui:lib/features/attendance/providers/attendance_provider.dart
   git show backup/glass-ui:lib/features/calendar/providers/calendar_provider.dart
   git show backup/glass-ui:lib/features/dashboard/providers/dashboard_provider.dart
   git show backup/glass-ui:lib/features/resources/providers/resources_provider.dart
   git show backup/glass-ui:lib/features/settings/providers/settings_provider.dart
   ```
2. **Run Unit Tests for Data Logic**:
   ```powershell
   flutter test test/features/safe_bunk_calculator_test.dart
   flutter test test/unit/dashboard_snapshot_test.dart
   ```

### 5.2 Files to Inspect
- `c:\Projects\college_companion\.agents\explorer_1\analysis.md`
- `lib/features/attendance/providers/attendance_provider.dart`
- `lib/features/dashboard/models/dashboard_snapshot.dart`

### 5.3 Invalidation Conditions
- If repository signatures change (e.g. `watchAll` taking different arguments), the StreamProvider definitions will require adjustments.
