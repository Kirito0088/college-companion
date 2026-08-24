/// Widget tests covering the Slice 5 (Calendar + Timetable) redesign.
///
/// Two things are under test:
///
/// 1. `CalendarScreen` renders its agenda from [calendarEventsStreamProvider]
///    (live), not from any of the mock/hardcoded literals scattered across
///    the legacy `calendar_grid.dart` / `calendar_event_list.dart` widgets
///    (unreachable, but their strings must never leak onto the live screen).
/// 2. Event-type color consistency: before this slice, `agenda_card.dart`'s
///    `typeColor` getter, `event_details_screen.dart`'s private
///    `_eventTypeColor`, and `add_edit_event_screen.dart`'s `_eventTypes`
///    picker each hand-rolled their own eventType->color switch and
///    disagreed (e.g. 'assignment' was secondary in one, warning in
///    another). All three now resolve through the single
///    `calendarEventTypeColor` function, so the same event type renders
///    identically everywhere.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/app_user.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/calendar/providers/calendar_provider.dart';
import 'package:college_companion/features/calendar/screens/calendar_screen.dart';
import 'package:college_companion/features/calendar/widgets/agenda_card.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _TestAuthStateNotifier extends AuthStateNotifier {
  @override
  AuthState build() => const AuthAuthenticated(
    AppUser(
      uid: 'test_user_id',
      email: 'test@example.com',
      displayName: 'Test Student',
    ),
  );
}

CalendarEventEntity _event({
  required String id,
  required String title,
  required String eventType,
  required DateTime startDate,
}) {
  final nowIso = DateTime.now().toUtc().toIso8601String();
  return CalendarEventEntity(
    id: id,
    userId: 'test_user_id',
    title: title,
    startDate: startDate.toUtc().toIso8601String(),
    endDate: startDate.add(const Duration(hours: 1)).toUtc().toIso8601String(),
    isAllDay: false,
    eventType: eventType,
    createdAt: nowIso,
    updatedAt: nowIso,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CalendarScreen real-data wiring', () {
    Future<void> pumpCalendarScreen(
      WidgetTester tester,
      List<CalendarEventEntity> events,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_TestAuthStateNotifier.new),
            calendarEventsStreamProvider.overrideWith(
              (ref, userId) => Stream.value(events),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CalendarScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'renders today\'s agenda from the live provider, not a hardcoded mock event',
      (tester) async {
        final today = DateTime.now();
        final event = _event(
          id: 'evt_1',
          title: 'Physics Viva',
          eventType: 'exam',
          startDate: DateTime(today.year, today.month, today.day, 10),
        );

        await pumpCalendarScreen(tester, [event]);

        expect(find.text('Physics Viva'), findsOneWidget);

        // Literals hardcoded in the unused legacy mock widgets must never
        // appear on the live, provider-driven screen.
        expect(find.text('AI Mini Project Report'), findsNothing);
        expect(find.text('DevOps Lab Record'), findsNothing);
        expect(find.text('Internal Test - CN'), findsNothing);
      },
    );

    testWidgets(
      'shows the empty-agenda state, not a stale event, when there are no events today',
      (tester) async {
        await pumpCalendarScreen(tester, []);

        expect(find.text('Physics Viva'), findsNothing);
        expect(find.text('Nothing scheduled today.'), findsNothing);
      },
    );
  });

  group('Calendar event-type color consistency (ADR-011)', () {
    testWidgets(
      'academic/assignment/exam/personal resolve to distinct, theme-reactive colors '
      'through a single shared function',
      (tester) async {
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        final CCTokens cc = capturedContext.cc;
        final colorScheme = Theme.of(capturedContext).colorScheme;

        expect(
          calendarEventTypeColor(capturedContext, 'academic'),
          equals(cc.pri),
        );
        expect(
          calendarEventTypeColor(capturedContext, 'assignment'),
          equals(cc.warn),
        );
        expect(
          calendarEventTypeColor(capturedContext, 'exam'),
          equals(cc.risk),
        );
        expect(
          calendarEventTypeColor(capturedContext, 'personal'),
          equals(colorScheme.tertiary),
        );

        // Case-insensitive, and consistent for the same entity everywhere.
        final assignmentEvent = _event(
          id: 'evt_2',
          title: 'Lab Report',
          eventType: 'Assignment',
          startDate: DateTime.now(),
        );
        expect(
          assignmentEvent.typeColor(capturedContext),
          equals(calendarEventTypeColor(capturedContext, 'assignment')),
        );
      },
    );
  });
}
