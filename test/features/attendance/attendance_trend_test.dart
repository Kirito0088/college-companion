/// Tests covering issue #30 — `AttendanceTrendCard` previously plotted a
/// fixed, hardcoded list of 7 points inside `_TrendChartPainter` and took no
/// parameters at all, so an account with zero attendance records still
/// rendered a plausible-looking 40-65% curve. That violates this repo's
/// "Never Synthesize Fake Data" rule.
///
/// These tests pin both halves of the fix:
///   1. `AttendanceTrend.fromRecords` — the pure records -> per-weekday
///      percentage bucketing (no `DateTime.now()`, so the week is explicit).
///   2. `AttendanceTrendCard` — renders an explicit empty state for a week
///      with no lectures, and repaints differently when the data changes
///      (the same "different result -> different render" pattern as
///      `test/widget/attendance_redesign_test.dart`).
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/attendance/providers/attendance_provider.dart';
import 'package:college_companion/features/attendance/widgets/attendance_trend_card.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

AttendanceEntity _record({
  required String date,
  required String primaryStatus,
  String id = 'a1',
}) {
  return AttendanceEntity(
    id: id,
    userId: 'u1',
    subjectId: 's1',
    date: date,
    primaryStatus: primaryStatus,
    lectureType: 'theory',
    createdAt: '2026-08-24T00:00:00.000Z',
    updatedAt: '2026-08-24T00:00:00.000Z',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // Monday 2026-08-24 .. Sunday 2026-08-30.
  final weekStart = DateTime(2026, 8, 24);

  group('AttendanceTrend.fromRecords', () {
    test('an account with zero attendance records has no data at all', () {
      final trend = AttendanceTrend.fromRecords(const [], weekStart);

      expect(trend.dailyPercentages, hasLength(7));
      expect(trend.dailyPercentages.every((p) => p == null), isTrue);
      expect(trend.hasData, isFalse);
    });

    test('buckets records into Monday-first weekday percentages', () {
      final trend = AttendanceTrend.fromRecords([
        // Monday: 1 of 2 attended -> 50%.
        _record(id: 'a1', date: '2026-08-24', primaryStatus: 'present'),
        _record(id: 'a2', date: '2026-08-24', primaryStatus: 'absent'),
        // Wednesday: 1 of 1 attended -> 100%.
        _record(id: 'a3', date: '2026-08-26', primaryStatus: 'present'),
      ], weekStart);

      expect(trend.dailyPercentages[0], 50.0);
      expect(trend.dailyPercentages[2], 100.0);
      expect(trend.hasData, isTrue);
    });

    test('a day with only cancelled lectures counts as no data, not 0%', () {
      // A cancelled lecture is not a missed one — bucketing it as 0% would
      // plot a dip that never happened.
      final trend = AttendanceTrend.fromRecords([
        _record(id: 'a1', date: '2026-08-25', primaryStatus: 'cancelled'),
      ], weekStart);

      expect(trend.dailyPercentages[1], isNull);
      expect(trend.hasData, isFalse);
    });

    test('a day with lectures held but none attended is 0%, not null', () {
      final trend = AttendanceTrend.fromRecords([
        _record(id: 'a1', date: '2026-08-25', primaryStatus: 'absent'),
      ], weekStart);

      expect(trend.dailyPercentages[1], 0.0);
      expect(trend.hasData, isTrue);
    });

    test('ignores records outside the requested week', () {
      final trend = AttendanceTrend.fromRecords([
        _record(id: 'a1', date: '2026-08-23', primaryStatus: 'present'),
        _record(id: 'a2', date: '2026-08-31', primaryStatus: 'present'),
      ], weekStart);

      expect(trend.hasData, isFalse);
    });

    test('ignores soft-deleted records', () {
      final trend = AttendanceTrend.fromRecords([
        _record(
          id: 'a1',
          date: '2026-08-24',
          primaryStatus: 'present',
        ).copyWith(deletedAt: const Value('2026-08-25T00:00:00.000Z')),
      ], weekStart);

      expect(trend.hasData, isFalse);
    });
  });

  group('AttendanceTrendCard', () {
    Future<void> pumpCard(
      WidgetTester tester,
      AsyncValue<AttendanceTrend> trend,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: AttendanceTrendCard(trend: trend)),
        ),
      );
      await tester.pump();
    }

    CustomPainter? trendPainterOf(WidgetTester tester) {
      final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      for (final paint in paints) {
        if (paint.painter is TrendChartPainter) return paint.painter;
      }
      return null;
    }

    testWidgets(
      'a week with no attendance renders an empty state, not a curve',
      (tester) async {
        await pumpCard(tester, const AsyncData(AttendanceTrend.empty));

        expect(find.text('Not enough data yet'), findsOneWidget);
        expect(trendPainterOf(tester), isNull);
      },
    );

    testWidgets(
      'a still-loading trend renders a loading state, not "no data"',
      (tester) async {
        // `null` means the records have not been read yet — claiming "not
        // enough data" here would assert something the card cannot know.
        await pumpCard(tester, const AsyncLoading());

        expect(find.text('Loading…'), findsOneWidget);
        expect(find.text('Not enough data yet'), findsNothing);
        expect(trendPainterOf(tester), isNull);
      },
    );

    testWidgets('a week with attendance renders the trend chart', (
      tester,
    ) async {
      await pumpCard(
        tester,
        AsyncData(
          AttendanceTrend.fromRecords([
            _record(id: 'a1', date: '2026-08-24', primaryStatus: 'present'),
          ], weekStart),
        ),
      );

      expect(find.text('Not enough data yet'), findsNothing);
      expect(trendPainterOf(tester), isNotNull);
    });

    testWidgets('a failed read renders an error state, not a loading state', (
      tester,
    ) async {
      // Device QA (CPH2455) hit `no such table: attendance` — a hard,
      // permanent failure. Rendering that as "Loading…" told the user to
      // wait for something that was never going to arrive.
      await pumpCard(
        tester,
        AsyncError<AttendanceTrend>(
          Exception('no such table: attendance'),
          StackTrace.empty,
        ),
      );

      expect(find.text('Couldn’t load your trend'), findsOneWidget);
      expect(find.text('Loading…'), findsNothing);
      expect(find.text('Not enough data yet'), findsNothing);
      expect(trendPainterOf(tester), isNull);
    });

    testWidgets('the rendered curve changes when the underlying data changes', (
      tester,
    ) async {
      await pumpCard(
        tester,
        AsyncData(
          AttendanceTrend.fromRecords([
            _record(id: 'a1', date: '2026-08-24', primaryStatus: 'present'),
          ], weekStart),
        ),
      );
      final first = trendPainterOf(tester)! as TrendChartPainter;

      await pumpCard(
        tester,
        AsyncData(
          AttendanceTrend.fromRecords([
            _record(id: 'a1', date: '2026-08-24', primaryStatus: 'present'),
            _record(id: 'a2', date: '2026-08-24', primaryStatus: 'absent'),
            _record(id: 'a3', date: '2026-08-26', primaryStatus: 'absent'),
          ], weekStart),
        ),
      );
      final second = trendPainterOf(tester)! as TrendChartPainter;

      expect(second.percentages, isNot(equals(first.percentages)));
      expect(second.shouldRepaint(first), isTrue);
    });
  });
}
