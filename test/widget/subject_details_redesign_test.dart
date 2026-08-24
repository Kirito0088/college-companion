/// Widget tests covering the Slice 6 (Subject Details) redesign.
///
/// `SubjectDetailsScreen` computes its state from
/// [subjectByIdStreamProvider] and [attendanceBySubjectStreamProvider] (see
/// `subject_detail_provider.dart`), which feed `SubjectMetricOverview`'s
/// bunk-calculator display and `SubjectDetailsHeader`'s title. These tests
/// override those two family stream providers with fixed data (same
/// fake-stream-for-reads approach as `attendance_redesign_test.dart`) and
/// assert the screen renders real, provider-derived values — including that
/// two different attendance datasets produce different rendered numbers —
/// plus that the screen's own token-driven color (the FAB's `cc.pri`
/// background) actually changes across accents, guarding against the ~56
/// still-hardcoded `ColorTokens`/`RadiusTokens` refs elsewhere in
/// `subjects/widgets` silently ignoring accent switches.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subject_detail_provider.dart';
import 'package:college_companion/features/subjects/screens/subject_details_screen.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: 'test_user_id',
      email: 'test@example.com',
      displayName: 'Test Student',
    ),
  );
}

const _subjectParams = (userId: 'test_user_id', subjectId: 'subj_1');

SubjectEntity _subject(String name) {
  const nowIso = '2026-01-01T00:00:00.000Z';
  return SubjectEntity(
    id: _subjectParams.subjectId,
    userId: _subjectParams.userId,
    semesterId: 'sem_1',
    name: name,
    type: 'theory',
    createdAt: nowIso,
    updatedAt: nowIso,
  );
}

List<AttendanceEntity> _records({required int present, required int absent}) {
  const nowIso = '2026-01-01T00:00:00.000Z';
  return [
    for (var i = 0; i < present; i++)
      AttendanceEntity(
        id: 'present_$i',
        userId: _subjectParams.userId,
        subjectId: _subjectParams.subjectId,
        date: '2026-01-0${(i % 9) + 1}',
        primaryStatus: 'present',
        lectureType: 'theory',
        createdAt: nowIso,
        updatedAt: nowIso,
      ),
    for (var i = 0; i < absent; i++)
      AttendanceEntity(
        id: 'absent_$i',
        userId: _subjectParams.userId,
        subjectId: _subjectParams.subjectId,
        date: '2026-01-0${(i % 9) + 1}',
        primaryStatus: 'absent',
        lectureType: 'theory',
        createdAt: nowIso,
        updatedAt: nowIso,
      ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpSubjectDetailsScreen(
    WidgetTester tester, {
    required SubjectEntity subject,
    required List<AttendanceEntity> records,
    Accent accent = Accent.jade,
  }) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(_TestAuthStateNotifier.new),
          databaseProvider.overrideWithValue(database),
          subjectByIdStreamProvider.overrideWith(
            (ref, params) => Stream.value(subject),
          ),
          attendanceBySubjectStreamProvider.overrideWith(
            (ref, params) => Stream.value(records),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.theme(Brightness.dark, accent),
          home: SubjectDetailsScreen(subjectId: _subjectParams.subjectId),
        ),
      ),
    );
    await tester.pump();
  }

  group('SubjectDetailsScreen real-data wiring', () {
    testWidgets(
      'renders the real subject name and provider-derived attendance percentage',
      (tester) async {
        final subject = _subject('Data Structures');
        final records = _records(present: 15, absent: 5);

        await pumpSubjectDetailsScreen(
          tester,
          subject: subject,
          records: records,
        );

        expect(find.text('Data Structures'), findsWidgets);
        // 15/20 = 75%
        expect(find.text('75%'), findsOneWidget);
        expect(find.text('15'), findsWidgets);
        expect(find.text('5'), findsWidgets);
      },
    );

    testWidgets(
      'a different attendance dataset renders different numbers, proving live '
      'state rather than a hardcoded placeholder',
      (tester) async {
        final subject = _subject('Digital Electronics');
        final records = _records(present: 6, absent: 4);

        await pumpSubjectDetailsScreen(
          tester,
          subject: subject,
          records: records,
        );

        expect(find.text('Digital Electronics'), findsWidgets);
        // 6/10 = 60%
        expect(find.text('60%'), findsOneWidget);
        expect(find.text('75%'), findsNothing);
      },
    );
  });

  group('SubjectDetailsScreen accent reactivity (ADR-011)', () {
    testWidgets(
      'the FAB background resolves through context.cc.pri and differs between accents',
      (tester) async {
        final subject = _subject('Thermodynamics');
        final records = _records(present: 10, absent: 0);

        await pumpSubjectDetailsScreen(
          tester,
          subject: subject,
          records: records,
          accent: Accent.jade,
        );
        final jadeFab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        final jadeColor = jadeFab.backgroundColor;

        await pumpSubjectDetailsScreen(
          tester,
          subject: subject,
          records: records,
          accent: Accent.azure,
        );
        // MaterialApp wraps its Theme in an AnimatedTheme, so a bare pump()
        // only captures the interpolation's start frame (the old accent).
        // Settle it so the FAB reads the fully-transitioned target color.
        await tester.pumpAndSettle();
        final azureFab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        final azureColor = azureFab.backgroundColor;

        expect(jadeColor, isNotNull);
        expect(azureColor, isNotNull);
        expect(
          jadeColor,
          isNot(equals(azureColor)),
          reason:
              'FAB background must resolve through context.cc.pri, which '
              'varies per accent — a hardcoded ColorTokens value would stay '
              'identical here.',
        );
      },
    );
  });
}
