import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:college_companion/services/image_storage_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ImageStorageService storageService;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('image_storage_test_');
    storageService = ImageStorageService(
      getAppDocDir: () async => tempDir,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ImageStorageService - Save & Resolution', () {
    test('saveImage saves bytes into evidence/ directory with SHA-256 hash', () async {
      final sampleBytes = Uint8List.fromList(utf8.encode('test-image-content-bytes-12345'));
      final expectedSha = sha256.convert(sampleBytes).toString();

      final result = await storageService.saveImage(
        bytes: sampleBytes,
        fileName: 'test_photo.jpg',
        width: 1920,
        height: 1080,
      );

      expect(result.relativePath, 'evidence/test_photo.jpg');
      expect(result.sha256Hash, expectedSha);
      expect(result.fileSizeBytes, sampleBytes.length);
      expect(result.width, 1920);
      expect(result.height, 1080);

      // Verify file exists on disk
      final absPath = await storageService.resolveAbsolutePath(result.relativePath);
      final diskFile = File(absPath);
      expect(diskFile.existsSync(), isTrue);
      expect(await diskFile.readAsBytes(), sampleBytes);
    });

    test('saveImage auto-generates fileName if omitted', () async {
      final sampleBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await storageService.saveImage(bytes: sampleBytes);

      expect(result.relativePath, startsWith('evidence/'));
      expect(result.relativePath, endsWith('.jpg'));
      expect(await storageService.fileExists(result.relativePath), isTrue);
    });

    test('saveFromFile copies existing file to evidence directory', () async {
      final sourceFile = File('${tempDir.path}/source_image.jpg');
      final bytes = Uint8List.fromList(utf8.encode('source-file-data'));
      await sourceFile.writeAsBytes(bytes);

      final result = await storageService.saveFromFile(
        sourceFile,
        fileName: 'copied_evidence.jpg',
      );

      expect(result.relativePath, 'evidence/copied_evidence.jpg');
      expect(await storageService.fileExists(result.relativePath), isTrue);
      expect(await storageService.readBytes(result.relativePath), bytes);
    });

    test('resolveAbsolutePath normalizes backslashes to standard separators', () async {
      final absPath = await storageService.resolveAbsolutePath(r'evidence\sub\photo.jpg');
      expect(absPath, '${tempDir.path}/evidence/sub/photo.jpg');
    });
  });

  group('ImageStorageService - Read & Existence Guards', () {
    test('fileExists returns false for non-existent file or empty path', () async {
      expect(await storageService.fileExists('evidence/does_not_exist.jpg'), isFalse);
      expect(await storageService.fileExists(''), isFalse);
      expect(await storageService.fileExists('   '), isFalse);
    });

    test('getFile returns null for missing file', () async {
      final file = await storageService.getFile('evidence/non_existent.jpg');
      expect(file, isNull);
    });

    test('readBytes returns null for missing file', () async {
      final bytes = await storageService.readBytes('evidence/ghost.jpg');
      expect(bytes, isNull);
    });
  });

  group('ImageStorageService - Deletion & Cleanup', () {
    test('deleteImage removes file from disk and returns true', () async {
      final sampleBytes = Uint8List.fromList([10, 20, 30]);
      final result = await storageService.saveImage(
        bytes: sampleBytes,
        fileName: 'to_delete.jpg',
      );

      expect(await storageService.fileExists(result.relativePath), isTrue);

      final deleted = await storageService.deleteImage(result.relativePath);
      expect(deleted, isTrue);
      expect(await storageService.fileExists(result.relativePath), isFalse);
    });

    test('deleteImage returns false and does not throw for non-existent file', () async {
      final deleted = await storageService.deleteImage('evidence/never_existed.jpg');
      expect(deleted, isFalse);
    });
  });

  group('ImageStorageService - Integrity Verification', () {
    test('verifyIntegrity returns original when SHA-256 matches', () async {
      final sampleBytes = Uint8List.fromList(utf8.encode('tamper-proof-image-payload'));
      final result = await storageService.saveImage(
        bytes: sampleBytes,
        fileName: 'integrity_check.jpg',
      );

      final integrity = await storageService.verifyIntegrity(
        result.relativePath,
        result.sha256Hash,
      );

      expect(integrity, EvidenceIntegrityState.original);
    });

    test('verifyIntegrity returns integrityFailed when file content has been altered', () async {
      final sampleBytes = Uint8List.fromList(utf8.encode('original-payload'));
      final result = await storageService.saveImage(
        bytes: sampleBytes,
        fileName: 'tampered.jpg',
      );

      // Tamper with the file on disk
      final absPath = await storageService.resolveAbsolutePath(result.relativePath);
      await File(absPath).writeAsBytes(Uint8List.fromList(utf8.encode('tampered-payload')));

      final integrity = await storageService.verifyIntegrity(
        result.relativePath,
        result.sha256Hash,
      );

      expect(integrity, EvidenceIntegrityState.integrityFailed);
    });

    test('verifyIntegrity returns missing when file is not found on disk', () async {
      final integrity = await storageService.verifyIntegrity(
        'evidence/lost_file.jpg',
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );

      expect(integrity, EvidenceIntegrityState.missing);
    });
  });
}
