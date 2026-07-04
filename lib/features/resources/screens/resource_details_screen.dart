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

class ResourceDetailsScreen extends StatelessWidget {
  const ResourceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.more_vert),
            onPressed: () {
              // TODO: Show context menu
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: LayoutTokens.screenPadding,
            right: LayoutTokens.screenPadding,
            bottom: LayoutTokens.bottomNavigationHeight + SpacingTokens.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroCard(context),
              const SizedBox(height: SpacingTokens.xl),
              _buildQuickActions(context),
              const SizedBox(height: SpacingTokens.xl),
              _buildFileInformation(context),
              const SizedBox(height: SpacingTokens.xl),
              _buildStorageInformationCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(SpacingTokens.xxl),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Symbols.picture_as_pdf,
            size: 64,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        Text(
          'Operating Systems Unit 3 Notes',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorTokens.onSurface,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Operating Systems',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: ColorTokens.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xxs,
              ),
              decoration: const BoxDecoration(
                color: ColorTokens.surfaceContainer,
                borderRadius: RadiusTokens.borderRadiusSm,
              ),
              child: Text(
                'PDF',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ColorTokens.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            Text(
              '2.4 MB',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: SpacingTokens.md),
            const Text(
              '•',
              style: TextStyle(color: ColorTokens.onSurfaceVariant),
            ),
            const SizedBox(width: SpacingTokens.md),
            Text(
              'Modified Yesterday',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(context, 'Open', Symbols.open_in_new, () {
          // TODO: Implement open file logic
        }),
        _buildActionButton(context, 'Share', Symbols.share, () {
          // TODO: Implement share file logic
        }),
        _buildActionButton(context, 'Rename', Symbols.edit, () {
          // TODO: Implement rename file logic
        }),
        _buildActionButton(context, 'Delete', Symbols.delete, () {
          // TODO: Implement delete file logic
        }, isDestructive: true),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? ColorTokens.error : ColorTokens.primary;

    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: color,
          style: IconButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(SpacingTokens.md),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDestructive
                ? ColorTokens.error
                : ColorTokens.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInformation(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            'File Information',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          child: Column(
            children: [
              _buildInfoRow(context, 'Subject', 'Operating Systems'),
              const Divider(
                height: SpacingTokens.xl,
                color: ColorTokens.outlineVariant,
              ),
              _buildInfoRow(context, 'Semester', 'Semester 5'),
              const Divider(
                height: SpacingTokens.xl,
                color: ColorTokens.outlineVariant,
              ),
              _buildInfoRow(context, 'Category', 'Lecture Notes'),
              const Divider(
                height: SpacingTokens.xl,
                color: ColorTokens.outlineVariant,
              ),
              _buildInfoRow(context, 'Created', 'Oct 12, 2023'),
              const Divider(
                height: SpacingTokens.xl,
                color: ColorTokens.outlineVariant,
              ),
              _buildInfoRow(context, 'Modified', 'Oct 14, 2023, 10:30 AM'),
              const Divider(
                height: SpacingTokens.xl,
                color: ColorTokens.outlineVariant,
              ),
              _buildInfoRow(context, 'Storage', 'Local Device'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStorageInformationCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: const BoxDecoration(
        color: ColorTokens.tertiaryContainer,
        borderRadius: RadiusTokens.borderRadiusLg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Symbols.offline_pin,
            color: ColorTokens.onTertiaryContainer,
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stored locally',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ColorTokens.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'This resource is available offline and remains only on this device.\n\nIt is never uploaded to your cloud account.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ColorTokens.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
