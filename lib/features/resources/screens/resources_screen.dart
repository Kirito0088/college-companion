import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/resources/providers/resources_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/empty_states/cc_empty_states.dart';
import 'package:college_companion/shared/widgets/errors/cc_error_state.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final resourcesAsync = ref.watch(resourcesStreamProvider(userId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ExcludeSemantics(
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
                            resourcesAsync.maybeWhen(
                              data: (list) =>
                                  _buildRecentResources(context, list),
                              orElse: () =>
                                  _buildRecentResources(context, const []),
                            ),
                            _buildCategories(context),
                            const SizedBox(height: SpacingTokens.xl),
                          ],
                        ),
                      ),
                    ),
                    _buildResourcesList(context, resourcesAsync, userId),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
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
              backgroundColor: cc.raise,
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
                    color: cc.fg,
                  ),
                ),
                Text(
                  'Manage all your study materials in one place.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
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
    final cc = context.cc;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(color: cc.line.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search resources...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
          prefixIcon: Icon(Symbols.search, color: cc.mut),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final cc = context.cc;
    return ExcludeSemantics(
      child: SingleChildScrollView(
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
                backgroundColor: cc.raise,
                selectedColor: cc.priSoft,
                checkmarkColor: cc.pri,
                labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? cc.pri : cc.mut,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : cc.line.withValues(alpha: 0.5),
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
      ),
    );
  }

  Widget _buildResourcesList(
    BuildContext context,
    AsyncValue<List<ResourceEntity>> resourcesAsync,
    String userId,
  ) {
    return resourcesAsync.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: LayoutTokens.screenPadding),
          child: SkeletonList(),
        ),
      ),
      error: (err, stack) => SliverFillRemaining(
        hasScrollBody: false,
        child: CcErrorState(
          error: err,
          onRetry: () {
            ref.invalidate(resourcesStreamProvider(userId));
          },
        ),
      ),
      data: (allResources) {
        final filtered = allResources.where((r) {
          // Category filter
          if (_selectedCategory == 'Favorites') {
            if (!r.category.toLowerCase().contains('fav')) return false;
          } else if (_selectedCategory != 'All') {
            if (!r.category.toLowerCase().contains(
              _selectedCategory.toLowerCase(),
            )) {
              return false;
            }
          }
          // Search filter
          if (_searchQuery.isNotEmpty) {
            if (!r.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                !(r.subjectId?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false)) {
              return false;
            }
          }
          return true;
        }).toList();

        if (filtered.isEmpty) {
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
            delegate: SliverChildBuilderDelegate((context, index) {
              final r = filtered[index];
              final isPdf =
                  r.url.toLowerCase().contains('pdf') ||
                  r.category.toLowerCase().contains('notes') ||
                  r.category.toLowerCase().contains('paper');
              final icon = isPdf ? Symbols.picture_as_pdf : Symbols.description;
              final iconColor = isPdf ? Colors.redAccent : Colors.blueAccent;
              final isFav = r.category.toLowerCase().contains('fav');

              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                child: _buildResourceCard(
                  context,
                  resourceId: r.id,
                  icon: icon,
                  title: r.title,
                  subject: r.subjectId ?? 'General',
                  fileType: isPdf ? 'PDF' : 'DOC',
                  fileSize: '2.4 MB',
                  lastModified: r.updatedAt.length > 10
                      ? r.updatedAt.substring(0, 10)
                      : r.updatedAt,
                  iconColor: iconColor,
                  isFavorite: isFav,
                ),
              );
            }, childCount: filtered.length),
          ),
        );
      },
    );
  }

  Widget _buildRecentResources(
    BuildContext context,
    List<ResourceEntity> list,
  ) {
    final cc = context.cc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Viewed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cc.fg,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        ExcludeSemantics(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: list.isNotEmpty
                  ? list.take(3).map((r) {
                      final isPdf =
                          r.url.toLowerCase().contains('pdf') ||
                          r.category.toLowerCase().contains('notes');
                      return Padding(
                        padding: const EdgeInsets.only(right: SpacingTokens.md),
                        child: _buildRecentResourceCard(
                          context,
                          icon: isPdf
                              ? Symbols.picture_as_pdf
                              : Symbols.description,
                          title: r.title,
                          subject: r.subjectId ?? 'General',
                          timeAgo: r.updatedAt.length > 10
                              ? r.updatedAt.substring(0, 10)
                              : 'Recent',
                          color: isPdf ? Colors.redAccent : Colors.blueAccent,
                        ),
                      );
                    }).toList()
                  : [
                      _buildRecentResourceCard(
                        context,
                        icon: Symbols.picture_as_pdf,
                        title: 'Data Structures Notes',
                        subject: 'CS201',
                        timeAgo: '2h ago',
                        color: Colors.redAccent,
                      ),
                      _buildRecentResourceCard(
                        context,
                        icon: Symbols.description,
                        title: 'OS Lab Manual',
                        subject: 'CS204',
                        timeAgo: 'Yesterday',
                        color: Colors.blueAccent,
                      ),
                    ],
            ),
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
    final cc = context.cc;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusLg,
        border: Border.all(color: cc.line.withValues(alpha: 0.2)),
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
              color: cc.fg,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            subject,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cc.pri),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            timeAgo,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: cc.mut),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required String resourceId,
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
    final cc = context.cc;
    return Material(
      color: cc.raise,
      borderRadius: RadiusTokens.borderRadiusXl,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/resource-details/$resourceId');
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
                        color: cc.fg,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cc.pri,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            fileType,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cc.mut,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text('•', style: TextStyle(color: cc.mut)),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          fileSize,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cc.mut,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text('•', style: TextStyle(color: cc.mut)),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            lastModified,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cc.mut,
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
                    color: isFavorite ? cc.pri : cc.mut,
                    size: 24,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Icon(Symbols.chevron_right, color: cc.mut),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
