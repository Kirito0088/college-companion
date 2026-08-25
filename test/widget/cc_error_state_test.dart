/// Tests covering issue #34 — every screen rendered `NetworkErrorWidget`
/// unconditionally in its `error:` branch, so a local SQLite failure told the
/// user to check their internet connection. That mislabelling is what made
/// #33 take a device pull and a logcat trace to diagnose: the UI actively
/// pointed away from the real cause.
///
/// The rule these tests pin is that "network" requires positive evidence.
/// Anything else degrades to a neutral message rather than blaming
/// connectivity, so a failure mode nobody anticipated is labelled honestly
/// instead of confidently wrongly.
library;

import 'dart:async';
import 'dart:io';

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/shared/widgets/errors/cc_error_state.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _UnrecognisedFailure implements Exception {}

/// Stands in for `package:sqlite3`'s exception of the same name.
///
/// The classifier recognises it by type name rather than by importing
/// sqlite3/drift into the widget layer, so a double whose `runtimeType` is
/// literally `SqliteException` exercises the real code path.
class SqliteException implements Exception {
  const SqliteException(this.message);
  final String message;
  @override
  String toString() => 'SqliteException(1): $message';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('classifyError', () {
    test('classifies genuine transport failures as network', () {
      expect(
        classifyError(const SocketException('failed host lookup')),
        CcErrorKind.network,
      );
      expect(classifyError(const HttpException('502')), CcErrorKind.network);
      expect(classifyError(TimeoutException('timed out')), CcErrorKind.network);
    });

    test('classifies local data failures as data, never network', () {
      // This is the exact failure that shipped as "check your internet
      // connection" on a physical device — see #33.
      expect(
        classifyError(
          const DatabaseException(
            'Failed to watch attendance',
            'SqliteException(1): no such table: attendance',
          ),
        ),
        CcErrorKind.data,
      );
      expect(
        classifyError(const RepositoryException('read failed')),
        CcErrorKind.data,
      );
      expect(
        classifyError(const NotFoundException('missing')),
        CcErrorKind.data,
      );
    });

    test('classifies a raw sqlite failure as data', () {
      // Drift surfaces these without wrapping when a query fails outside a
      // repository's try/catch, so the classifier cannot rely on
      // `AppException` alone.
      expect(
        classifyError(const SqliteException('no such table: attendance')),
        CcErrorKind.data,
      );
    });

    test('an unrecognised error is unknown, NOT network', () {
      // The single most important assertion here: the fallback must never be
      // "network". Defaulting to network is what made #33 point at the wrong
      // layer for two milestones.
      expect(classifyError(_UnrecognisedFailure()), CcErrorKind.unknown);
      expect(classifyError('some string'), CcErrorKind.unknown);
      expect(classifyError(null), CcErrorKind.unknown);
    });
  });

  group('no screen reaches for NetworkErrorWidget directly', () {
    // The guard that makes this a route fix rather than ten patches. Screens
    // are not in a position to know whether the error they are holding is a
    // transport failure, so the choice belongs to CcErrorState alone. Without
    // this test, the next screen someone writes re-lands issue #34.
    test('lib/features contains no direct NetworkErrorWidget usage', () {
      final offenders = <String>[];

      for (final entity in Directory(
        'lib/features',
      ).listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.readAsStringSync().contains('NetworkErrorWidget')) {
          offenders.add(entity.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'These screens name NetworkErrorWidget directly and will report '
            'local data failures as connectivity problems. Use CcErrorState '
            'and let it classify the error instead: ${offenders.join(', ')}',
      );
    });
  });

  group('CcErrorState', () {
    Future<void> pump(
      WidgetTester tester,
      Object? error, {
      VoidCallback? onRetry,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CcErrorState(error: error, onRetry: onRetry),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('renders the network error only for a transport failure', (
      tester,
    ) async {
      await pump(tester, const SocketException('failed host lookup'));

      expect(find.byType(NetworkErrorWidget), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
    });

    testWidgets('a local database failure never mentions the network', (
      tester,
    ) async {
      await pump(
        tester,
        const DatabaseException('no such table: attendance'),
        onRetry: () {},
      );

      expect(find.byType(NetworkErrorWidget), findsNothing);
      expect(find.text('Network Error'), findsNothing);
      expect(find.textContaining('internet', findRichText: true), findsNothing);
    });

    testWidgets('an unrecognised failure never mentions the network', (
      tester,
    ) async {
      await pump(tester, _UnrecognisedFailure(), onRetry: () {});

      expect(find.byType(NetworkErrorWidget), findsNothing);
      expect(find.textContaining('internet'), findsNothing);
    });

    testWidgets('surfaces the retry action it was given', (tester) async {
      var retried = false;
      await pump(
        tester,
        const DatabaseException('boom'),
        onRetry: () => retried = true,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('renders without a retry action when none is given', (
      tester,
    ) async {
      await pump(tester, const DatabaseException('boom'));

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
