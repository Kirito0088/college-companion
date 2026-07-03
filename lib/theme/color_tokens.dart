/// Design Tokens: Color Tokens
///
/// Single source of truth for all color values in College Companion.
/// No widget may use hardcoded colors. Reference these tokens instead.
///
/// Token Hierarchy: Primitive → Semantic → Component → Screens
library;

import 'package:flutter/material.dart';

/// Primitive color tokens — the raw palette values.
abstract final class ColorTokens {
  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF9C6AFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2D1F5E);
  static const Color onPrimaryContainer = Color(0xFFE0D0FF);

  // ── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF7C6AE6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF28204A);
  static const Color onSecondaryContainer = Color(0xFFD4CCFF);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF6AE6C5);
  static const Color onTertiary = Color(0xFF003829);
  static const Color tertiaryContainer = Color(0xFF1A3D32);
  static const Color onTertiaryContainer = Color(0xFFC0FFF0);

  // ── Surface ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF0F0F17);
  static const Color surfaceVariant = Color(0xFF1A1A28);
  static const Color surfaceContainerLow = Color(0xFF12121A);
  static const Color surfaceContainer = Color(0xFF141420);
  static const Color surfaceContainerHigh = Color(0xFF1E1E2E);
  static const Color surfaceContainerHighest = Color(0xFF262636);
  static const Color onSurface = Color(0xFFE6E1E6);
  static const Color onSurfaceVariant = Color(0xFF9E9E9E);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFFF9800);
  static const Color onWarning = Color(0xFF000000);
  static const Color error = Color(0xFFEF5350);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF42A5F5);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF3A3A4A);
  static const Color outlineVariant = Color(0xFF2A2A3A);
  static const Color divider = Color(0xFF1E1E2E);

  // ── Inverse ──────────────────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFFE6E1E6);
  static const Color onInverseSurface = Color(0xFF1A1A28);
  static const Color inversePrimary = Color(0xFF6A3FBF);

  // ── Scrim ────────────────────────────────────────────────────────────────
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);
}

/// Semantic color tokens for feature-specific use.
///
/// These reference primitive tokens and provide contextual meaning.
abstract final class SemanticColorTokens {
  // ── Attendance ───────────────────────────────────────────────────────────
  static const Color present = ColorTokens.success;
  static const Color absent = ColorTokens.error;
  static const Color cancelled = ColorTokens.onSurfaceVariant;

  // ── Assignments ──────────────────────────────────────────────────────────
  static const Color pending = ColorTokens.warning;
  static const Color completed = ColorTokens.success;
  static const Color overdue = ColorTokens.error;

  // ── Calendar ─────────────────────────────────────────────────────────────
  static const Color lecture = ColorTokens.primary;
  static const Color practical = ColorTokens.tertiary;
  static const Color holiday = ColorTokens.warning;
}
