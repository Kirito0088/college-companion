import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  const testUserId = 'test_user_read_model';

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

  group('Attendance Read-Model Tests', () {
    test('calculates accurate attended, total, percentage, and safe bunks for attendance records', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Seed 6 present records
      for (int i = 0; i < 6; i++) {
        await db.into(db.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att_p_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            date: now,
            lectureType: 'theory',
            primaryStatus: 'present',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      // Seed 2 absent records
      for (int i = 0; i < 2; i++) {
        await db.into(db.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att_a_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            date: now,
            lectureType: 'theory',
            primaryStatus: 'absent',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final result = await container.read(safeBunkStreamProvider(testUserId).future);
      expect(result.attended, 6);
      expect(result.total, 8);
      expect(result.currentPercentage, 75.0);
      expect(result.safeBunks, 0);
      expect(result.mustAttend, 0);
    });

    test('calculates mustAttend when attendance is below 75%', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      // Seed 5 present records and 5 absent records (50%)
      for (int i = 0; i < 5; i++) {
        await db.into(db.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att_p_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            date: now,
            lectureType: 'theory',
            primaryStatus: 'present',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      for (int i = 0; i < 5; i++) {
        await db.into(db.attendance).insert(
          AttendanceCompanion.insert(
            id: 'att_a_$i',
            userId: testUserId,
            subjectId: 'sub_1',
            date: now,
            lectureType: 'theory',
            primaryStatus: 'absent',
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      final result = await container.read(safeBunkStreamProvider(testUserId).future);
      expect(result.attended, 5);
      expect(result.total, 10);
      expect(result.currentPercentage, 50.0);
      expect(result.mustAttend, 10);
    });
  });
}
