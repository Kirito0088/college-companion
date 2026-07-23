import 'dart:async';
import 'dart:math';

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/attendance/repositories/attendance_repository.dart';
import 'package:college_companion/features/authentication/repositories/user_repository.dart';
import 'package:college_companion/features/calendar/repositories/calendar_repository.dart';
import 'package:college_companion/features/internal_marks/repositories/internal_marks_repository.dart';
import 'package:college_companion/features/resources/repositories/resources_repository.dart';
import 'package:college_companion/features/semester/repositories/semesters_repository.dart';
import 'package:college_companion/features/settings/repositories/user_settings_repository.dart';
import 'package:college_companion/features/subjects/repositories/subjects_repository.dart';
import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:college_companion/services/connectivity_service.dart';
import 'package:college_companion/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestConnectivityService implements ConnectivityService {
  final StreamController<InternetStatus> _controller =
      StreamController<InternetStatus>.broadcast();
  bool isConnected = true;

  @override
  Future<bool> get hasInternetAccess async => isConnected;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([]);

  @override
  Stream<InternetStatus> get onStatusChange => _controller.stream;

  void emitStatus(InternetStatus status) {
    isConnected = status == InternetStatus.connected;
    _controller.add(status);
  }

  void dispose() {
    _controller.close();
  }
}

class TestSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, List<Map<String, dynamic>>> upsertedPayloads = {};
  final Map<String, List<String>> deletedIds = {};
  bool shouldThrow = false;
  int callCount = 0;
  String? failOnRecordId;

  @override
  SupabaseQueryBuilder from(String table) {
    callCount++;
    if (shouldThrow) {
      throw Exception('Supabase connection network failure');
    }
    return TestSupabaseQueryBuilder(table, this);
  }
}

class TestSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  TestSupabaseQueryBuilder(this.table, this.client);
  final String table;
  final TestSupabaseClient client;

  @override
  PostgrestFilterBuilder<dynamic> upsert(
    Object values, {
    String? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = false,
  }) {
    if (client.shouldThrow) throw Exception('Supabase connection network failure');
    if (values is Map<String, dynamic>) {
      if (client.failOnRecordId != null && values['id'] == client.failOnRecordId) {
        throw Exception('Simulated failure for record ${client.failOnRecordId}');
      }
      client.upsertedPayloads.putIfAbsent(table, () => []).add(values);
    }
    return TestPostgrestFilterBuilder();
  }

  @override
  PostgrestFilterBuilder<dynamic> delete({String? count}) {
    if (client.shouldThrow) throw Exception('Supabase connection network failure');
    return TestPostgrestFilterBuilder(onEq: (column, value) {
      if (column == 'id') {
        if (client.failOnRecordId != null && value.toString() == client.failOnRecordId) {
          throw Exception('Simulated delete failure for record ${client.failOnRecordId}');
        }
        client.deletedIds.putIfAbsent(table, () => []).add(value.toString());
      }
    });
  }
}

class TestPostgrestFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  TestPostgrestFilterBuilder({this.onEq});
  final void Function(String column, dynamic value)? onEq;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    onEq?.call(column, value);
    return this;
  }

  @override
  Future<U> then<U>(
    FutureOr<U> Function(T value) onFulfilled, {
    Function? onError,
  }) {
    return Future<T>.value(null as T).then<U>(onFulfilled, onError: onError);
  }
}

void main() {
  late AppDatabase database;
  late SyncQueueRepository syncQueueRepository;
  late TestConnectivityService connectivityService;
  late TestSupabaseClient supabaseClient;
  late SyncService syncService;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncQueueRepository = SyncQueueRepository(database);
    connectivityService = TestConnectivityService();
    supabaseClient = TestSupabaseClient();
    syncService = SyncService(
      syncQueueRepository: syncQueueRepository,
      database: database,
      supabaseClient: supabaseClient,
      connectivityService: connectivityService,
    );
  });

  tearDown(() async {
    syncService.dispose();
    connectivityService.dispose();
    await database.close();
  });

  group('EMPIRICAL STRESS TEST 1: SyncQueue Enqueueing Across All Domain Repositories', () {
    test('Offline repo mutations enqueue SyncQueueItems across all 10 domain repositories', () async {
      connectivityService.isConnected = false; // Device is offline
      final now = DateTime.now().toUtc().toIso8601String();

      // 1. Semesters Repository
      final semestersRepo = SemesterRepository(database, syncQueueRepository);
      final semId = await semestersRepo.create(SemestersCompanion(
        id: const Value('sem_stress_1'),
        userId: const Value('user_stress_1'),
        name: const Value('Fall 2026'),
        workingDays: const Value('[0,1,2,3,4]'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await semestersRepo.update(
        'user_stress_1',
        semId,
        const SemestersCompanion(name: Value('Fall 2026 Updated')),
      );

      // 2. Subjects Repository
      final subjectsRepo = SubjectRepository(database, syncQueueRepository);
      final subId = await subjectsRepo.create(SubjectsCompanion(
        id: const Value('sub_stress_1'),
        userId: const Value('user_stress_1'),
        semesterId: Value(semId),
        name: const Value('Algorithms'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await subjectsRepo.update(
        'user_stress_1',
        subId,
        const SubjectsCompanion(name: Value('Advanced Algorithms')),
      );

      // 3. Attendance Repository
      final attendanceRepo = AttendanceRepository(database, syncQueueRepository);
      final attId = await attendanceRepo.create(AttendanceCompanion(
        id: const Value('att_stress_1'),
        userId: const Value('user_stress_1'),
        subjectId: Value(subId),
        date: const Value('2026-07-24'),
        primaryStatus: const Value('present'),
        lectureType: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await attendanceRepo.update(
        'user_stress_1',
        attId,
        const AttendanceCompanion(primaryStatus: Value('absent')),
      );

      // 4. Timetable Repository
      final timetableRepo = TimetableRepository(database, syncQueueRepository);
      final ttId = await timetableRepo.create(TimetableCompanion(
        id: const Value('tt_stress_1'),
        userId: const Value('user_stress_1'),
        subjectId: Value(subId),
        dayOfWeek: const Value(1),
        startTime: const Value('09:00'),
        endTime: const Value('10:00'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await timetableRepo.update(
        'user_stress_1',
        ttId,
        const TimetableCompanion(startTime: Value('09:30')),
      );

      // 5. Assignments Repository
      final assignmentsRepo = AssignmentRepository(database, syncQueueRepository);
      final asgnId = await assignmentsRepo.create(AssignmentsCompanion(
        id: const Value('asgn_stress_1'),
        userId: const Value('user_stress_1'),
        subjectId: Value(subId),
        title: const Value('Project Phase 1'),
        dueDate: const Value('2026-08-01'),
        status: const Value('pending'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await assignmentsRepo.update(
        'user_stress_1',
        asgnId,
        const AssignmentsCompanion(status: Value('completed')),
      );

      // 6. Calendar Repository
      final calendarRepo = CalendarRepository(database, syncQueueRepository);
      final calId = await calendarRepo.create(CalendarEventsCompanion(
        id: const Value('cal_stress_1'),
        userId: const Value('user_stress_1'),
        title: const Value('Midterm Exam'),
        startDate: const Value('2026-08-15'),
        endDate: const Value('2026-08-15'),
        eventType: const Value('exam'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await calendarRepo.update(
        'user_stress_1',
        calId,
        const CalendarEventsCompanion(title: Value('Midterm Exam Room 302')),
      );

      // 7. Resources Repository
      final resourcesRepo = ResourcesRepository(database, syncQueueRepository);
      final resId = await resourcesRepo.create(ResourcesCompanion(
        id: const Value('res_stress_1'),
        userId: const Value('user_stress_1'),
        subjectId: Value(subId),
        title: const Value('Lecture Slides 1'),
        category: const Value('notes'),
        url: const Value('https://example.com/slides1.pdf'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await resourcesRepo.update(
        'user_stress_1',
        resId,
        const ResourcesCompanion(title: Value('Lecture Slides 1 Final')),
      );

      // 8. Internal Marks Repository
      final internalMarksRepo = InternalMarksRepository(database, syncQueueRepository);
      final markId = await internalMarksRepo.create(InternalMarksCompanion(
        id: const Value('mark_stress_1'),
        userId: const Value('user_stress_1'),
        subjectId: Value(subId),
        examName: const Value('Quiz 1'),
        marksObtained: const Value(18.5),
        maxMarks: const Value(20.0),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await internalMarksRepo.update(
        'user_stress_1',
        markId,
        const InternalMarksCompanion(marksObtained: Value(19.0)),
      );

      // 9. User Repository
      final userRepo = UserRepository(database, null, syncQueueRepository);
      final userId = await userRepo.create(UsersCompanion(
        id: const Value('user_stress_1'),
        name: const Value('Empirical Tester'),
        email: const Value('tester@college.edu'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await userRepo.update(
        userId,
        const UsersCompanion(name: Value('Empirical Tester Updated')),
      );

      // 10. User Settings Repository
      final settingsRepo = UserSettingsRepository(database, syncQueueRepository);
      await settingsRepo.saveSettings(UserSettingsCompanion(
        id: const Value('set_stress_1'),
        userId: const Value('user_stress_1'),
        theme: const Value('dark'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await settingsRepo.updateTheme('user_stress_1', 'light');

      // Verify all pending sync queue items
      final pendingItems = await syncQueueRepository.getPendingItems(limit: 100);

      final tables = pendingItems.map((e) => e.targetTable).toSet();
      expect(tables, containsAll([
        'semesters',
        'subjects',
        'attendance',
        'timetable',
        'assignments',
        'calendar_events',
        'resources',
        'internal_marks',
        'users',
        'user_settings',
      ]));

      // Verify total expected sync queue items count (at least 19 operations)
      expect(pendingItems.length, greaterThanOrEqualTo(19));

      // Test DELETE operations across domain repositories
      await assignmentsRepo.delete('user_stress_1', asgnId);
      await calendarRepo.delete('user_stress_1', calId);
      await resourcesRepo.delete('user_stress_1', resId);
      await internalMarksRepo.delete('user_stress_1', markId);
      await userRepo.delete(userId);

      final updatedPending = await syncQueueRepository.getPendingItems(limit: 100);
      final deleteItems = updatedPending.where((e) => e.operation == 'DELETE').toList();
      expect(deleteItems.length, 5);
      expect(
        deleteItems.map((e) => e.targetTable).toSet(),
        containsAll(['assignments', 'calendar_events', 'resources', 'internal_marks', 'users']),
      );
    });
  });

  group('EMPIRICAL STRESS TEST 2: Exponential Backoff & Max Retry Limit Enforcement', () {
    test('Empirically measures backoff formula 2^retryCount * 500ms and max retry limit (5 retries)', () async {
      // Step A: Mathematical verification of expected delay progression
      final expectedDelays = [500, 1000, 2000, 4000, 8000];
      for (var r = 0; r < 5; r++) {
        final delay = pow(2, r).toInt() * 500;
        expect(delay, expectedDelays[r]);
      }

      // Step B: Empirical execution delay check with Stopwatch
      final id = await syncQueueRepository.enqueue(
        targetTable: 'semesters',
        recordId: 'sem_backoff_test',
        operation: 'INSERT',
      );

      // Insert matching row locally so sync processor can construct payload
      final now = DateTime.now().toUtc().toIso8601String();
      await database.into(database.semesters).insert(SemestersCompanion.insert(
        id: 'sem_backoff_test',
        userId: 'u1',
        name: 'Backoff Semester',
        workingDays: '[]',
        createdAt: now,
        updatedAt: now,
      ));

      supabaseClient.shouldThrow = true;
      connectivityService.isConnected = true;

      final sw = Stopwatch()..start();
      await syncService.syncPendingMutations();
      sw.stop();

      // Check item state after attempt 1 (retryCount was 0 before attempt, delay should be pow(2,0)*500 = 500ms)
      var items = await syncQueueRepository.getPendingItems();
      expect(items.first.retryCount, 1);
      expect(items.first.error, contains('Supabase connection network failure'));
      expect(sw.elapsedMilliseconds, greaterThanOrEqualTo(450)); // ~500ms

      // Step C: Verify Max Retry Limit (5 retries limit)
      // Manually set retryCount to 5 to test skipping logic
      await syncQueueRepository.recordFailure(id, 'Fatal error attempt 5', 4); // becomes retryCount 5
      items = await syncQueueRepository.getPendingItems();
      expect(items.first.retryCount, 5);

      // Reset client throw to verify that even when online, item with retryCount = 5 is skipped
      supabaseClient.shouldThrow = false;
      await syncService.syncPendingMutations();

      items = await syncQueueRepository.getPendingItems();
      expect(items.length, 1);
      expect(items.first.id, id);
      expect(items.first.retryCount, 5);
      expect(items.first.isSynced, false);
      expect(supabaseClient.upsertedPayloads['semesters'], isNull); // Was skipped!
    });
  });

  group('EMPIRICAL STRESS TEST 3: Connectivity Status Transition Auto-Flush', () {
    test('Offline to Online auto-flushes pending queue, handles rapid toggle', () async {
      connectivityService.isConnected = false;

      // Seed 2 pending operations while offline
      await syncQueueRepository.enqueue(
        targetTable: 'timetable',
        recordId: 'tt_auto_1',
        operation: 'INSERT',
      );
      await syncQueueRepository.enqueue(
        targetTable: 'attendance',
        recordId: 'att_auto_1',
        operation: 'INSERT',
      );

      final now = DateTime.now().toUtc().toIso8601String();
      await database.into(database.timetable).insert(TimetableCompanion.insert(
        id: 'tt_auto_1',
        userId: 'u1',
        subjectId: 'sub1',
        dayOfWeek: 2,
        startTime: '10:00',
        endTime: '11:00',
        createdAt: now,
        updatedAt: now,
      ));
      await database.into(database.attendance).insert(AttendanceCompanion.insert(
        id: 'att_auto_1',
        userId: 'u1',
        subjectId: 'sub1',
        date: '2026-07-24',
        primaryStatus: 'present',
        lectureType: 'practical',
        createdAt: now,
        updatedAt: now,
      ));

      var pending = await syncQueueRepository.getPendingItems();
      expect(pending.length, 2);

      // Rapid toggle internet connection (disconnected -> connected -> connected)
      connectivityService.emitStatus(InternetStatus.connected);
      connectivityService.emitStatus(InternetStatus.connected);

      // Wait briefly for asynchronous sync execution trigger
      await Future<void>.delayed(const Duration(milliseconds: 200));

      pending = await syncQueueRepository.getPendingItems();
      expect(pending.isEmpty, true);
      expect(supabaseClient.upsertedPayloads['timetable']?.length, 1);
      expect(supabaseClient.upsertedPayloads['attendance']?.length, 1);
    });
  });

  group('EMPIRICAL STRESS TEST 4: Local-First Truth & Crash Resilience', () {
    test('Preserves local SQLite as source of truth and survives item failure mid-batch', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Seed 3 items in SQLite and queue
      await database.into(database.subjects).insert(SubjectsCompanion(
        id: const Value('sub_crash_1'),
        userId: const Value('user_crash'),
        semesterId: const Value('sem_crash'),
        name: const Value('Local First Subject 1'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await database.into(database.subjects).insert(SubjectsCompanion(
        id: const Value('sub_crash_2'),
        userId: const Value('user_crash'),
        semesterId: const Value('sem_crash'),
        name: const Value('Local First Subject 2 (Will Fail)'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));
      await database.into(database.subjects).insert(SubjectsCompanion(
        id: const Value('sub_crash_3'),
        userId: const Value('user_crash'),
        semesterId: const Value('sem_crash'),
        name: const Value('Local First Subject 3'),
        type: const Value('theory'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await syncQueueRepository.enqueue(
        targetTable: 'subjects',
        recordId: 'sub_crash_1',
        operation: 'INSERT',
      );
      final id2 = await syncQueueRepository.enqueue(
        targetTable: 'subjects',
        recordId: 'sub_crash_2',
        operation: 'INSERT',
      );
      await syncQueueRepository.enqueue(
        targetTable: 'subjects',
        recordId: 'sub_crash_3',
        operation: 'INSERT',
      );

      // Verify local database can be queried immediately (Local-first source of truth)
      final localSubjects = await (database.select(database.subjects)
            ..where((t) => t.userId.equals('user_crash')))
          .get();
      expect(localSubjects.length, 3);
      expect(localSubjects.map((s) => s.name), contains('Local First Subject 1'));

      // Configure client to fail specifically on item 2 ('sub_crash_2')
      supabaseClient.failOnRecordId = 'sub_crash_2';
      connectivityService.isConnected = true;

      // Execute sync
      await syncService.syncPendingMutations();

      // Item 1 succeeded and was markedSynced + purged
      // Item 2 failed and retryCount incremented
      // Item 3 succeeded after item 2's failure delay (backoff delayed item 2, then processed item 3)
      final remainingPending = await syncQueueRepository.getPendingItems();
      expect(remainingPending.length, 1);
      expect(remainingPending.first.id, id2);
      expect(remainingPending.first.recordId, 'sub_crash_2');
      expect(remainingPending.first.retryCount, 1);

      // Verify item 1 and item 3 were synced to Supabase
      final upserts = supabaseClient.upsertedPayloads['subjects']!;
      expect(upserts.length, 2);
      expect(upserts[0]['id'], 'sub_crash_1');
      expect(upserts[1]['id'], 'sub_crash_3');

      // Verify camelCase to snake_case field translation
      expect(upserts[0]['user_id'], 'user_crash');
      expect(upserts[0]['semester_id'], 'sem_crash');
      expect(upserts[0]['created_at'], now);
    });

    test('Gracefully handles orphan queue item when local row was hard deleted', () async {
      await syncQueueRepository.enqueue(
        targetTable: 'semesters',
        recordId: 'sem_deleted_locally',
        operation: 'UPDATE',
      );

      connectivityService.isConnected = true;
      await syncService.syncPendingMutations();

      final pending = await syncQueueRepository.getPendingItems();
      expect(pending.isEmpty, true); // Marked synced and purged cleanly
      expect(supabaseClient.upsertedPayloads['semesters'], isNull);
    });
  });
}
