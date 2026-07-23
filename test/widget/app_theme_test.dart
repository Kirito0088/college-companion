import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('AppTheme Unit & Widget Tests', () {
    test('darkTheme returns Material Design 3 dark theme', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
      expect(
        theme.scaffoldBackgroundColor,
        equals(theme.colorScheme.surface),
      );
    });
  });
}
