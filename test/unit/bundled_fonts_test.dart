/// Guards the offline-first font bundle (issue #22).
///
/// The three redesign families used to be fetched over the network on first
/// use, so a first launch without connectivity rendered the whole UI in
/// Roboto. They now ship in `assets/google_fonts/` and runtime fetching is
/// disabled, which turns a missing file into a load error instead of a
/// silent network fallback.
///
/// The first test is the regression net: it requests every variant the type
/// system can produce with fetching off, so adding a weight to
/// `TypographyTokens` without bundling its file fails here, not on a
/// student's phone.
library;

import 'package:college_companion/theme/bundled_fonts.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

List<TextStyle?> _styles(TextTheme t) => [
  t.displayLarge,
  t.displayMedium,
  t.displaySmall,
  t.headlineLarge,
  t.headlineMedium,
  t.headlineSmall,
  t.titleLarge,
  t.titleMedium,
  t.titleSmall,
  t.bodyLarge,
  t.bodyMedium,
  t.bodySmall,
  t.labelLarge,
  t.labelMedium,
  t.labelSmall,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every variant the type system requests loads from bundled assets',
    () async {
      GoogleFonts.config.allowRuntimeFetching = false;

      final base = _styles(TypographyTokens.textTheme);
      _styles(TypographyTokens.serifTextTheme);
      // mono() may wrap any style in the scale, so cover all of them.
      base.forEach(TypographyTokens.mono);

      await expectLater(GoogleFonts.pendingFonts(), completes);
    },
  );

  test('configure() disables runtime fetching', () {
    GoogleFonts.config.allowRuntimeFetching = true;

    BundledFonts.configure();

    expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
  });

  test(
    'configure() registers the OFL license of each bundled family',
    () async {
      BundledFonts.configure();

      final entries = await LicenseRegistry.licenses.toList();
      for (final family in [
        'Plus Jakarta Sans',
        'Newsreader',
        'IBM Plex Mono',
      ]) {
        final entry = entries.where((e) => e.packages.contains(family));
        expect(entry, hasLength(1), reason: '$family license not registered');
        final text = entry.single.paragraphs.map((p) => p.text).join('\n');
        expect(text, contains('SIL Open Font License'));
      }
    },
  );
}
