library;

import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the dashboard presentation model.
///
/// Currently returns static mock data. Once backend integration begins,
/// this provider will aggregate data from repositories and perform synthesis.
final dashboardSnapshotProvider = Provider<DashboardSnapshot>((ref) {
  return DashboardSnapshot.mockHeavyDay();
});
