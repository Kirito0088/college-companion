import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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

  // ── Primitive token assertions (ADR-011 jade palette) ────────────────────
  // These tests do NOT construct AppTheme.theme() (which loads fonts), so
  // they are pure unit tests against the static (dark, jade) fallback
  // token constants.
  group('ColorTokens ADR-011 jade palette tests', () {
    test('primary is jade #6FCFB0', () {
      expect(ColorTokens.primary, equals(const Color(0xFF6FCFB0)));
    });
    test('background is deep charcoal #0E1315', () {
      expect(ColorTokens.background, equals(const Color(0xFF0E1315)));
    });
    test('surface is #131A1C', () {
      expect(ColorTokens.surface, equals(const Color(0xFF131A1C)));
    });
    test('surfaceContainerLow is the raise elevation step #182124', () {
      expect(ColorTokens.surfaceContainerLow, equals(const Color(0xFF182124)));
    });
    test('surfaceContainer is the raise2 elevation step #1F292C', () {
      expect(ColorTokens.surfaceContainer, equals(const Color(0xFF1F292C)));
    });
    test('onSurface is the foreground tone #E9EEEC', () {
      expect(ColorTokens.onSurface, equals(const Color(0xFFE9EEEC)));
    });
    test('onSurfaceVariant is the muted tone #93A09C', () {
      expect(ColorTokens.onSurfaceVariant, equals(const Color(0xFF93A09C)));
    });
    test('warning is sand #E3B274', () {
      expect(ColorTokens.warning, equals(const Color(0xFFE3B274)));
    });
    test('error is coral (risk) #E98A80', () {
      expect(ColorTokens.error, equals(const Color(0xFFE98A80)));
    });
    test('primary is NOT the prior electric cobalt', () {
      expect(ColorTokens.primary, isNot(equals(const Color(0xFF3B82F6))));
    });
    test('background is NOT the prior deep obsidian', () {
      expect(ColorTokens.background, isNot(equals(const Color(0xFF0D0F12))));
    });
    test('outlineVariant token is non-transparent (micro-border usable)', () {
      expect(ColorTokens.outlineVariant, isNot(equals(Colors.transparent)));
    });
  });

  // ── CCTokens factory tests ────────────────────────────────────────────────
  group('CCTokens.resolve per (brightness, accent)', () {
    test('dark jade matches the canvas literal values', () {
      final cc = CCTokens.resolve(Brightness.dark, Accent.jade);
      expect(cc.bg, equals(const Color(0xFF0E1315)));
      expect(cc.pri, equals(const Color(0xFF6FCFB0)));
      expect(cc.priFg, equals(const Color(0xFF052620)));
    });

    test('light jade matches the canvas literal values', () {
      final cc = CCTokens.resolve(Brightness.light, Accent.jade);
      expect(cc.bg, equals(const Color(0xFFF3F0EA)));
      expect(cc.pri, equals(const Color(0xFF1C7A63)));
      expect(cc.priFg, equals(const Color(0xFFFFFFFF)));
    });

    test('dark sand overrides only the accent slots', () {
      final jade = CCTokens.resolve(Brightness.dark, Accent.jade);
      final sand = CCTokens.resolve(Brightness.dark, Accent.sand);
      expect(sand.pri, equals(const Color(0xFFE3B274)));
      expect(sand.priFg, equals(const Color(0xFF281904)));
      // Non-accent slots are unaffected by the accent choice.
      expect(sand.bg, equals(jade.bg));
      expect(sand.fg, equals(jade.fg));
    });

    test('light azure falls back to the base light priFg (no override)', () {
      final cc = CCTokens.resolve(Brightness.light, Accent.azure);
      expect(cc.pri, equals(const Color(0xFF1F6491)));
      expect(cc.priFg, equals(const Color(0xFFFFFFFF)));
    });

    test('lerp between dark and light interpolates, never throws', () {
      final dark = CCTokens.resolve(Brightness.dark, Accent.jade);
      final light = CCTokens.resolve(Brightness.light, Accent.jade);
      final mid = dark.lerp(light, 0.5);
      expect(mid, isA<CCTokens>());
      expect(mid.bg, isNot(equals(dark.bg)));
      expect(mid.bg, isNot(equals(light.bg)));
    });
  });

  // ── AppTheme.theme() integration tests (loads Google Fonts) ──────────────
  // Built inside testWidgets (not plain test()) so the test binding awaits
  // the pending async font-loading work — matching the pattern the CCCard
  // tests below already rely on. A plain test() leaks the async font
  // rejection into whichever test runs next.
  group('AppTheme.theme(brightness, accent)', () {
    testWidgets('dark jade theme carries a matching CCTokens extension', (
      tester,
    ) async {
      final theme = AppTheme.theme(Brightness.dark, Accent.jade);
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const SizedBox()),
      );
      expect(theme.brightness, equals(Brightness.dark));
      final cc = theme.extension<CCTokens>();
      expect(cc, isNotNull);
      expect(cc!.pri, equals(const Color(0xFF6FCFB0)));
      expect(theme.colorScheme.primary, equals(cc.pri));
    });

    testWidgets('light theme differs from dark theme in background/primary', (
      tester,
    ) async {
      final dark = AppTheme.theme(Brightness.dark, Accent.jade);
      final light = AppTheme.theme(Brightness.light, Accent.jade);
      await tester.pumpWidget(MaterialApp(theme: dark, home: const SizedBox()));
      await tester.pumpWidget(
        MaterialApp(theme: light, home: const SizedBox()),
      );
      expect(
        dark.scaffoldBackgroundColor,
        isNot(equals(light.scaffoldBackgroundColor)),
      );
      expect(
        dark.colorScheme.primary,
        isNot(equals(light.colorScheme.primary)),
      );
    });

    testWidgets(
      'accent changes primary but not background, within one brightness',
      (tester) async {
        final jade = AppTheme.theme(Brightness.dark, Accent.jade);
        final sand = AppTheme.theme(Brightness.dark, Accent.sand);
        await tester.pumpWidget(
          MaterialApp(theme: jade, home: const SizedBox()),
        );
        await tester.pumpWidget(
          MaterialApp(theme: sand, home: const SizedBox()),
        );
        expect(
          jade.colorScheme.primary,
          isNot(equals(sand.colorScheme.primary)),
        );
        expect(
          jade.scaffoldBackgroundColor,
          equals(sand.scaffoldBackgroundColor),
        );
      },
    );

    testWidgets('darkTheme/lightTheme aliases resolve to the jade accent', (
      tester,
    ) async {
      final darkTheme = AppTheme.darkTheme;
      final lightTheme = AppTheme.lightTheme;
      await tester.pumpWidget(
        MaterialApp(theme: darkTheme, home: const SizedBox()),
      );
      await tester.pumpWidget(
        MaterialApp(theme: lightTheme, home: const SizedBox()),
      );
      expect(
        darkTheme.colorScheme.primary,
        equals(
          AppTheme.theme(Brightness.dark, Accent.jade).colorScheme.primary,
        ),
      );
      expect(
        lightTheme.colorScheme.primary,
        equals(
          AppTheme.theme(Brightness.light, Accent.jade).colorScheme.primary,
        ),
      );
    });
  });

  // ── CCCard micro-border widget tests ─────────────────────────────────────
  group('CCCard micro-border tests', () {
    testWidgets('CCCard renders with a BoxDecoration that has a border', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme(Brightness.dark, Accent.jade),
          home: const Scaffold(body: CCCard(child: Text('Test Card'))),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('CCCard border uses the theme\'s outlineVariant color', (
      tester,
    ) async {
      final theme = AppTheme.theme(Brightness.dark, Accent.jade);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: CCCard(child: Text('Test Card'))),
        ),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, equals(theme.colorScheme.outlineVariant));
    });
  });
}
