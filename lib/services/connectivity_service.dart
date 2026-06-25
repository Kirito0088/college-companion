/// Connectivity Service
///
/// Monitors network connectivity state for the offline-first architecture.
/// Uses connectivity_plus for network state and
/// internet_connection_checker_plus for actual internet verification.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service responsible for monitoring network connectivity.
///
/// The app should continue functioning without internet
/// (per 00-project-vision.md).
class ConnectivityService {
  /// Creates a [ConnectivityService].
  ConnectivityService({
    Connectivity? connectivity,
    InternetConnection? internetConnection,
  }) : _connectivity = connectivity ?? Connectivity(),
       _internetConnection = internetConnection ?? InternetConnection();

  final Connectivity _connectivity;
  final InternetConnection _internetConnection;

  /// Stream of connectivity changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Checks if the device currently has internet access.
  Future<bool> get hasInternetAccess => _internetConnection.hasInternetAccess;

  /// Stream indicating whether internet is available.
  Stream<InternetStatus> get onStatusChange =>
      _internetConnection.onStatusChange;
}
