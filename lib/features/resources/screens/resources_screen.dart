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

// OFFLINE-FIRST ARCHITECTURE
//
// Resources are stored only on the local device.
// SQLite/Drift indexes metadata.
// Actual files remain in local storage.
//
// Supabase is intentionally NOT used for storing
// PDFs, images, videos, or other large assets.

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  MockUiState _uiState = MockUiState.success;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Favorites',
    'Lecture Notes',
    'Lab Manuals',
    'Question Papers',
    'Books',
    'Syllabus',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: LayoutTokens.screenPadding,
                        right: LayoutTokens.screenPadding,
                        top: SpacingTokens.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSearchBar(context),
                          const SizedBox(height: SpacingTokens.lg),
                          _buildRecentResources(context),
                          _buildCategories(context),
                          const SizedBox(height: SpacingTokens.xl),
                        ],
                      ),
                    ),
                  ),
                  _buildResourcesList(context),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          LayoutTokens.bottomNavigationHeight +
                          SpacingTokens.xl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LayoutTokens.screenPadding,
        SpacingTokens.md,
        LayoutTokens.screenPadding,
        SpacingTokens.sm,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.home);
              }
            },
            icon: const Icon(Symbols.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: ColorTokens.surfaceContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusMd,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resources',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.onSurface,
                  ),
                ),
                Text(
                  'Manage all your study materials in one place.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.lg,
        vertical: SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Symbols.search, color: ColorTokens.onSurfaceVariant),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              'Search resources...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.sm),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: ColorTokens.surfaceContainer,
              selectedColor: ColorTokens.primaryContainer,
              checkmarkColor: ColorTokens.onPrimaryContainer,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? ColorTokens.onPrimaryContainer
                    : ColorTokens.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusLg,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : ColorTokens.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResourcesList(BuildContext context) {
    switch (_uiState) {
      case MockUiState.loading:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.screenPadding,
            ),
            child: SkeletonList(),
          ),
        );
      case MockUiState.empty:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyResources(),
        );
      case MockUiState.error:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: NetworkErrorWidget(
            onRetry: () {
              setState(() {
                _uiState = MockUiState.loading;
                Future.delayed(
                  const Duration(seconds: 1),
                  () => setState(() => _uiState = MockUiState.success),
                );
              });
            },
          ),
        );
      case MockUiState.success:
        if (_selectedCategory != 'All') {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyResources(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildResourceCard(
                context,
                icon: Symbols.picture_as_pdf,
                title: 'Operating Systems Unit 3 Notes',
                subject: 'Operating Systems',
                fileType: 'PDF',
                fileSize: '2.4 MB',
                lastModified: 'Yesterday',
                iconColor: Colors.redAccent,
                isFavorite: true,
              ),
              const SizedBox(height: SpacingTokens.md),
              _buildResourceCard(
                context,
                icon: Symbols.picture_as_pdf,
                title: 'DBMS Lab Manual',
                subject: 'Database Management',
                fileType: 'PDF',
                fileSize: '5.1 MB',
                lastModified: 'Monday',
                iconColor: Colors.redAccent,
                isFavorite: false,
              ),
              const SizedBox(height: SpacingTokens.md),
              _buildResourceCard(
                context,
                icon: Symbols.description,
                title: 'Question Paper 2025',
                subject: 'Computer Networks',
                fileType: 'PDF',
                fileSize: '1.2 MB',
                lastModified: '2 weeks ago',
                iconColor: Colors.blueAccent,
                isFavorite: true,
              ),
            ]),
          ),
        );
    }
  }

  Widget _buildRecentResources(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Viewed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildRecentResourceCard(
                context,
                icon: Symbols.picture_as_pdf,
                title: 'Data Structures...',
                subject: 'Computer Science',
                timeAgo: '2 hours ago',
                color: Colors.redAccent,
              ),
              const SizedBox(width: SpacingTokens.md),
              _buildRecentResourceCard(
                context,
                icon: Symbols.description,
                title: 'Math Assignment',
                subject: 'Mathematics',
                timeAgo: 'Yesterday',
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }

  Widget _buildRecentResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subject,
    required String timeAgo,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: RadiusTokens.borderRadiusMd,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: ColorTokens.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            subject,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ColorTokens.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            timeAgo,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subject,
    required String fileType,
    required String fileSize,
    required String lastModified,
    required Color iconColor,
    bool isFavorite = false,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusXl,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(RoutePaths.resourceDetails);
        },
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.md),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: RadiusTokens.borderRadiusLg,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: SpacingTokens.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ColorTokens.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      children: [
                        Text(
                          fileType,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        const Text(
                          '•',
                          style: TextStyle(color: ColorTokens.onSurfaceVariant),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          fileSize,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: ColorTokens.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        const Text(
                          '•',
                          style: TextStyle(color: ColorTokens.onSurfaceVariant),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            lastModified,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: ColorTokens.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFavorite ? Symbols.bookmark : Symbols.bookmark_border,
                    color: isFavorite
                        ? ColorTokens.primary
                        : ColorTokens.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  const Icon(
                    Symbols.chevron_right,
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
