import 'dart:io';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/attendance_evidence_dao.dart';
import 'package:college_companion/features/attendance/providers/attendance_evidence_provider.dart';
import 'package:college_companion/features/attendance/widgets/evidence_capture_sheet.dart';
import 'package:college_companion/features/attendance/widgets/evidence_preview_dialog.dart';
import 'package:college_companion/features/attendance/widgets/evidence_thumbnail_strip.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/services/image_storage_service.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../support/test_db.dart';

// Valid 1x1 transparent PNG bytes for Flutter Image widgets in tests
final kTestPngBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late Backend backend;
  late Directory tempDir;
  late ImageStorageService storageService;
  late AttendanceEvidenceDao evidenceDao;

  setUp(() {
    backend = Backend.memory();
    evidenceDao = AttendanceEvidenceDao(backend.db, backend.queueDao);
    tempDir = Directory.systemTemp.createTempSync('widget_evidence_test_');
    storageService = ImageStorageService(getAppDocDir: () async => tempDir);
  });

  tearDown(() async {
    await backend.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  Widget buildTestableWidget({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(backend.db),
        attendanceEvidenceDaoProvider.overrideWithValue(evidenceDao),
        imageStorageServiceProvider.overrideWithValue(storageService),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: child is Scaffold ? child : Scaffold(body: child),
      ),
    );
  }

  group('EvidenceCaptureSheet Widget Tests', () {
    testWidgets('renders camera option, gallery option, and note field', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const EvidenceCaptureSheet(recordId: 'rec-test-1'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Attach Evidence'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.byIcon(Symbols.photo_camera), findsNWidgets(2));
      expect(find.byIcon(Symbols.photo_library), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('triggers onSourceSelected with note content on button press', (
      tester,
    ) async {
      ImageSource? selectedSource;
      String? enteredNote;

      await tester.pumpWidget(
        buildTestableWidget(
          child: EvidenceCaptureSheet(
            recordId: 'rec-test-1',
            onSourceSelected: (source, note) {
              selectedSource = source;
              enteredNote = note;
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.enterText(
        find.byType(TextField),
        'Classroom blackboard notes',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Take Photo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(selectedSource, ImageSource.camera);
      expect(enteredNote, 'Classroom blackboard notes');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('triggers gallery selection on Choose from Gallery tap', (
      tester,
    ) async {
      ImageSource? selectedSource;

      await tester.pumpWidget(
        buildTestableWidget(
          child: EvidenceCaptureSheet(
            recordId: 'rec-test-1',
            onSourceSelected: (source, note) {
              selectedSource = source;
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.text('Choose from Gallery'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(selectedSource, ImageSource.gallery);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });

  group('EvidenceThumbnailStrip Widget Tests', () {
    testWidgets('renders empty placeholder when no evidence exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const EvidenceThumbnailStrip(recordId: 'rec-empty-1'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Add Evidence'), findsOneWidget);
      expect(find.byIcon(Symbols.add_a_photo), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'renders photo thumbnail and add more button when evidence is present',
      (tester) async {
        final saved = await storageService.saveImage(
          bytes: kTestPngBytes,
          fileName: 'thumb_test.png',
        );

        await evidenceDao.insertEvidence(
          AttendanceEvidenceCompanion(
            id: const Value('ev-thumb-1'),
            lectureRecordId: const Value('rec-with-thumb'),
            localPathRelative: Value(saved.relativePath),
            sha256: Value(saved.sha256Hash),
            width: const Value(800),
            height: const Value(600),
            captureTimestamp: Value(DateTime.now().toUtc()),
            appVersion: const Value('1.0.0'),
            timezone: const Value('UTC'),
            state: const Value('original'),
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: const EvidenceThumbnailStrip(recordId: 'rec-with-thumb'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(EvidenceThumbnailCard), findsOneWidget);
        expect(find.byIcon(Symbols.add), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });

  group('EvidencePreviewDialog Widget Tests', () {
    testWidgets(
      'renders interactive preview, close button, delete button, and metadata',
      (tester) async {
        final saved = await storageService.saveImage(
          bytes: kTestPngBytes,
          fileName: 'preview_test.png',
        );

        final entity = LectureEvidenceEntity(
          id: 'ev-preview-1',
          lectureRecordId: 'rec-preview-1',
          localPathRelative: saved.relativePath,
          sha256: saved.sha256Hash,
          width: 1920,
          height: 1080,
          captureTimestamp: DateTime.utc(2026, 9, 15, 9, 30),
          appVersion: '1.0.0',
          timezone: 'UTC',
          state: 'original',
        );

        await tester.pumpWidget(
          buildTestableWidget(
            child: EvidencePreviewDialog(
              evidence: entity,
              recordId: 'rec-preview-1',
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byIcon(Symbols.close), findsOneWidget);
        expect(find.byIcon(Symbols.delete), findsOneWidget);
        expect(find.text('Evidence Photo'), findsOneWidget);
        expect(find.text('SHA-256 Verified'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );

    testWidgets('delete action shows confirmation and deletes evidence', (
      tester,
    ) async {
      final saved = await storageService.saveImage(
        bytes: kTestPngBytes,
        fileName: 'to_delete_dialog.png',
      );

      await evidenceDao.insertEvidence(
        AttendanceEvidenceCompanion(
          id: const Value('ev-delete-dialog'),
          lectureRecordId: const Value('rec-delete-dialog'),
          localPathRelative: Value(saved.relativePath),
          sha256: Value(saved.sha256Hash),
          width: const Value(800),
          height: const Value(600),
          captureTimestamp: Value(DateTime.now().toUtc()),
          appVersion: const Value('1.0.0'),
          timezone: const Value('UTC'),
          state: const Value('original'),
        ),
      );

      final entity = (await evidenceDao.getById('ev-delete-dialog'))!;

      await tester.pumpWidget(
        buildTestableWidget(
          child: EvidencePreviewDialog(
            evidence: entity,
            recordId: 'rec-delete-dialog',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Tap delete button in preview
      await tester.tap(find.byIcon(Symbols.delete));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Confirm delete dialog
      expect(find.text('Delete Evidence?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verify row is deleted from DAO
      final inDb = await evidenceDao.getById('ev-delete-dialog');
      expect(inDb, isNull);

      // Verify file is deleted from disk
      expect(await storageService.fileExists(saved.relativePath), isFalse);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });

  group('attendanceEvidenceProvider Integration Tests', () {
    testWidgets(
      'provides reactive stream and executes capture and delete actions',
      (tester) async {
        const recordId = 'rec-provider-test';

        late WidgetRef capturedRef;
        await tester.pumpWidget(
          buildTestableWidget(
            child: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                final asyncEvidence = ref.watch(
                  attendanceEvidenceProvider(recordId),
                );
                return asyncEvidence.when(
                  data: (list) => Text('Count: ${list.length}'),
                  loading: () => const Text('Loading...'),
                  error: (e, _) => Text('Error: $e'),
                );
              },
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Count: 0'), findsOneWidget);

        // Add evidence via notifier
        final notifier = capturedRef.read(
          attendanceEvidenceProvider(recordId).notifier,
        );
        final added = await notifier.addEvidenceFromBytes(
          bytes: kTestPngBytes,
          fileName: 'prov_test.png',
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Count: 1'), findsOneWidget);

        // Delete evidence via notifier
        await notifier.deleteEvidence(added.id);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Count: 0'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      },
    );
  });
}
