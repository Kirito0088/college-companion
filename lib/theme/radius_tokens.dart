/// Design Tokens: Radius Tokens
///
/// Cards, dialogs, buttons, and sheets share the same family of corner radii.
/// Never hardcode border radius values (per 01-design-tokens.md).
library;

import 'package:flutter/material.dart';

/// Border radius tokens for consistent shape language.
abstract final class RadiusTokens {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 100;
  static const double circle = 999;

  // ── Pre-built BorderRadius instances ──────────────────────────────────
  static const BorderRadius borderRadiusXs = BorderRadius.all(
    Radius.circular(xs),
  );
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(sm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(md),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(lg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius borderRadiusPill = BorderRadius.all(
    Radius.circular(pill),
  );
}
