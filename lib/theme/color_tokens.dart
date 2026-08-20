/// Design Tokens: Color Tokens
///
/// Single source of truth for all color values in College Companion.
/// No widget may use hardcoded colors. Reference these tokens instead.
///
/// Issue #21 — De-Vibecode: Distinctive obsidian / electric cobalt palette.
/// Replaces the generic neon purple vibecoded aesthetic with a sophisticated,
/// editorial-precision identity grounded in the academic operating system brief.
///
/// Token Hierarchy: Primitive → Semantic → Component → Screens
library;

import 'package:flutter/material.dart';

/// Primitive color tokens — the raw palette values.
///
/// Palette overview:
/// - Foundation: deep obsidian (#0D0F12) with warm graphite containers
/// - Primary action: electric cobalt (#3B82F6) — purposeful, focused
/// - Secondary: indigo (#6366F1) — calendar, lectures
/// - Tertiary: violet (#8B5CF6) — resources, focus
/// - Semantic: emerald / amber / coral (attendance states)
abstract final class ColorTokens {
  // ── Primary ──────────────────────────────────────────────────────────────
  /// Electric cobalt — primary action, navigation indicator, links.
  static const Color primary = Color(0xFF3B82F6);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Deep cobalt container.
  static const Color primaryContainer = Color(0xFF1A2E4A);

  /// Light cobalt — text/icons on primaryContainer.
  static const Color onPrimaryContainer = Color(0xFFBFDBFE);

  // ── Secondary ────────────────────────────────────────────────────────────
  /// Indigo — calendar events, lecture slots.
  static const Color secondary = Color(0xFF6366F1);
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Deep indigo container.
  static const Color secondaryContainer = Color(0xFF1E1F3E);

  /// Light indigo — text/icons on secondaryContainer.
  static const Color onSecondaryContainer = Color(0xFFC7D2FE);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  /// Violet — resources, focus mode.
  static const Color tertiary = Color(0xFF8B5CF6);
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Deep violet container.
  static const Color tertiaryContainer = Color(0xFF2D1F5E);

  /// Light violet — text/icons on tertiaryContainer.
  static const Color onTertiaryContainer = Color(0xFFDDD6FE);

  // ── Surface ──────────────────────────────────────────────────────────────
  /// Deep obsidian — screen background.
  static const Color background = Color(0xFF0D0F12);

  /// Dark graphite — scaffold and card surface.
  static const Color surface = Color(0xFF121518);

  /// Warm graphite — low elevation containers.
  static const Color surfaceVariant = Color(0xFF161A1F);

  /// Warm graphite — surfaceContainerLow alias.
  static const Color surfaceContainerLow = Color(0xFF161A1F);

  /// Elevated container.
  static const Color surfaceContainer = Color(0xFF1A1E24);

  /// More elevated container.
  static const Color surfaceContainerHigh = Color(0xFF1E232A);

  /// Highest elevation container.
  static const Color surfaceContainerHighest = Color(0xFF252B33);

  /// Crisp off-white — primary text on surfaces.
  static const Color onSurface = Color(0xFFF0F2F5);

  /// Subdued — supporting text, icons, metadata.
  static const Color onSurfaceVariant = Color(0xFF8B909A);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Emerald — healthy attendance, completed tasks.
  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Amber — at-risk attendance, approaching deadlines.
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFF000000);

  /// Coral red — critical attendance, overdue assignments.
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);

  /// Cobalt — neutral notifications, informational states.
  static const Color info = Color(0xFF3B82F6);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ── Borders ──────────────────────────────────────────────────────────────
  /// Subtle border — primary outline for inputs and chips.
  static const Color outline = Color(0xFF2D3340);

  /// Very subtle border — micro-borders for cards (replaces diffuse glows).
  static const Color outlineVariant = Color(0xFF1F2530);

  /// Divider — section separators.
  static const Color divider = Color(0xFF1A1E24);

  // ── Inverse ──────────────────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFFF0F2F5);
  static const Color onInverseSurface = Color(0xFF121518);

  /// Darker cobalt — inverse primary for light surfaces.
  static const Color inversePrimary = Color(0xFF1D4ED8);

  // ── Scrim ────────────────────────────────────────────────────────────────
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);
}

/// Semantic color tokens for feature-specific use.
///
/// These reference primitive tokens and provide contextual meaning.
abstract final class SemanticColorTokens {
  // ── Attendance ───────────────────────────────────────────────────────────
  /// Emerald — present / healthy attendance.
  static const Color present = ColorTokens.success;

  /// Coral red — absent / attendance alert.
  static const Color absent = ColorTokens.error;

  /// Subdued — cancelled / neutral state.
  static const Color cancelled = ColorTokens.onSurfaceVariant;

  // ── Assignments ──────────────────────────────────────────────────────────
  /// Amber — pending work.
  static const Color pending = ColorTokens.warning;

  /// Emerald — completed work.
  static const Color completed = ColorTokens.success;

  /// Coral red — overdue assignment.
  static const Color overdue = ColorTokens.error;

  // ── Calendar ─────────────────────────────────────────────────────────────
  /// Cobalt — lecture event.
  static const Color lecture = ColorTokens.primary;

  /// Indigo — practical/lab event.
  static const Color practical = ColorTokens.secondary;

  /// Violet — holiday.
  static const Color holiday = ColorTokens.tertiary;
}
