/// Notification Providers
///
/// Riverpod providers for notification-related dependencies and reactive streams.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/notifications/repositories/notification_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [NotificationRepository] instance.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final syncQueueRepository = ref.watch(syncQueueRepositoryProvider);
  return NotificationRepository(database, syncQueueRepository);
});

/// Watches all non-deleted notifications for a user.
final notificationsStreamProvider =
    StreamProvider.family<List<NotificationEntity>, String>((ref, userId) {
      final repo = ref.watch(notificationRepositoryProvider);
      return repo.watchAll(userId);
    });
