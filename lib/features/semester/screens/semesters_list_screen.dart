import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SemestersListScreen extends StatefulWidget {
  const SemestersListScreen({super.key});

  @override
  State<SemestersListScreen> createState() => _SemestersListScreenState();
}

class _SemestersListScreenState extends State<SemestersListScreen> {
  MockUiState _uiState = MockUiState.success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Static placeholder data indicating the current semester
    const int currentSemester = 5;

    // Calculate the current academic year's semesters
    const int currentYearStart = currentSemester % 2 == 0
        ? currentSemester - 1
        : currentSemester;
    const int currentYearEnd = currentYearStart + 1;

    final List<Map<String, dynamic>> currentYearSemesters = [
      _generateSemesterData(currentYearStart, currentSemester),
      _generateSemesterData(currentYearEnd, currentSemester),
    ];

    final List<Map<String, dynamic>> previousSemesters = [];
    for (int i = currentYearStart - 1; i >= 1; i--) {
      previousSemesters.add(_generateSemesterData(i, currentSemester));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: ColorTokens.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Semesters',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(
        context,
        currentSemester,
        currentYearSemesters,
        previousSemesters,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    int currentSemester,
    List<Map<String, dynamic>> currentYearSemesters,
    List<Map<String, dynamic>> previousSemesters,
  ) {
    switch (_uiState) {
      case MockUiState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: LayoutTokens.screenPadding),
          child: SkeletonList(),
        );
      case MockUiState.empty:
        return const EmptySubjects();
      case MockUiState.error:
        return NetworkErrorWidget(
          onRetry: () {
            setState(() {
              _uiState = MockUiState.loading;
              Future.delayed(
                const Duration(seconds: 1),
                () => setState(() => _uiState = MockUiState.success),
              );
            });
          },
        );
      case MockUiState.success:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: LayoutTokens.sectionGap),
              _CurrentSemesterBanner(currentSemester: currentSemester),
              const SizedBox(height: LayoutTokens.sectionGap),

              // Current Academic Year
              Text(
                'Current Academic Year',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorTokens.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              ...currentYearSemesters.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: _SemesterCard(data: s),
                ),
              ),

              // Previous Semesters
              if (previousSemesters.isNotEmpty) ...[
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Previous Semesters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                ...previousSemesters.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                    child: _SemesterCard(data: s),
                  ),
                ),
              ],

              const SizedBox(height: SpacingTokens.xxl),
            ],
          ),
        );
    }
  }

  Map<String, dynamic> _generateSemesterData(
    int semesterNum,
    int currentSemester,
  ) {
    if (semesterNum == currentSemester) {
      return {
        'title': 'Semester $semesterNum',
        'status': 'Active',
        'timeline': 'July 2026 – Nov 2026',
        'subjects': '7',
        'credits': '24',
        'attendance': '82%',
        'progress': 0.68,
      };
    } else if (semesterNum > currentSemester) {
      return {
        'title': 'Semester $semesterNum',
        'status': 'Upcoming',
        'timeline': 'Jan 2027 – May 2027',
        'subjects': '—',
        'credits': '—',
        'attendance': '—',
      };
    } else {
      return {
        'title': 'Semester $semesterNum',
        'status': 'Completed',
        'timeline': 'Jan 2026 – May 2026',
        'subjects': '6',
        'credits': '22',
        'attendance': '88%',
      };
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your academic journey.',
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Track every semester in one place.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CurrentSemesterBanner extends StatelessWidget {
  const _CurrentSemesterBanner({required this.currentSemester});

  final int currentSemester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: ColorTokens.primaryContainer.withValues(alpha: 0.25),
      borderRadius: RadiusTokens.borderRadiusXl,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.semesterDetails),
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Semester',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: ColorTokens.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Continue',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: ColorTokens.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      const Icon(
                        Symbols.arrow_forward,
                        size: 16,
                        color: ColorTokens.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Semester $currentSemester',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ColorTokens.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '68% Complete',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ColorTokens.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.md),
              LinearProgressIndicator(
                value: 0.68,
                backgroundColor: ColorTokens.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                color: ColorTokens.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String status = data['status'] as String;
    final bool isActive = status == 'Active';

    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusXl,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RoutePaths.semesterDetails),
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] as String,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ColorTokens.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          data['timeline'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: SpacingTokens.lg),
              const Divider(height: 1, color: ColorTokens.outlineVariant),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(
                    label: 'Subjects',
                    value: data['subjects'] as String,
                  ),
                  _InfoChip(label: 'Credits', value: data['credits'] as String),
                  _InfoChip(
                    label: 'Attendance',
                    value: data['attendance'] as String,
                  ),
                ],
              ),
              if (isActive && data['progress'] != null) ...[
                const SizedBox(height: SpacingTokens.lg),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: data['progress'] as double,
                        backgroundColor: ColorTokens.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        color: ColorTokens.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Text(
                      '${((data['progress'] as double) * 100).toInt()}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ColorTokens.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;

    switch (status) {
      case 'Active':
        backgroundColor = ColorTokens.primaryContainer;
        foregroundColor = ColorTokens.onPrimaryContainer;
        break;
      case 'Completed':
        backgroundColor = ColorTokens.success;
        foregroundColor = ColorTokens.onSuccess;
        break;
      case 'Upcoming':
      default:
        backgroundColor = ColorTokens.surfaceContainerHighest;
        foregroundColor = ColorTokens.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.6),
        borderRadius: RadiusTokens.borderRadiusSm,
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xxs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: ColorTokens.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
