/// Issue #26 — ADR-011 theming contract guard.
///
/// `ColorTokens`/`SemanticColorTokens` are `static const` (dark theme, jade
/// accent) and cannot react to the user's theme/accent selection at
/// Settings -> Appearance. The contract is that *only* `lib/theme/` may
/// reference them — every widget outside it must read colors from
/// `Theme.of(context).colorScheme` or `context.cc` (`CCTokens`).
///
/// This is a source-scanning test rather than a widget test on purpose: the
/// defect is a *whole-codebase invariant*, and a per-widget test would only
/// catch the screens someone remembered to write a test for.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Matches a static reference to either legacy token class, e.g.
/// `ColorTokens.primary` or `SemanticColorTokens.present`.
final _legacyColorRef = RegExp(r'\b(Semantic)?ColorTokens\.\w+');

/// Directory that legitimately owns the legacy constants.
const _themeDir = 'lib/theme';

List<File> _dartFilesOutsideTheme() {
  final lib = Directory('lib');
  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll(r'\', '/').startsWith(_themeDir))
      .toList();
}

void main() {
  group('ADR-011 theming contract (issue #26)', () {
    test('no widget outside lib/theme references ColorTokens statics', () {
      final offenders = <String>[];

      for (final file in _dartFilesOutsideTheme()) {
        final path = file.path.replaceAll(r'\', '/');
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (_legacyColorRef.hasMatch(lines[i])) {
            offenders.add('$path:${i + 1}: ${lines[i].trim()}');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'These call sites render fixed dark/jade colors and ignore the '
            'user\'s theme + accent selection. Migrate them to '
            '`context.cc.*` or `Theme.of(context).colorScheme.*`.\n'
            '${offenders.join('\n')}',
      );
    });
  });
}
