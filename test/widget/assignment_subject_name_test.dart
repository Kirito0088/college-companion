/// Assignments show their subject's name, never its id (#40).
///
/// The add dialog used to store the subject's *name* (or the literal
/// 'General') in `subject_id`, and the screens printed `subject_id`
/// verbatim. Real ids are UUIDs, so correctly stored rows rendered as UUIDs.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/assignments/repositories/assignments_repository.dart';
import 'package:college_companion/features/assignments/screens/assignment_details_screen.dart';
import 'package:college_companion/features/assignments/screens/assignments_screen.dart';
import 'package:college_companion/features/assignments/widgets/add_assignment_dialog.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/subjects/providers/subjects_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _uid = 'test_user_id';
const _iso = '2026-10-01T00:00:00.000Z';

class _SignedIn extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(uid: _uid, email: 'e@x.test', displayName: 'Test'),
  );
}

const _dsa = SubjectEntity(
  id: '7f3c2a10-uuid-dsa',
  userId: _uid,
  semesterId: 'sem',
  name: 'Data Structures',
  type: 'theory',
  createdAt: _iso,
  updatedAt: _iso,
);

AssignmentEntity _assignment(String id, String title, String subjectId) =>
    AssignmentEntity(
      id: id,
      userId: _uid,
      subjectId: subjectId,
      title: title,
      dueDate: '2026-10-20T10:00:00.000Z',
      status: 'pending',
      createdAt: _iso,
      updatedAt: _iso,
    );

/// Serves one fixed assignment, so the details screen needs no database.
class _OneAssignmentRepository extends AssignmentRepository {
  _OneAssignmentRepository(super.database, this.assignment);

  final AssignmentEntity assignment;

  @override
  Stream<AssignmentEntity?> watchById(String userId, String id) =>
      Stream.value(assignment);
}

Future<void> _pumpDetails(
  WidgetTester tester,
  AssignmentEntity assignment,
) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_SignedIn.new),
        assignmentRepositoryProvider.overrideWithValue(
          _OneAssignmentRepository(db, assignment),
        ),
        subjectsStreamProvider.overrideWith(
          (ref, u) => Stream.value(const [_dsa]),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.theme(Brightness.dark, Accent.jade),
        home: AssignmentDetailsScreen(assignmentId: assignment.id),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _pumpList(
  WidgetTester tester,
  List<AssignmentEntity> assignments,
) async {
  tester.view.physicalSize = const Size(1080, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith(_SignedIn.new),
        assignmentsStreamProvider.overrideWith(
          (ref, u) => Stream.value(assignments),
        ),
        subjectsStreamProvider.overrideWith(
          (ref, u) => Stream.value(const [_dsa]),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.theme(Brightness.dark, Accent.jade),
        home: const AssignmentsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AssignmentsScreen cards', () {
    testWidgets('show the subject name for a subject id', (tester) async {
      await _pumpList(tester, [_assignment('a1', 'Linked lists', _dsa.id)]);

      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text(_dsa.id), findsNothing);
    });

    testWidgets('read rows saved before #40, which stored the name', (
      tester,
    ) async {
      await _pumpList(tester, [
        _assignment('a1', 'Linked lists', 'Data Structures'),
      ]);

      expect(find.text('Data Structures'), findsOneWidget);
    });

    testWidgets('never show an id that resolves to no subject', (tester) async {
      await _pumpList(tester, [
        _assignment('a1', 'Essay', 'General'),
        _assignment('a2', 'Quiz', '0b1e-deleted-subject-uuid'),
      ]);

      expect(find.text('General'), findsNothing);
      expect(find.text('0b1e-deleted-subject-uuid'), findsNothing);
      expect(find.text('No subject'), findsNWidgets(2));
    });
  });

  group('AssignmentsScreen search', () {
    testWidgets('matches the subject name', (tester) async {
      await _pumpList(tester, [
        _assignment('a1', 'Linked lists', _dsa.id),
        _assignment('a2', 'Essay', 'General'),
      ]);

      await tester.enterText(find.byType(TextField).first, 'data struct');
      await tester.pumpAndSettle();

      expect(find.text('Linked lists'), findsOneWidget);
      expect(find.text('Essay'), findsNothing);
    });
  });

  group('AssignmentDetailsScreen', () {
    testWidgets('shows the subject name', (tester) async {
      await _pumpDetails(tester, _assignment('a1', 'Linked lists', _dsa.id));

      expect(find.text('Data Structures'), findsOneWidget);
      expect(find.text(_dsa.id), findsNothing);
    });

    testWidgets('shows no raw id for an unresolvable subject', (tester) async {
      await _pumpDetails(tester, _assignment('a1', 'Essay', 'General'));

      expect(find.text('Essay'), findsOneWidget);
      expect(find.text('General'), findsNothing);
    });
  });

  group('AddAssignmentDialog', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<void> pumpDialog(
      WidgetTester tester, {
      List<SubjectEntity> subjects = const [_dsa],
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_SignedIn.new),
            databaseProvider.overrideWithValue(db),
            subjectsStreamProvider.overrideWith(
              (ref, u) => Stream.value(subjects),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.theme(Brightness.dark, Accent.jade),
            home: const Scaffold(body: AddAssignmentDialog()),
          ),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'Linked lists');
    }

    Future<void> save(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Save Assignment'));
      await tester.tap(find.text('Save Assignment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('stores the chosen subject by id, not by name', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data Structures').last);
      await tester.pumpAndSettle();
      await save(tester);

      final rows = await db.select(db.assignments).get();
      expect(rows.single.subjectId, _dsa.id);
    });

    testWidgets('refuses to save without a subject', (tester) async {
      await pumpDialog(tester);

      await save(tester);

      expect(await db.select(db.assignments).get(), isEmpty);
      expect(find.text('Choose a subject for this assignment'), findsOneWidget);
    });

    testWidgets('offers no placeholder "General" subject', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsNothing);
    });

    testWidgets('tells a student with no subjects where to add one', (
      tester,
    ) async {
      await pumpDialog(tester, subjects: const []);

      expect(find.textContaining('Add a subject'), findsOneWidget);
    });
  });
}
