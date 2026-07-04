import 'package:college_companion/routing/app_router.dart';
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
    // Determine which list to show based on category or empty state
    // For this UI implementation, we show placeholder data if "All" is selected,
    // and empty state otherwise to demonstrate both views.
    if (_selectedCategory != 'All') {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(context),
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

  Widget _buildRecentResources(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.md,
          ),
          child: Text(
            'Recent Resources',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildCompactResourceCard(
          context,
          icon: Symbols.picture_as_pdf,
          title: 'Operating Systems Unit 3 Notes',
          time: 'Yesterday',
          iconColor: Colors.redAccent,
        ),
        const SizedBox(height: SpacingTokens.sm),
        _buildCompactResourceCard(
          context,
          icon: Symbols.picture_as_pdf,
          title: 'DBMS Lab Manual',
          time: 'Monday',
          iconColor: Colors.redAccent,
        ),
        const SizedBox(height: SpacingTokens.sm),
        _buildCompactResourceCard(
          context,
          icon: Symbols.description,
          title: 'WT Question Paper',
          time: '2 days ago',
          iconColor: Colors.blueAccent,
        ),
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }

  Widget _buildCompactResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusLg,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(RoutePaths.resourceDetails);
        },
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                time,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              const Icon(
                Symbols.chevron_right,
                size: 20,
                color: ColorTokens.onSurfaceVariant,
              ),
            ],
          ),
        ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.screenPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.xxl),
            decoration: const BoxDecoration(
              color: ColorTokens.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symbols.folder_open,
              size: 64,
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Text(
            'No Resources Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Import your study materials to access them offline.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          FilledButton.icon(
            onPressed: () {
              // TODO: Future file picker integration
            },
            icon: const Icon(Symbols.upload_file),
            label: const Text('Import Resources'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.xl,
                vertical: SpacingTokens.md,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: RadiusTokens.borderRadiusXl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
