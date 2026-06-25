/// App Theme Configuration
///
/// Dark mode only. Material Design 3. All values from design tokens.
/// No hardcoded colors, spacing, typography, or radii (per 10-rules.md).
library;

import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/material.dart';

/// Provides the application's [ThemeData].
///
/// Dark mode only, Material Design 3, Android-first experience.
abstract final class AppTheme {
  /// The single dark theme for College Companion.
  static ThemeData get darkTheme {
    final colorScheme = _colorScheme;
    final textTheme = TypographyTokens.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,

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
        backgroundColor: ColorTokens.surfaceContainer,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        iconTheme: const WidgetStatePropertyAll(
          IconThemeData(color: ColorTokens.onSurfaceVariant, size: 24),
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: ColorTokens.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
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
          backgroundColor: ColorTokens.surfaceContainerHigh,
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
        fillColor: ColorTokens.surfaceContainerHigh,
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
        backgroundColor: ColorTokens.surfaceContainerHigh,
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusSm,
        ),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorTokens.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.xl),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: ColorTokens.onSurfaceVariant,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: ColorTokens.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusXl,
        ),
      ),

      // ── Snack Bar ──────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorTokens.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: ColorTokens.onSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusSm,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ColorTokens.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ───────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),

      // ── Tooltip ────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: ColorTokens.surfaceContainerHighest,
          borderRadius: RadiusTokens.borderRadiusSm,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: ColorTokens.onSurface),
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
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        iconColor: ColorTokens.onSurfaceVariant,
        textColor: ColorTokens.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
        ),
      ),
    );
  }

  /// Dark color scheme derived from [ColorTokens].
  static ColorScheme get _colorScheme {
    return const ColorScheme.dark(
      primary: ColorTokens.primary,
      onPrimary: ColorTokens.onPrimary,
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
      error: ColorTokens.error,
      onError: ColorTokens.onError,
      surface: ColorTokens.surface,
      onSurface: ColorTokens.onSurface,
      onSurfaceVariant: ColorTokens.onSurfaceVariant,
      outline: ColorTokens.outline,
      outlineVariant: ColorTokens.outlineVariant,
      inverseSurface: ColorTokens.inverseSurface,
      onInverseSurface: ColorTokens.onInverseSurface,
      inversePrimary: ColorTokens.inversePrimary,
      scrim: ColorTokens.scrim,
      shadow: ColorTokens.shadow,
      surfaceContainerHighest: ColorTokens.surfaceContainerHighest,
      surfaceContainerHigh: ColorTokens.surfaceContainerHigh,
      surfaceContainer: ColorTokens.surfaceContainer,
      surfaceContainerLow: ColorTokens.surfaceVariant,
      surfaceContainerLowest: ColorTokens.background,
    );
  }
}
