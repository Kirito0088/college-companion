import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/repositories/calendar_repository.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Provider Graph Tests', () {
    test('databaseProvider resolves to AppDatabase', () {
      expect(container.read(databaseProvider), isA<AppDatabase>());
    });

    test('syncQueueRepositoryProvider resolves to SyncQueueRepository', () {
      expect(container.read(syncQueueRepositoryProvider), isA<SyncQueueRepository>());
    });

    test('userSettingsRepositoryProvider resolves to UserSettingsRepository', () {
      expect(container.read(userSettingsRepositoryProvider), isA<UserSettingsRepository>());
    });

    test('assignmentRepositoryProvider resolves to AssignmentRepository', () {
      expect(container.read(assignmentRepositoryProvider), isA<AssignmentRepository>());
    });

    test('attendanceRepositoryProvider resolves to AttendanceRepository', () {
      expect(container.read(attendanceRepositoryProvider), isA<AttendanceRepository>());
    });

    test('calendarRepositoryProvider resolves to CalendarRepository', () {
      expect(container.read(calendarRepositoryProvider), isA<CalendarRepository>());
    });

    test('resourcesRepositoryProvider resolves to ResourcesRepository', () {
      expect(container.read(resourcesRepositoryProvider), isA<ResourcesRepository>());
    });

    test('stream providers instantiate cleanly from graph', () {
      expect(container.read(assignmentsStreamProvider('u1')), isNotNull);
      expect(container.read(safeBunkStreamProvider('u1')), isNotNull);
      expect(container.read(calendarEventsStreamProvider('u1')), isNotNull);
      expect(container.read(resourcesStreamProvider('u1')), isNotNull);
      expect(container.read(userSettingsStreamProvider('u1')), isNotNull);
      expect(container.read(dashboardSnapshotProvider('u1')), isNotNull);
    });
  });
}
