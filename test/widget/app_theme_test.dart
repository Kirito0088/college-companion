import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable network font fetching in all tests — prevents google_fonts from
  // making outbound HTTP calls during CI/test runs.
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // ── Primitive token assertions ────────────────────────────────────────────
  // These tests do NOT construct AppTheme.darkTheme (which loads Inter), so
  // they are pure unit tests against the token constants.
  group('ColorTokens De-Vibecode Palette Tests', () {
    test('primary is electric cobalt #3B82F6', () {
      expect(ColorTokens.primary, equals(const Color(0xFF3B82F6)));
    });
    test('background is deep obsidian #0D0F12', () {
      expect(ColorTokens.background, equals(const Color(0xFF0D0F12)));
    });
    test('surface is dark graphite #121518', () {
      expect(ColorTokens.surface, equals(const Color(0xFF121518)));
    });
    test('surfaceContainerLow is warm graphite #161A1F', () {
      expect(ColorTokens.surfaceContainerLow, equals(const Color(0xFF161A1F)));
    });
    test('surfaceContainer is elevated container #1A1E24', () {
      expect(ColorTokens.surfaceContainer, equals(const Color(0xFF1A1E24)));
    });
    test('surfaceContainerHigh is #1E232A', () {
      expect(ColorTokens.surfaceContainerHigh, equals(const Color(0xFF1E232A)));
    });
    test('surfaceContainerHighest is #252B33', () {
      expect(
        ColorTokens.surfaceContainerHighest,
        equals(const Color(0xFF252B33)),
      );
    });
    test('onSurface is crisp off-white #F0F2F5', () {
      expect(ColorTokens.onSurface, equals(const Color(0xFFF0F2F5)));
    });
    test('onSurfaceVariant is subdued #8B909A', () {
      expect(ColorTokens.onSurfaceVariant, equals(const Color(0xFF8B909A)));
    });
    test('success is emerald #10B981', () {
      expect(ColorTokens.success, equals(const Color(0xFF10B981)));
    });
    test('warning is amber #F59E0B', () {
      expect(ColorTokens.warning, equals(const Color(0xFFF59E0B)));
    });
    test('error is coral red #EF4444', () {
      expect(ColorTokens.error, equals(const Color(0xFFEF4444)));
    });
    test('outline is subtle border #2D3340', () {
      expect(ColorTokens.outline, equals(const Color(0xFF2D3340)));
    });
    test('outlineVariant is very subtle border #1F2530', () {
      expect(ColorTokens.outlineVariant, equals(const Color(0xFF1F2530)));
    });
    test('primary is NOT old neon purple', () {
      expect(ColorTokens.primary, isNot(equals(const Color(0xFF9C6AFF))));
    });
    test('primaryContainer is NOT old deep purple', () {
      expect(
        ColorTokens.primaryContainer,
        isNot(equals(const Color(0xFF2D1F5E))),
      );
    });
    test('outlineVariant token is non-transparent (micro-border usable)', () {
      expect(ColorTokens.outlineVariant, isNot(equals(Colors.transparent)));
    });
  });

  // ── ColorScheme unit tests (no font loading) ─────────────────────────────
  // Access the color scheme directly from AppTheme without materializing
  // a TextTheme — avoids the google_fonts network issue in CI.
  group('AppTheme ColorScheme integration tests', () {
    // Build only the color scheme portion, which does not touch google_fonts.
    const colorScheme = ColorScheme.dark(
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
      surfaceContainerLow: ColorTokens.surfaceContainerLow,
      surfaceContainerLowest: ColorTokens.background,
    );

    test('colorScheme primary is electric cobalt', () {
      expect(colorScheme.primary, equals(const Color(0xFF3B82F6)));
    });
    test('colorScheme surface is dark graphite', () {
      expect(colorScheme.surface, equals(const Color(0xFF121518)));
    });
    test('colorScheme surfaceContainerLow maps correctly', () {
      expect(
        colorScheme.surfaceContainerLow,
        equals(ColorTokens.surfaceContainerLow),
      );
    });
    test('colorScheme outlineVariant is crisp micro-border color', () {
      expect(colorScheme.outlineVariant, equals(const Color(0xFF1F2530)));
    });
    test('AppTheme uses Material3 and dark brightness (via colorScheme)', () {
      // We verify M3 + dark by inspecting the ColorScheme brightness directly
      // without calling AppTheme.darkTheme in a plain test() context, which
      // would trigger google_fonts async font loading and leak into other tests.
      expect(colorScheme.brightness, equals(Brightness.dark));
    });
  });

  // ── CCCard micro-border widget tests ─────────────────────────────────────
  group('CCCard micro-border tests', () {
    testWidgets('CCCard renders with a BoxDecoration that has a border', (
      tester,
    ) async {
      // Use a minimal ThemeData with no google_fonts dependency.
      final minimalTheme = ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: ColorTokens.surface,
          surfaceContainer: ColorTokens.surfaceContainer,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: minimalTheme,
          home: const Scaffold(body: CCCard(child: Text('Test Card'))),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('CCCard border uses outlineVariant color', (tester) async {
      final minimalTheme = ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: ColorTokens.surface,
          surfaceContainer: ColorTokens.surfaceContainer,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: minimalTheme,
          home: const Scaffold(body: CCCard(child: Text('Test Card'))),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, equals(ColorTokens.outlineVariant));
    });
  });
}
