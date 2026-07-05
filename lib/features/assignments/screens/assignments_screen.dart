import 'package:college_companion/features/assignments/widgets/assignment_card.dart';
import 'package:college_companion/features/assignments/widgets/assignments_fab.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExtended = true;
  int _selectedFilterIndex = 0;
  MockUiState _uiState = MockUiState.success;
  final List<String> _filters = [
    'All',
    'Pending',
    'Due Today',
    'Overdue',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isFabExtended) setState(() => _isFabExtended = false);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isFabExtended) setState(() => _isFabExtended = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: LayoutTokens.screenPadding,
                      vertical: SpacingTokens.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchField(theme),
                        const SizedBox(height: SpacingTokens.lg),
                        _buildFilterChips(theme),
                        const SizedBox(height: SpacingTokens.lg),
                        _buildProgressSummaryCard(theme),
                        const SizedBox(height: SpacingTokens.xl),
                        _buildAssignmentList(context),
                        const SizedBox(height: 120), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: SpacingTokens.xl,
              right: LayoutTokens.screenPadding,
              child: AssignmentsFab(isExtended: _isFabExtended),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LayoutTokens.screenPadding,
        SpacingTokens.xl,
        LayoutTokens.screenPadding,
        SpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignments',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorTokens.onSurface,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Track all assignments across your subjects.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search assignments...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: ColorTokens.onSurfaceVariant,
        ),
        prefixIcon: const Icon(
          Symbols.search,
          color: ColorTokens.onSurfaceVariant,
        ),
        filled: true,
        fillColor: ColorTokens.surfaceContainerHigh,
        border: const OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusLg,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.lg,
        ),
      ),
    );
  }

  Widget _buildProgressSummaryCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusMd,
        border: Border.all(color: ColorTokens.surfaceVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.onSurface,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: ColorTokens.surfaceVariant,
                    color: ColorTokens.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '75%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ColorTokens.primary,
                ),
              ),
              Text(
                '8 of 12 done',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.sm),
            child: AnimatedTheme(
              data: theme.copyWith(canvasColor: Colors.transparent),
              child: FilterChip(
                label: Text(_filters[index]),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                },
                backgroundColor: ColorTokens.surfaceContainer,
                selectedColor: ColorTokens.primaryContainer,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? ColorTokens.onPrimaryContainer
                      : ColorTokens.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : ColorTokens.outlineVariant,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusMd,
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: 0,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context) {
    switch (_uiState) {
      case MockUiState.loading:
        return const SkeletonList();
      case MockUiState.empty:
        return const EmptyAssignments();
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
        if (_selectedFilterIndex == 3) {
          return const EmptyAssignments();
        }
        final assignments = [
          AssignmentCard(
            title: 'Operating Systems Assignment 3',
            subject: 'Operating Systems',
            subjectColor: Colors.blue,
            dueDate: 'Tomorrow',
            status: 'Pending',
            statusColor: ColorTokens.warning,
            priority: 'High Priority',
            onTap: () => context.push(RoutePaths.assignmentDetails),
          ),
          AssignmentCard(
            title: 'Database Lab Report',
            subject: 'DBMS',
            subjectColor: Colors.green,
            dueDate: 'Aug 5',
            status: 'Due Today',
            statusColor: ColorTokens.primary,
            onTap: () => context.push(RoutePaths.assignmentDetails),
          ),
          AssignmentCard(
            title: 'WT Mini Project',
            subject: 'Web Technology',
            subjectColor: Colors.amber,
            dueDate: 'Completed',
            status: 'Completed',
            statusColor: ColorTokens.success,
            onTap: () => context.push(RoutePaths.assignmentDetails),
          ),
        ];

        return Column(
          children: List.generate(assignments.length, (index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
                      child: child,
                    ),
                  ),
                );
              },
              child: assignments[index],
            );
          }),
        );
    }
  }
}
