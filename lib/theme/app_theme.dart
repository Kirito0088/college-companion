/// App Theme Configuration
///
/// ADR-011 — user-selectable light/dark theme with a selectable accent
/// (jade/sand/azure). Material Design 3. All values from design tokens.
/// No hardcoded colors, spacing, typography, or radii (per 10-rules.md).
library;

import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/material.dart';

/// Provides the application's [ThemeData].
///
/// Material Design 3, Android-first experience.
abstract final class AppTheme {
  /// Builds the theme for a given [brightness] and [accent] (ADR-011).
  ///
  /// Carries a [CCTokens] extension alongside the MD3 [ColorScheme] so
  /// widgets can reach either `Theme.of(context).colorScheme` or
  /// `context.cc` depending on which semantic slot they need.
  static ThemeData theme(Brightness brightness, Accent accent) {
    final ccTokens = CCTokens.resolve(brightness, accent);
    final colorScheme = _colorSchemeFor(brightness, ccTokens);
    final textTheme = TypographyTokens.textTheme.apply(
      bodyColor: ccTokens.fg,
      displayColor: ccTokens.fg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [ccTokens],
      scaffoldBackgroundColor: ccTokens.bg,

      // ── App Bar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // ── Navigation Bar (Bottom) ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ccTokens.raise,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: ccTokens.mut, size: 24),
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: ccTokens.raise,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ──────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ccTokens.raise2,
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: colorScheme.outline),
          shape: const RoundedRectangleBorder(
            borderRadius: RadiusTokens.borderRadiusMd,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Floating Action Button ─────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusLg,
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ccTokens.raise2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: ccTokens.raise2,
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusSm,
        ),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ccTokens.raise,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: ccTokens.mut,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: ccTokens.raise2,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusXl,
        ),
      ),

      // ── Snack Bar ──────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ccTokens.raise2,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: ccTokens.fg),
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusSm,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: ccTokens.line,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ───────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),

      // ── Tooltip ────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: ccTokens.raise2,
          borderRadius: RadiusTokens.borderRadiusSm,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: ccTokens.fg),
      ),

      // ── Tab Bar ────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        dividerHeight: 0,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      // ── Switch ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // ── List Tile ──────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        iconColor: ccTokens.mut,
        textColor: ccTokens.fg,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
        ),
      ),
    );
  }

  /// The dark theme, jade accent — kept as a stable default for call sites
  /// that haven't migrated to the reactive [theme] factory yet.
  static ThemeData get darkTheme => theme(Brightness.dark, Accent.jade);

  /// The light theme, jade accent.
  static ThemeData get lightTheme => theme(Brightness.light, Accent.jade);

  /// Derives an MD3 [ColorScheme] from [ccTokens] for the given [brightness].
  ///
  /// `secondary`/`tertiary` are not yet part of the redesign (the canvas
  /// doesn't define them) — they keep the prior palette's indigo/violet
  /// values for both brightnesses until the screens that use them
  /// (calendar, resources) are re-skinned.
  static ColorScheme _colorSchemeFor(Brightness brightness, CCTokens cc) {
    final base = brightness == Brightness.dark
        ? const ColorScheme.dark()
        : const ColorScheme.light();
    return base.copyWith(
      brightness: brightness,
      primary: cc.pri,
      onPrimary: cc.priFg,
      primaryContainer: ColorTokens.primaryContainer,
      onPrimaryContainer: ColorTokens.onPrimaryContainer,
      secondary: ColorTokens.secondary,
      onSecondary: ColorTokens.onSecondary,
      secondaryContainer: ColorTokens.secondaryContainer,
      onSecondaryContainer: ColorTokens.onSecondaryContainer,
      tertiary: ColorTokens.tertiary,
      onTertiary: ColorTokens.onTertiary,
      tertiaryContainer: ColorTokens.tertiaryContainer,
      onTertiaryContainer: ColorTokens.onTertiaryContainer,
      error: cc.risk,
      onError: cc.bg,
      surface: cc.surf,
      onSurface: cc.fg,
      onSurfaceVariant: cc.mut,
      // cc.line/line2 are translucent overlays (matching the canvas CSS,
      // meant to be composited directly onto a surface). Several call
      // sites below re-apply `.withValues(alpha: ...)` on top, expecting
      // an opaque base — so flatten them onto `cc.bg` first with
      // Color.alphaBlend to avoid compounding two alphas into an
      // almost-invisible border.
      outline: Color.alphaBlend(cc.line2, cc.bg),
      outlineVariant: Color.alphaBlend(cc.line, cc.bg),
      inverseSurface: brightness == Brightness.dark ? cc.fg : cc.bg,
      onInverseSurface: brightness == Brightness.dark ? cc.bg : cc.fg,
      inversePrimary: cc.pri,
      scrim: Colors.black,
      shadow: Colors.black,
      surfaceContainerHighest: cc.raise2,
      surfaceContainerHigh: cc.raise2,
      surfaceContainer: cc.raise2,
      surfaceContainerLow: cc.raise,
      surfaceContainerLowest: cc.bg,
    );
  }
}
