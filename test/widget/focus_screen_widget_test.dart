import 'package:college_companion/features/focus/screens/focus_screen.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FocusScreen renders hero timer, preset chips, and control buttons', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const FocusScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify FocusScreen renders
    expect(find.byType(FocusScreen), findsOneWidget);
    expect(find.text('Focus Mode'), findsOneWidget);
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Start Focus Session'), findsOneWidget);

    // Verify preset choice chips exist
    expect(find.text('25 min'), findsWidgets);
    expect(find.text('45 min'), findsWidgets);
    expect(find.text('60 min'), findsWidgets);
    expect(find.text('Custom'), findsOneWidget);

    // Tap on Start Focus Session
    await tester.tap(find.text('Start Focus Session'));
    await tester.pump();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('End Session'), findsOneWidget);
  });
}
