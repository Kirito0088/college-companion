/// Resource File Service
///
/// Resolves local-storage metadata (existence, size) for resource files
/// living in the app documents sandbox, and launches them in the native
/// OS file viewer.
library;

import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Local-storage metadata for a resource file at a relative path.
class ResourceFileInfo {
  const ResourceFileInfo({
    required this.exists,
    required this.sizeBytes,
    required this.absolutePath,
  });

  /// Whether the file is present on disk.
  final bool exists;

  /// File size in bytes, or 0 when [exists] is false.
  final int sizeBytes;

  /// Absolute path resolved within the app's sandbox.
  final String absolutePath;
}

/// Resolves and opens resource files stored in the app documents sandbox.
class ResourceFileService {
  /// Creates a [ResourceFileService].
  ///
  /// [getAppDocDir] and [openFile] can be overridden in tests to avoid
  /// touching the real filesystem or platform channel.
  ResourceFileService({
    Future<Directory> Function()? getAppDocDir,
    Future<OpenResult> Function(String path)? openFile,
  }) : _getAppDocDir = getAppDocDir ?? getApplicationDocumentsDirectory,
       _openFile = openFile ?? OpenFilex.open;

  final Future<Directory> Function() _getAppDocDir;
  final Future<OpenResult> Function(String path) _openFile;

  /// Resolves a relative path to an absolute path within the app sandbox.
  Future<String> resolveAbsolutePath(String relativePath) async {
    final docDir = await _getAppDocDir();
    final normalized = relativePath.replaceAll(r'\', '/');
    return '${docDir.path}/$normalized';
  }

  /// Reads existence and size of the file at [relativePath].
  Future<ResourceFileInfo> stat(String relativePath) async {
    final absPath = await resolveAbsolutePath(relativePath);
    final file = File(absPath);
    final exists = file.existsSync();
    return ResourceFileInfo(
      exists: exists,
      sizeBytes: exists ? file.lengthSync() : 0,
      absolutePath: absPath,
    );
  }

  /// Launches the file at [relativePath] in the native OS viewer.
  Future<OpenResult> open(String relativePath) async {
    final absPath = await resolveAbsolutePath(relativePath);
    return _openFile(absPath);
  }
}
