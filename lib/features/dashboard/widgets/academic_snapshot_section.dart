/// Academic Snapshot Section Widget
///
/// Displays a synthesized summary of macro-level academic status.
library;

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/dashboard/models/dashboard_snapshot.dart';
import 'package:college_companion/features/dashboard/providers/dashboard_provider.dart';
import 'package:college_companion/features/dashboard/widgets/attendance_ring.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:college_companion/theme/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A section displaying interpreted academic states to provide reassurance.
class AcademicSnapshotSection extends ConsumerWidget {
  /// Creates a [AcademicSnapshotSection].
  const AcademicSnapshotSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';
    final snapshot =
        ref.watch(dashboardSnapshotProvider(userId)).valueOrNull ??
        DashboardSnapshot.empty();
    final theme = Theme.of(context);
    final cc = context.cc;
    final stats = snapshot.academicSnapshot;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Academic Snapshot',
          style: TypographyTokens.serifTextTheme.titleLarge?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.md,
            horizontal: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXxl,
            border: Border.all(color: cc.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AttendanceRing(
                      percentage: stats.attendancePercentage,
                      isSafe: stats.isAttendanceSafe,
                      hasData: stats.hasAttendanceData,
                      size: 56,
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      'Attendance',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cc.mut,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              _buildStatCard(
                context: context,
                icon: Symbols.school_rounded,
                iconColor: cc.warn,
                value: stats.workloadState,
                label: 'Workload',
                valueColor: cc.warn,
              ),
              _buildStatCard(
                context: context,
                icon: Symbols.assignment_rounded,
                iconColor: cc.pri,
                value: stats.deadlinesState,
                label: 'Deadlines',
              ),
              _buildStatCard(
                context: context,
                icon: Symbols
                    .coffee_rounded, // Replaced timer with coffee for break
                iconColor: cc.pri,
                value: stats.nextBreakState,
                label: 'Next Break',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24, fill: 1.0),
          const SizedBox(height: SpacingTokens.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor ?? cc.fg,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cc.mut,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
