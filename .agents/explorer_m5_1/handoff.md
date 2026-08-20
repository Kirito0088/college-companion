# Handoff Report — Milestone 5 (R8 & R10 Investigation)

## 1. Observation

### R8: Settings & Sync (`lib/features/settings/screens/data_sync_screen.dart`)
- **Data Sync Screen (`lib/features/settings/screens/data_sync_screen.dart`)**:
  - `DataSyncScreen` (lines 9-106) is implemented as a `StatelessWidget` and does not connect to Riverpod providers (`ref.watch`/`ref.read`).
  - **Manual Sync (`Sync Now`)**: Line 148 contains `onPressed: () {}, // TODO: Implement manual sync`, an empty inline callback. `SyncService.syncPendingMutations()` is never invoked.
  - **Sync Preferences Toggles**: Lines 51–71 (`_SettingsSwitchRow`) use hardcoded values (`value: true`, `value: true`, `value: false`) and empty handlers `onChanged: (val) {}`.
  - **Storage & Cache Sizes**: Lines 81–95 (`_StorageInfoRow`) display hardcoded strings: `'12.4 MB'` (Local Storage), `'45.1 MB'` (Cloud Storage), and `'8.2 MB'` (Cache).
  - **Clear Cache Action**: Lines 75–97 contain no "Clear Cache" button or confirmation dialog.
  - **Last Synced Timestamp**: Line 139 contains hardcoded text `'Last synced: Today, 9:30 AM'`.

- **User Settings Repository (`lib/features/settings/repositories/user_settings_repository.dart`)**:
  - Lines 12–107 define methods `watchByUserId`, `getByUserId`, `saveSettings`, `updateTheme`, and `updateNotificationsEnabled`.
  - Missing repository helper methods for `updateAutoSync`, `updateWifiOnlySync`, and `updateBackgroundSync` to persist JSON preferences in the `preferences` column of SQLite `user_settings` table.

- **Sync Service & Metadata (`lib/services/sync_service.dart`, `lib/database/daos/sync_metadata_dao.dart`)**:
  - `SyncService` (lines 66–123) handles offline mutation flushing, but does not save or emit the timestamp of successful synchronization into `sync_metadata` table key `'last_synced_at'`.
  - `settings_screen.dart` lines 178–179 incorrectly attempts cache clearing via `await db.delete(db.userSettings).go();`, which deletes user settings rows from SQLite instead of deleting temp cache files.

---

### R10: Dashboard / Home Integration (`lib/features/dashboard/`)
- **Dashboard Screen (`lib/features/dashboard/screens/dashboard_screen.dart`)**:
  - Lines 166–212 (`_buildSuccessContent`) include `WelcomeSection`, `NextLectureCard`, `TodayOverviewSection`, and `AcademicSnapshotSection`.
  - `QuickActionsSection` (`lib/features/dashboard/widgets/quick_actions_section.dart`) is **completely omitted** from `DashboardScreen`.
- **Dashboard Provider (`lib/features/dashboard/providers/dashboard_provider.dart`)**:
  - Lines 22–38 watch `calendarEventsStreamProvider(userId)` for timeline events, but do NOT query `TimetableRepository.watchByDay(userId, dayOfWeek)` for weekly timetable slots.
  - Line 120 hardcodes `nextBreakState: 'In 2 hrs'` inside `AcademicSnapshot`.
- **Dashboard Widgets (`lib/features/dashboard/widgets/`)**:
  - `NextLectureCard` (line 56) uses `onTap: () => context.push(RoutePaths.subjectDetails)` without subject parameters.
  - `WelcomeSection` (line 60) has an empty notification bell tap callback `onPressed: () {}`.
  - `TodayOverviewSection` (lines 52–65) renders an empty list with no placeholder card when today's timeline events list is empty.

---

## 2. Logic Chain

1. **R8 Manual Sync**: `data_sync_screen.dart:148` has `onPressed: () {}`. To enable manual sync, `DataSyncScreen` must be converted to `ConsumerWidget` or `ConsumerStatefulWidget`, reading `syncServiceProvider` from `lib/providers/app_providers.dart` and invoking `ref.read(syncServiceProvider).syncPendingMutations()`.
2. **R8 Preferences State & Toggles**: `UserSettingsRepository` stores preferences in `UserSettings` table's `preferences` text column (JSON). Missing helper methods in `UserSettingsRepository` prevent updating auto-sync, Wi-Fi-only, and background-sync flags. Toggles in `data_sync_screen.dart:51-71` need to watch `userSettingsStreamProvider(userId)` and update state via repository calls.
3. **R8 Dynamic Storage & Cache**: SQLite DB file is located at `getApplicationDocumentsDirectory() + '/college_companion.db'`. Real file size can be calculated using `File.length()`. Temp cache size is calculated via `getTemporaryDirectory().stat()`. Exposing these via a `storageSizeProvider` removes the hardcoded strings at `data_sync_screen.dart:81-95`.
4. **R8 Clear Cache**: `settings_screen.dart:179` mistakenly calls `db.delete(db.userSettings).go()`. A dedicated Clear Cache tile and `CCDialogs` / `AlertDialog` confirmation dialog in `data_sync_screen.dart` will clear `getTemporaryDirectory()` contents without wiping database data.
5. **R8 Last Synced Display**: `SyncService.syncPendingMutations()` must set `'last_synced_at'` ISO string in `SyncMetadataDao`. `data_sync_screen.dart:139` must watch this timestamp and format it (e.g., "Just now", "Today, 4:30 PM", "Never").
6. **R10 Quick Actions Integration**: `QuickActionsSection` is imported nowhere in `dashboard_screen.dart`. Adding `QuickActionsSection` into `_buildSuccessContent()` with callbacks:
   - Timetable: `context.push(RoutePaths.timetable)`
   - Attendance: `context.go(RoutePaths.attendance)`
   - Assignments: `context.go(RoutePaths.assignments)`
   - Internal Marks: `context.push(RoutePaths.internalMarks)`
   restores full quick action navigation.
7. **R10 Timetable Integration**: `dashboard_provider.dart:22-38` currently ignores `timetableRepositoryProvider.watchByDay(userId, dayOfWeek)`. Combining timetable entries (resolving subject names from `SubjectRepository`) with calendar events ensures today's actual class schedule is shown in `TodayOverviewSection`.
8. **R10 Dynamic Next Break & Mock Cleanup**: Replacing `nextBreakState: 'In 2 hrs'` at `dashboard_provider.dart:120` with a calculation comparing current time to class end times resolves mock string leakage. Wiring `WelcomeSection:60` to `RoutePaths.notifications` fixes unhandled icon taps.

---

## 3. Caveats
- No existing native background sync service (WorkManager / JobScheduler) is configured for Android/iOS background execution yet; background sync toggle in user settings will record user preference in SQLite database for future background task schedulers.
- Route `/timetable` in `lib/routing/app_router.dart:285` points to `PlaceholderScreen(title: 'Timetable')`. Navigating to timetable from Quick Actions will display this screen until a full Timetable grid screen is created.

---

## 4. Conclusion

- **R8**: `data_sync_screen.dart` is static visual placeholder UI. Implementing Riverpod integration, manual sync trigger, toggle persistence in `UserSettingsRepository`, dynamic DB & temp directory file size measurement, Clear Cache dialog + temp folder purge, and last synced timestamp tracking from `SyncMetadataDao` completes R8 data sync & settings requirements.
- **R10**: `DashboardScreen` is missing `QuickActionsSection`, and `dashboard_provider.dart` lacks `TimetableRepository` schedule integration and hardcodes `nextBreakState`. Restoring `QuickActionsSection`, fetching today's timetable entries, calculating next break dynamically, and binding notification icon navigation completes R10.

---

## 5. Verification Method

### Recommended Fix Strategy & Code Snippets

#### 1. R8: `UserSettingsRepository` Updates (`lib/features/settings/repositories/user_settings_repository.dart`)
Add preferences helper methods:
```dart
Future<void> updateSyncPreference(String userId, String key, bool value) async {
  final current = await getByUserId(userId);
  Map<String, dynamic> prefs = {};
  if (current != null && current.preferences.isNotEmpty) {
    try {
      prefs = jsonDecode(current.preferences) as Map<String, dynamic>;
    } catch (_) {}
  }
  prefs[key] = value;
  final now = DateTime.now().toUtc().toIso8601String();
  await saveSettings(UserSettingsCompanion(
    id: Value(current?.id ?? 'settings_$userId'),
    userId: Value(userId),
    preferences: Value(jsonEncode(prefs)),
    updatedAt: Value(now),
  ));
}
```

#### 2. R8: Storage Size & Clear Cache Utility (`lib/features/settings/providers/settings_provider.dart`)
```dart
final storageSizeProvider = FutureProvider<({String localSize, String cacheSize})>((ref) async {
  final docDir = await getApplicationDocumentsDirectory();
  final tempDir = await getTemporaryDirectory();
  
  final dbFile = File('${docDir.path}/college_companion.db');
  int dbBytes = dbFile.existsSync() ? await dbFile.length() : 0;
  
  int cacheBytes = 0;
  if (tempDir.existsSync()) {
    await for (final entity in tempDir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        cacheBytes += await entity.length();
      }
    }
  }
  
  return (
    localSize: '${(dbBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
    cacheSize: '${(cacheBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
  );
});
```

#### 3. R10: Add `QuickActionsSection` in `DashboardScreen` (`lib/features/dashboard/screens/dashboard_screen.dart`)
In `_buildSuccessContent()`:
```dart
// Quick Actions
FadeTransition(
  opacity: _heroOpacity,
  child: QuickActionsSection(
    onTimetablePressed: () => context.push(RoutePaths.timetable),
    onAttendancePressed: () => context.go(RoutePaths.attendance),
    onAssignmentsPressed: () => context.go(RoutePaths.assignments),
    onMarksPressed: () => context.push(RoutePaths.internalMarks),
  ),
),
const SizedBox(height: SpacingTokens.xxl),
```

### Verification Commands
```bash
# Run unit and widget tests
flutter test test/unit/dashboard_snapshot_test.dart
flutter test test/widget/dashboard_widgets_test.dart
flutter test test/unit/database/user_settings_repository_test.dart
flutter test test/unit/services/sync_service_test.dart

# Run static analysis
dart analyze lib/features/settings lib/features/dashboard lib/services
```
