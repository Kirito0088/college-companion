import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/assignments/providers/assignments_provider.dart';
import 'package:college_companion/features/assignments/widgets/assignment_card.dart';
import 'package:college_companion/features/assignments/widgets/assignments_fab.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_error_state.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isFabExtended = true;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final assignmentsAsync = ref.watch(assignmentsStreamProvider(userId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme, cc),
                Expanded(
                  child: assignmentsAsync.when(
                    data: (allAssignments) {
                      // Filter by search query
                      final searchFiltered = allAssignments.where((a) {
                        if (_searchQuery.isEmpty) return true;
                        return a.title.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            a.subjectId.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                      }).toList();

                      // Filter by chip category
                      final filtered = searchFiltered.where((a) {
                        final status = a.status.toLowerCase();
                        switch (_selectedFilterIndex) {
                          case 1:
                            return status == 'pending';
                          case 2:
                            final due = DateTime.tryParse(a.dueDate);
                            if (due != null) {
                              final now = DateTime.now();
                              return due.year == now.year &&
                                  due.month == now.month &&
                                  due.day == now.day;
                            }
                            return status == 'due today';
                          case 3:
                            return status == 'overdue';
                          case 4:
                            return status == 'completed';
                          case 0:
                          default:
                            return true;
                        }
                      }).toList();

                      // Overview progress metrics
                      final totalCount = allAssignments.length;
                      final completedCount = allAssignments
                          .where((a) => a.status.toLowerCase() == 'completed')
                          .length;
                      final progress = totalCount > 0
                          ? (completedCount / totalCount).clamp(0.0, 1.0)
                          : 0.0;

                      return SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: LayoutTokens.screenPadding,
                          vertical: SpacingTokens.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchField(theme, cc),
                            const SizedBox(height: SpacingTokens.lg),
                            _buildFilterChips(theme, cc),
                            const SizedBox(height: SpacingTokens.lg),
                            _buildProgressSummaryCard(
                              theme,
                              cc,
                              progress: progress,
                              completedCount: completedCount,
                              totalCount: totalCount,
                            ),
                            const SizedBox(height: SpacingTokens.xl),
                            _buildAssignmentList(context, cc, filtered),
                            const SizedBox(height: 120),
                          ],
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: LayoutTokens.screenPadding,
                        vertical: SpacingTokens.md,
                      ),
                      child: SkeletonList(),
                    ),
                    error: (err, stack) => CcErrorState(
                      error: err,
                      onRetry: () {
                        ref.invalidate(assignmentsStreamProvider(userId));
                      },
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

  Widget _buildHeader(ThemeData theme, CCTokens cc) {
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
              color: cc.fg,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Track all assignments across your subjects.',
            style: theme.textTheme.bodyLarge?.copyWith(color: cc.mut),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, CCTokens cc) {
    return TextField(
      controller: _searchController,
      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search assignments...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: cc.mut),
        prefixIcon: Icon(Symbols.search, color: cc.mut),
        filled: true,
        fillColor: cc.raise2,
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

  Widget _buildProgressSummaryCard(
    ThemeData theme,
    CCTokens cc, {
    required double progress,
    required int completedCount,
    required int totalCount,
  }) {
    final pctString = '${(progress * 100).round()}%';
    final doneString = '$completedCount of $totalCount done';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusMd,
        border: Border.all(color: cc.line),
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
                    color: cc.fg,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: cc.line,
                    color: cc.pri,
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
                pctString,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cc.pri,
                ),
              ),
              Text(
                doneString,
                style: theme.textTheme.labelSmall?.copyWith(color: cc.mut),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, CCTokens cc) {
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
                backgroundColor: cc.raise,
                selectedColor: cc.priSoft,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? cc.pri : cc.mut,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : cc.line,
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

  Widget _buildAssignmentList(
    BuildContext context,
    CCTokens cc,
    List<AssignmentEntity> filteredAssignments,
  ) {
    if (filteredAssignments.isEmpty) {
      return const EmptyAssignments();
    }

    final cards = filteredAssignments.map((entity) {
      Color statusColor = cc.pri;
      final st = entity.status.toLowerCase();
      if (st == 'completed') {
        statusColor = cc.pri;
      } else if (st == 'overdue') {
        statusColor = cc.risk;
      } else if (st == 'pending') {
        statusColor = cc.warn;
      }

      final dueDt = DateTime.tryParse(entity.dueDate);
      final dueStr = dueDt != null
          ? '${dueDt.month}/${dueDt.day}'
          : entity.dueDate;

      return AssignmentCard(
        title: entity.title,
        subject: entity.subjectId,
        subjectColor: cc.pri,
        dueDate: dueStr,
        status: entity.status,
        statusColor: statusColor,
        onTap: () => context.push('/assignment-details/${entity.id}'),
      );
    }).toList();

    return Column(
      children: List.generate(cards.length, (index) {
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
          child: cards[index],
        );
      }),
    );
  }
}
