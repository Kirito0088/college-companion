/// Offline-first font setup (issue #22).
///
/// The three ADR-011 families ship as assets in `assets/google_fonts/`, named
/// the way `google_fonts` looks them up (`<Family>-<Variant>.ttf`), so the
/// package loads them from the bundle and never needs the network. The files
/// are the exact binaries `google_fonts` would otherwise fetch, verified
/// against the hashes it pins.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Configures font loading for an offline-first app.
abstract final class BundledFonts {
  /// Display name → asset-file prefix for each bundled family.
  static const Map<String, String> _families = {
    'Plus Jakarta Sans': 'PlusJakartaSans',
    'Newsreader': 'Newsreader',
    'IBM Plex Mono': 'IBMPlexMono',
  };

  static bool _licensesRegistered = false;

  /// Call once before `runApp`.
  ///
  /// Disables runtime fetching so a variant missing from the bundle fails
  /// loudly instead of silently reaching for the network, and registers each
  /// family's SIL Open Font License, which must accompany the redistributed
  /// font files.
  static void configure() {
    GoogleFonts.config.allowRuntimeFetching = false;

    if (_licensesRegistered) return;
    _licensesRegistered = true;
    LicenseRegistry.addLicense(() async* {
      for (final MapEntry(key: name, value: prefix) in _families.entries) {
        final text = await rootBundle.loadString(
          'assets/google_fonts/$prefix-OFL.txt',
        );
        yield LicenseEntryWithLineBreaks([name], text);
      }
    });
  }
}
