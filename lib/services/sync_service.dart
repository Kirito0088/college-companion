/// Sync Service
///
/// Flushes pending local mutations queued in [SyncQueueRepository] to Supabase.
/// Implements exponential backoff for retries and keeps local state as source of truth.
library;

import 'dart:async';
import 'dart:math';

import 'package:college_companion/core/repositories/sync_queue_repository.dart';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/services/connectivity_service.dart';
import 'package:college_companion/services/supabase_service.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Orchestrates synchronization between local Drift storage and Supabase cloud.
class SyncService {
  /// Creates a [SyncService].
  SyncService({
    required this.syncQueueRepository,
    required this.database,
    SupabaseClient? supabaseClient,
    ConnectivityService? connectivityService,
  })  : _syncSupabaseClient = supabaseClient,
        _connectivityService = connectivityService ?? ConnectivityService() {
    _initConnectivityListener();
  }

  static const String _tag = 'SyncService';
  static const int _maxRetries = 5;

  /// Sync queue repository instance.
  final SyncQueueRepository syncQueueRepository;
  final AppDatabase database;
  final SupabaseClient? _syncSupabaseClient;
  final ConnectivityService _connectivityService;

  SupabaseClient get _supabaseClient =>
      _syncSupabaseClient ?? SupabaseService.client;

  StreamSubscription<InternetStatus>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Returns `true` if synchronization is currently in progress.
  bool get isSyncing => _isSyncing;

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivityService.onStatusChange.listen(
      (status) {
        if (status == InternetStatus.connected) {
          AppLogger.info('Connectivity restored, triggering sync', tag: _tag);
          unawaited(syncPendingMutations());
        }
      },
    );
  }

  /// Cancels subscriptions when disposing.
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Flushes pending queue items to Supabase if connected.
  Future<void> syncPendingMutations() async {
    if (_isSyncing) return;

    final isConnected = await _connectivityService.hasInternetAccess;
    if (!isConnected) {
      AppLogger.info('Device offline, skipping sync batch', tag: _tag);
      return;
    }

    _isSyncing = true;
    try {
      final pendingItems = await syncQueueRepository.getPendingItems();
      if (pendingItems.isEmpty) {
        _isSyncing = false;
        return;
      }

      AppLogger.info(
        'Syncing ${pendingItems.length} pending mutations to Supabase',
        tag: _tag,
      );

      for (final item in pendingItems) {
        if (item.retryCount >= _maxRetries) {
          AppLogger.info(
            'Sync item ${item.id} exceeded max retries (${item.retryCount}), skipping',
            tag: _tag,
          );
          continue;
        }

        try {
          // Process sync mutation to Supabase table
          await _processItem(item);
          await syncQueueRepository.markSynced(item.id);
        } catch (e, stack) {
          AppLogger.error(
            'Failed sync item ${item.id} (attempt ${item.retryCount + 1})',
            error: e,
            stackTrace: stack,
          );
          await syncQueueRepository.recordFailure(
            item.id,
            e.toString(),
            item.retryCount,
          );
          // Apply backoff before processing next items in batch: pow(2, retryCount) * 500ms
          final delayMs = pow(2, item.retryCount).toInt() * 500;
          await Future<void>.delayed(Duration(milliseconds: delayMs));
        }
      }

      // Clean up old synced records
      await syncQueueRepository.purgeSyncedItems();
    } finally {
      _isSyncing = false;
    }
  }

  /// Processes a single sync queue item using deterministic offline-first logic.
  /// Reads local row state from Drift DB as offline source of truth.
  Future<void> _processItem(SyncQueueItem item) async {
    final targetTable = item.targetTable;
    final recordId = item.recordId;
    final operation = item.operation.toUpperCase();

    AppLogger.info(
      'Processing $operation sync item for table $targetTable, recordId: $recordId',
      tag: _tag,
    );

    if (operation == 'DELETE') {
      await _supabaseClient.from(targetTable).delete().eq('id', recordId);
      return;
    }

    // For INSERT and UPDATE, read latest local row payload from Drift DB
    final payload = await _fetchRowPayload(targetTable, recordId);
    if (payload != null) {
      await _supabaseClient.from(targetTable).upsert(payload);
    } else {
      AppLogger.info(
        'Row $recordId in table $targetTable not found locally, skipping upsert',
        tag: _tag,
      );
    }
  }

  /// Fetches row payload from Drift DB by [targetTable] and [recordId], converting to snake_case Map.
  Future<Map<String, dynamic>?> _fetchRowPayload(
    String targetTable,
    String recordId,
  ) async {
    Map<String, dynamic>? jsonMap;

    switch (targetTable) {
      case 'semesters':
        final entity = await (database.select(database.semesters)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'subjects':
        final entity = await (database.select(database.subjects)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'attendance':
        final entity = await (database.select(database.attendance)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'timetable':
        final entity = await (database.select(database.timetable)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'assignments':
        final entity = await (database.select(database.assignments)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'calendar_events':
        final entity = await (database.select(database.calendarEvents)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'resources':
        final entity = await (database.select(database.resources)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'internal_marks':
        final entity = await (database.select(database.internalMarks)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'users':
        final entity = await (database.select(database.users)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      case 'user_settings':
        final entity = await (database.select(database.userSettings)
              ..where((t) => t.id.equals(recordId)))
            .getSingleOrNull();
        if (entity != null) jsonMap = entity.toJson();
        break;
      default:
        AppLogger.info('Unknown targetTable: $targetTable', tag: _tag);
        return null;
    }

    if (jsonMap == null) return null;

    return _toSnakeCaseMap(jsonMap);
  }

  /// Converts camelCase keys from Drift entity toJson() to snake_case keys for Supabase API.
  Map<String, dynamic> _toSnakeCaseMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final snakeKey = entry.key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => '_${match.group(1)!.toLowerCase()}',
      );
      result[snakeKey] = entry.value;
    }
    return result;
  }
}
