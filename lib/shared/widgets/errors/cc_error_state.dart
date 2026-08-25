/// Error state routing.
///
/// Every screen used to render [NetworkErrorWidget] directly from its
/// `error:` branch, so a local SQLite failure told the user to check their
/// internet connection (issue #34). That mislabelling is what made the
/// missing-tables bug (#33) take a device pull and a logcat trace to
/// diagnose — the UI actively pointed away from the real cause.
///
/// Screens now hand the error to [CcErrorState] and let it decide. The
/// decision lives in exactly one place, so a screen written tomorrow
/// inherits the right behaviour instead of having to remember this.
library;

import 'dart:async';
import 'dart:io';

import 'package:college_companion/core/errors/exceptions.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:flutter/material.dart';

/// What kind of failure an error represents.
enum CcErrorKind {
  /// A genuine transport failure — the device could not reach the network.
  network,

  /// A local data failure: SQLite, a repository, or a missing record.
  data,

  /// Nothing recognisable. Deliberately NOT [network].
  unknown,
}

/// Type names of third-party exceptions recognised without importing the
/// packages that declare them.
///
/// Matching on the name keeps the widget layer free of `sqlite3`, `drift`,
/// and `http` imports, which the architecture rules keep out of the UI. The
/// cost is that a rename upstream degrades a [data] to an [unknown] — both
/// render a non-network message, so the guarantee that matters still holds.
const Set<String> _dataErrorTypeNames = {
  'SqliteException',
  'DriftRemoteException',
  'DriftWrappedException',
  'CouldNotRollBackException',
};

const Set<String> _networkErrorTypeNames = {
  'ClientException',
  'AuthRetryableFetchException',
  'SocketException',
  'HandshakeException',
};

/// Classifies [error] so the UI can describe it honestly.
///
/// [CcErrorKind.network] requires positive evidence of a transport failure.
/// Anything unrecognised falls through to [CcErrorKind.unknown] rather than
/// being blamed on connectivity — defaulting to "network" is precisely the
/// bug this function exists to prevent.
CcErrorKind classifyError(Object? error) {
  if (error == null) return CcErrorKind.unknown;

  // Local data failures are checked first: a DatabaseException may well wrap
  // a cause whose text mentions a host or a connection, and the outer type is
  // the more reliable signal.
  if (error is AppException) return CcErrorKind.data;

  if (error is SocketException ||
      error is HttpException ||
      error is TimeoutException) {
    return CcErrorKind.network;
  }

  final typeName = error.runtimeType.toString();
  if (_dataErrorTypeNames.contains(typeName)) return CcErrorKind.data;
  if (_networkErrorTypeNames.contains(typeName)) return CcErrorKind.network;

  return CcErrorKind.unknown;
}

/// Renders the error state appropriate to [error].
///
/// Use this instead of reaching for [NetworkErrorWidget] directly — screens
/// are not in a position to know what kind of failure they are holding.
class CcErrorState extends StatelessWidget {
  const CcErrorState({required this.error, this.onRetry, super.key});

  /// The error as delivered by `AsyncValue.error` or a catch clause.
  final Object? error;

  /// Invoked by the retry affordance. When null, no retry is offered.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (classifyError(error)) {
      CcErrorKind.network => NetworkErrorWidget(onRetry: onRetry),
      CcErrorKind.data when onRetry != null => RetryStateWidget(
        onRetry: onRetry!,
      ),
      _ => UnknownErrorWidget(onRetry: onRetry),
    };
  }
}
