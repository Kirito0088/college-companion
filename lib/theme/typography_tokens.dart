/// Design Tokens: Typography Tokens
///
/// ADR-011 three-font system: Plus Jakarta Sans (UI/body — the base
/// [textTheme]), Newsreader (serif display/headline text via
/// [serifTextTheme]), and IBM Plex Mono (tabular numerals and uppercase
/// eyebrow labels via [mono]). No custom font sizes outside the typography
/// scale.
///
/// Issue #21 — De-Vibecode: Deliberate tracking constants for editorial
/// precision. Headlines use tighter tracking; uppercase labels use expanded
/// spacing to distinguish metadata from body copy.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens following Material Design 3 type scale.
///
/// Uses Inter as the single font family per design token specification.
abstract final class TypographyTokens {
  // ── Letter-spacing utility constants ─────────────────────────────────────
  /// Tight tracking for large display text — editorial crispness.
  static const double displayLetterSpacing = -0.5;

  /// Slight tightening for headlines — focused, purposeful headers.
  static const double headlineLetterSpacing = -0.25;

  /// Expanded tracking for uppercase label text — distinguishes metadata
  /// from body copy at a glance.
  static const double labelUppercaseSpacing = 0.8;

  /// Moderate tracking for metadata/caption text — readable density.
  static const double metadataSpacing = 0.5;

  /// Expanded tracking for mono eyebrow labels/uppercase micro-copy
  /// (e.g. "TUE 22 AUG · WEEK 6", "SAFE MARGIN") per the redesign canvas.
  static const double monoLabelSpacing = 1.4; // ~0.1em at 14px

  /// Base text theme using Plus Jakarta Sans (ADR-011 — replaces Inter).
  static TextTheme get textTheme {
    return GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        // ── Display ──────────────────────────────────────────────────────
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
        ),

        // ── Headline ─────────────────────────────────────────────────────
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5, // displayLetterSpacing — editorial crispness
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25, // headlineLetterSpacing — focused headers
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25, // headlineLetterSpacing
          height: 1.33,
        ),

        // ── Title ────────────────────────────────────────────────────────
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),

        // ── Body ─────────────────────────────────────────────────────────
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),

        // ── Label ────────────────────────────────────────────────────────
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      ),
    );
  }

  /// Serif display/headline text theme using Newsreader (ADR-011).
  ///
  /// Only the display/headline tiers carry the serif face — body, title,
  /// and label tiers fall back to [textTheme]'s Plus Jakarta Sans so a
  /// screen can mix `Theme.of(context).textTheme` (UI chrome) with
  /// `TypographyTokens.serifTextTheme` (greetings, section titles) without
  /// two incompatible type systems.
  static TextTheme get serifTextTheme {
    final base = textTheme;
    return GoogleFonts.newsreaderTextTheme(base).copyWith(
      displayLarge: GoogleFonts.newsreader(textStyle: base.displayLarge),
      displayMedium: GoogleFonts.newsreader(textStyle: base.displayMedium),
      displaySmall: GoogleFonts.newsreader(textStyle: base.displaySmall),
      headlineLarge: GoogleFonts.newsreader(textStyle: base.headlineLarge),
      headlineMedium: GoogleFonts.newsreader(textStyle: base.headlineMedium),
      headlineSmall: GoogleFonts.newsreader(textStyle: base.headlineSmall),
    );
  }

  /// Applies IBM Plex Mono with tabular figures to [style] — for numerals
  /// (times, percentages, counts) and uppercase eyebrow labels.
  static TextStyle mono(TextStyle? style) {
    return GoogleFonts.ibmPlexMono(
      textStyle: style,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  }
}
