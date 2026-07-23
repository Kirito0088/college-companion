import 'package:college_companion/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants Unit Tests', () {
    test('appName is correctly defined', () {
      expect(AppConstants.appName, equals('College Companion'));
    });

    test('minAndroidSdk is Android 12 (API 31)', () {
      expect(AppConstants.minAndroidSdk, equals(31));
    });

    test('targetAndroidSdk is Android 15 (API 35)', () {
      expect(AppConstants.targetAndroidSdk, equals(35));
    });
  });
}
