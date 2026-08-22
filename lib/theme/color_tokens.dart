/// Design Tokens: Color Tokens
///
/// Single source of truth for all color values in College Companion.
/// No widget may use hardcoded colors. Reference these tokens instead.
///
/// ADR-011 — Jade redesign: these are the **dark theme, jade accent**
/// values only — a `static const` fallback for legacy call sites that
/// haven't migrated to `Theme.of(context)`/[CCTokens] yet, and are not
/// reactive to the user's light/dark or accent choice. New code should
/// prefer `Theme.of(context).colorScheme` (for MD3 slots) or
/// `context.cc`/`CCTokens` (for the redesign's extra semantic slots —
/// `priSoft`, `warnSoft`, `riskSoft`, `shadow`, `sheen`, `dim`).
///
/// Token Hierarchy: Primitive → Semantic → Component → Screens
library;

import 'package:flutter/material.dart';

/// Primitive color tokens — the raw palette values (dark theme, jade accent).
///
/// Palette overview (ADR-011):
/// - Foundation: deep charcoal (#0E1315) with warm-neutral containers
/// - Primary action: jade (#6FCFB0) — calm, "you're fine" reassurance
/// - Secondary/Tertiary: unchanged from the prior palette — the redesign
///   canvas doesn't define these; not scoped for repointing until the
///   screens using them (calendar, resources) are re-skinned.
/// - Semantic: jade / sand / coral (attendance states — warn/risk, ADR-011)
abstract final class ColorTokens {
  // ── Primary ──────────────────────────────────────────────────────────────
  /// Jade — primary action, navigation indicator, links (ADR-011).
  static const Color primary = Color(0xFF6FCFB0);
  static const Color onPrimary = Color(0xFF052620);

  /// Deep jade container — derived tint (primary blended over background);
  /// the canvas only specifies a translucent `priSoft`, not an opaque MD3
  /// container, so this value is interpolated rather than a literal source.
  static const Color primaryContainer = Color(0xFF1B2E2A);

  /// Light jade — text/icons on primaryContainer.
  static const Color onPrimaryContainer = Color(0xFFBEEBDD);

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
  /// Deep charcoal — screen background (canvas `--bg`, dark).
  static const Color background = Color(0xFF0E1315);

  /// Base raised surface — scaffold and card surface (canvas `--surf`).
  static const Color surface = Color(0xFF131A1C);

  /// First elevation step (canvas `--raise`).
  static const Color surfaceVariant = Color(0xFF182124);

  /// First elevation step — surfaceContainerLow alias (canvas `--raise`).
  static const Color surfaceContainerLow = Color(0xFF182124);

  /// Second elevation step (canvas `--raise2`).
  static const Color surfaceContainer = Color(0xFF1F292C);

  /// More elevated container — derived, one step lighter than
  /// surfaceContainer (no direct canvas equivalent).
  static const Color surfaceContainerHigh = Color(0xFF29373A);

  /// Highest elevation container — derived, lighter still.
  static const Color surfaceContainerHighest = Color(0xFF344347);

  /// Foreground — primary text on surfaces (canvas `--fg`).
  static const Color onSurface = Color(0xFFE9EEEC);

  /// Muted — supporting text, icons, metadata (canvas `--mut`).
  static const Color onSurfaceVariant = Color(0xFF93A09C);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Jade — healthy attendance, completed tasks (reuses primary; the
  /// canvas treats "healthy" and "primary accent" as the same color).
  static const Color success = Color(0xFF6FCFB0);
  static const Color onSuccess = Color(0xFF052620);

  /// Sand — at-risk attendance, approaching deadlines (canvas `--warn`).
  static const Color warning = Color(0xFFE3B274);
  static const Color onWarning = Color(0xFF281904);

  /// Coral — critical attendance, overdue assignments (canvas `--risk`).
  static const Color error = Color(0xFFE98A80);
  static const Color onError = Color(0xFF3A100D);

  /// Azure — neutral notifications, informational states. Derived: the
  /// canvas doesn't define an "info" slot, so this borrows the azure
  /// accent variant to keep informational messaging visually distinct
  /// from the jade primary and sand/coral warning/risk pair.
  static const Color info = Color(0xFF7FB8E8);
  static const Color onInfo = Color(0xFF04202F);

  // ── Borders ──────────────────────────────────────────────────────────────
  /// Emphasised border — inputs, chips, active states (canvas `--line2`
  /// flattened to an opaque approximation over `background`).
  static const Color outline = Color(0xFF323638);

  /// Hairline border — micro-borders for cards (canvas `--line` flattened
  /// to an opaque approximation over `background`).
  static const Color outlineVariant = Color(0xFF1F2325);

  /// Divider — section separators.
  static const Color divider = Color(0xFF1F2325);

  // ── Inverse ──────────────────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFFE9EEEC);
  static const Color onInverseSurface = Color(0xFF131A1C);

  /// Jade (light-theme value) — inverse primary for light/inverse surfaces.
  static const Color inversePrimary = Color(0xFF1C7A63);

  // ── Scrim ────────────────────────────────────────────────────────────────
  static const Color scrim = Color(0xFF000000);
  static const Color shadow = Color(0xFF000000);
}

/// Semantic color tokens for feature-specific use.
///
/// These reference primitive tokens and provide contextual meaning.
abstract final class SemanticColorTokens {
  // ── Attendance ───────────────────────────────────────────────────────────
  /// Jade — present / healthy attendance.
  static const Color present = ColorTokens.success;

  /// Coral — absent / attendance alert.
  static const Color absent = ColorTokens.error;

  /// Subdued — cancelled / neutral state.
  static const Color cancelled = ColorTokens.onSurfaceVariant;

  // ── Assignments ──────────────────────────────────────────────────────────
  /// Sand — pending work.
  static const Color pending = ColorTokens.warning;

  /// Jade — completed work.
  static const Color completed = ColorTokens.success;

  /// Coral — overdue assignment.
  static const Color overdue = ColorTokens.error;

  // ── Calendar ─────────────────────────────────────────────────────────────
  /// Jade — lecture event.
  static const Color lecture = ColorTokens.primary;

  /// Indigo — practical/lab event.
  static const Color practical = ColorTokens.secondary;

  /// Violet — holiday.
  static const Color holiday = ColorTokens.tertiary;
}
