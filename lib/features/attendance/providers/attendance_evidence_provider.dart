/// Attendance Evidence Providers
///
/// Riverpod providers and state notifier for managing camera/gallery evidence
/// attached to lecture and attendance records.
library;

import 'dart:async';
import 'dart:io';

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/database/daos/attendance_evidence_dao.dart';
import 'package:college_companion/database/daos/sync_queue_dao.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/services/image_storage_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Provides the [AttendanceEvidenceDao] instance.
final attendanceEvidenceDaoProvider = Provider<AttendanceEvidenceDao>((ref) {
  final database = ref.watch(databaseProvider);
  final syncDao = SyncQueueDao(database);
  return AttendanceEvidenceDao(database, syncDao);
});

/// Provides the [ImageStorageService] instance.
final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService();
});

/// Watches evidence entities for a specific lecture record as a stream.
final attendanceEvidenceStreamProvider =
    StreamProvider.family<List<LectureEvidenceEntity>, String>((ref, recordId) {
  final dao = ref.watch(attendanceEvidenceDaoProvider);
  return dao.watchEvidenceForRecord(recordId);
});

/// StateNotifier providing reactive evidence streams and capture/delete actions.
class AttendanceEvidenceNotifier
    extends StateNotifier<AsyncValue<List<LectureEvidenceEntity>>> {
  AttendanceEvidenceNotifier({
    required this.recordId,
    required this.dao,
    required this.storageService,
    this.imagePicker,
  }) : super(const AsyncLoading()) {
    _init();
  }

  final String recordId;
  final AttendanceEvidenceDao dao;
  final ImageStorageService storageService;
  final ImagePicker? imagePicker;

  StreamSubscription<List<LectureEvidenceEntity>>? _subscription;

  void _init() {
    _subscription = dao.watchEvidenceForRecord(recordId).listen(
      (data) {
        state = AsyncData(data);
      },
      onError: (Object err, StackTrace stack) {
        state = AsyncError(err, stack);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Captures an image using [source] (camera or gallery) and persists it locally.
  Future<LectureEvidenceEntity?> captureAndSave({
    ImageSource source = ImageSource.camera,
    String? note,
    String appVersion = '1.0.0',
    String? timezone,
  }) async {
    try {
      final picker = imagePicker ?? ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      final fileName =
          'evidence_${recordId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      return await addEvidenceFromBytes(
        bytes: bytes,
        fileName: fileName,
        appVersion: appVersion,
        timezone: timezone ?? DateTime.now().timeZoneName,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Persists raw image bytes into the local storage sandbox and database.
  Future<LectureEvidenceEntity> addEvidenceFromBytes({
    required Uint8List bytes,
    String? fileName,
    int width = 1920,
    int height = 1080,
    String appVersion = '1.0.0',
    String? timezone,
  }) async {
    final saved = await storageService.saveImage(
      bytes: bytes,
      fileName: fileName,
      width: width,
      height: height,
    );

    final id = const Uuid().v4();
    final companion = AttendanceEvidenceCompanion(
      id: Value(id),
      lectureRecordId: Value(recordId),
      localPathRelative: Value(saved.relativePath),
      sha256: Value(saved.sha256Hash),
      width: Value(saved.width),
      height: Value(saved.height),
      captureTimestamp: Value(DateTime.now().toUtc()),
      appVersion: Value(appVersion),
      timezone: Value(timezone ?? DateTime.now().timeZoneName),
      state: const Value('original'),
    );

    await dao.insertEvidence(companion);
    final entity = await dao.getById(id);
    return entity!;
  }

  /// Persists an image from an existing [file].
  Future<LectureEvidenceEntity> addEvidenceFromFile(
    File file, {
    String? fileName,
    int width = 1920,
    int height = 1080,
    String appVersion = '1.0.0',
    String? timezone,
  }) async {
    final bytes = await file.readAsBytes();
    return addEvidenceFromBytes(
      bytes: bytes,
      fileName: fileName ?? file.uri.pathSegments.last,
      width: width,
      height: height,
      appVersion: appVersion,
      timezone: timezone,
    );
  }

  /// Deletes an evidence entity from the database and removes its disk file.
  Future<void> deleteEvidence(String evidenceId) async {
    try {
      final evidence = await dao.getById(evidenceId);
      if (evidence != null) {
        await storageService.deleteImage(evidence.localPathRelative);
      }
      await dao.deleteEvidence(evidenceId);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Provides the reactive evidence stream and capture/delete actions for a specific record.
final attendanceEvidenceProvider = StateNotifierProvider.autoDispose.family<
    AttendanceEvidenceNotifier,
    AsyncValue<List<LectureEvidenceEntity>>,
    String>((ref, recordId) {
  final dao = ref.watch(attendanceEvidenceDaoProvider);
  final storageService = ref.watch(imageStorageServiceProvider);
  return AttendanceEvidenceNotifier(
    recordId: recordId,
    dao: dao,
    storageService: storageService,
  );
});
