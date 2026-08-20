/// Settings Providers
///
/// Riverpod providers for user settings dependencies and reactive streams.
library;

import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:college_companion/providers/app_providers.dart'
    show userSettingsRepositoryProvider;

/// Watches user settings for a given user.
final userSettingsStreamProvider =
    StreamProvider.family<UserSettingsEntity?, String>((ref, userId) {
      final repo = ref.watch(userSettingsRepositoryProvider);
      return repo.watchByUserId(userId);
    });
