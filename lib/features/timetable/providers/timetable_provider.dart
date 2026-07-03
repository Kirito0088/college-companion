/// Timetable Providers
///
/// Riverpod providers for timetable-related dependencies.
library;

import 'package:college_companion/features/timetable/repositories/timetable_repository.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [TimetableRepository] instance.
final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TimetableRepository(database);
});
