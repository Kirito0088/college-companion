/// Image Storage Service
///
/// Handles local file persistence, directory sandboxing, path resolution,
/// SHA-256 integrity hashing, and file cleanup for offline-first camera evidence.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// Result returned after saving an image file to disk.
class SavedImageResult {
  const SavedImageResult({
    required this.relativePath,
    required this.absolutePath,
    required this.sha256Hash,
    required this.fileSizeBytes,
    this.width = 0,
    this.height = 0,
  });

  /// Path relative to the application documents directory.
  final String relativePath;

  /// Full absolute file path on the device filesystem.
  final String absolutePath;

  /// SHA-256 cryptographic checksum of the saved bytes.
  final String sha256Hash;

  /// Size of the saved file in bytes.
  final int fileSizeBytes;

  /// Image width in pixels (if available).
  final int width;

  /// Image height in pixels (if available).
  final int height;
}

/// Integrity status of an evidence file on disk.
enum EvidenceIntegrityState {
  /// File exists and SHA-256 hash matches the database record.
  original,

  /// File cannot be found on device storage.
  missing,

  /// File exists but content/hash differs from original record.
  integrityFailed,
}

/// Service managing offline evidence files inside the app documents sandbox.
class ImageStorageService {
  /// Creates an [ImageStorageService].
  ///
  /// [getAppDocDir] can be overridden in tests to provide an in-memory/temp directory.
  ImageStorageService({
    Future<Directory> Function()? getAppDocDir,
  }) : _getAppDocDir = getAppDocDir ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _getAppDocDir;

  /// Subfolder name where lecture/attendance evidence is kept.
  static const String evidenceSubdir = 'evidence';

  /// Resolves a relative path to an absolute path within the app sandbox.
  Future<String> resolveAbsolutePath(String relativePath) async {
    final docDir = await _getAppDocDir();
    final normalized = relativePath.replaceAll(r'\', '/');
    return '${docDir.path}/$normalized';
  }

  /// Checks if a file exists at [relativePath].
  Future<bool> fileExists(String relativePath) async {
    if (relativePath.trim().isEmpty) return false;
    try {
      final absPath = await resolveAbsolutePath(relativePath);
      final file = File(absPath);
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Returns a [File] handle at [relativePath] if it exists, or `null` otherwise.
  Future<File?> getFile(String relativePath) async {
    if (relativePath.trim().isEmpty) return null;
    try {
      final absPath = await resolveAbsolutePath(relativePath);
      final file = File(absPath);
      if (file.existsSync()) {
        return file;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Reads raw bytes of the file at [relativePath], or returns `null` if missing.
  Future<Uint8List?> readBytes(String relativePath) async {
    final file = await getFile(relativePath);
    if (file == null) return null;
    try {
      return file.readAsBytesSync();
    } catch (_) {
      return null;
    }
  }

  /// Saves raw image [bytes] to the evidence sandbox directory.
  ///
  /// Automatically creates parent directories, calculates SHA-256 hash, and returns [SavedImageResult].
  Future<SavedImageResult> saveImage({
    required Uint8List bytes,
    String? fileName,
    int width = 0,
    int height = 0,
  }) async {
    final docDir = await _getAppDocDir();
    final evidenceDir = Directory('${docDir.path}/$evidenceSubdir');
    if (!evidenceDir.existsSync()) {
      evidenceDir.createSync(recursive: true);
    }

    final name = fileName ??
        'evidence_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final relativePath = '$evidenceSubdir/$name';
    final absPath = '${docDir.path}/$relativePath';

    final file = File(absPath);
    file.writeAsBytesSync(bytes, flush: true);

    final hash = sha256.convert(bytes).toString();

    return SavedImageResult(
      relativePath: relativePath,
      absolutePath: absPath,
      sha256Hash: hash,
      fileSizeBytes: bytes.length,
      width: width,
      height: height,
    );
  }

  /// Saves an existing [file] to the evidence folder.
  Future<SavedImageResult> saveFromFile(
    File file, {
    String? fileName,
    int width = 0,
    int height = 0,
  }) async {
    if (!file.existsSync()) {
      throw FileSystemException('Source file not found', file.path);
    }
    final bytes = await file.readAsBytes();
    return saveImage(
      bytes: bytes,
      fileName: fileName ?? file.uri.pathSegments.last,
      width: width,
      height: height,
    );
  }

  /// Deletes the image file at [relativePath] from disk.
  ///
  /// Returns `true` if deleted, `false` if file did not exist.
  Future<bool> deleteImage(String relativePath) async {
    if (relativePath.trim().isEmpty) return false;
    try {
      final absPath = await resolveAbsolutePath(relativePath);
      final file = File(absPath);
      if (file.existsSync()) {
        file.deleteSync();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Verifies SHA-256 integrity of the file at [relativePath] against [expectedSha256].
  Future<EvidenceIntegrityState> verifyIntegrity(
    String relativePath,
    String expectedSha256,
  ) async {
    final bytes = await readBytes(relativePath);
    if (bytes == null) {
      return EvidenceIntegrityState.missing;
    }
    final calculatedHash = sha256.convert(bytes).toString();
    if (calculatedHash.toLowerCase() == expectedSha256.toLowerCase()) {
      return EvidenceIntegrityState.original;
    }
    return EvidenceIntegrityState.integrityFailed;
  }
}
