import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class DataSyncScreen extends StatelessWidget {
  const DataSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Data & Sync',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSyncStatusCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAccountInfoCard(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSection(
              context: context,
              title: 'Sync Preferences',
              children: [
                _SettingsSwitchRow(
                  icon: Symbols.autorenew,
                  label: 'Auto Sync',
                  value: true,
                  onChanged: (val) {},
                  showBorder: true,
                ),
                _SettingsSwitchRow(
                  icon: Symbols.wifi,
                  label: 'Sync over Wi-Fi only',
                  value: true,
                  onChanged: (val) {},
                  showBorder: true,
                ),
                _SettingsSwitchRow(
                  icon: Symbols.cached,
                  label: 'Background Sync',
                  value: false,
                  onChanged: (val) {},
                  showBorder: false,
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSection(
              context: context,
              title: 'Storage & Cache',
              children: [
                const _StorageInfoRow(
                  icon: Symbols.sd_storage,
                  label: 'Local Storage',
                  value: '12.4 MB',
                  showBorder: true,
                ),
                const _StorageInfoRow(
                  icon: Symbols.cloud,
                  label: 'Cloud Storage',
                  value: '45.1 MB',
                  showBorder: true,
                ),
                const _StorageInfoRow(
                  icon: Symbols.memory,
                  label: 'Cache',
                  value: '8.2 MB',
                  showBorder: false,
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildInfoFooter(context),
            const SizedBox(height: SpacingTokens.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(BuildContext context) {
    final theme = Theme.of(context);

    return CCCard(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: ColorTokens.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Symbols.check_circle,
              color: ColorTokens.success,
              size: 40,
              fill: 1.0,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'All data synced',
            style: theme.textTheme.titleLarge?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Last synced: Today, 9:30 AM',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {}, // TODO: Implement manual sync
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.primary,
                foregroundColor: ColorTokens.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: const RoundedRectangleBorder(
                  borderRadius: RadiusTokens.borderRadiusLg,
                ),
              ),
              child: const Text(
                'Sync Now',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return CCCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: ColorTokens.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'J',
              style: theme.textTheme.titleLarge?.copyWith(
                color: ColorTokens.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syncing to',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
                Text(
                  'jayeshpatil@gmail.com',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
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
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
            border: Border.all(
              color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Symbols.info,
            size: 20,
            color: ColorTokens.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              'Data is encrypted locally and in transit. Your college credentials are never sent to our servers.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorTokens.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.showBorder,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.cardPadding,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorTokens.onSurfaceVariant),
          const SizedBox(width: SpacingTokens.base),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ColorTokens.surface,
            activeTrackColor: ColorTokens.primary,
            inactiveThumbColor: ColorTokens.outline,
            inactiveTrackColor: ColorTokens.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

class _StorageInfoRow extends StatelessWidget {
  const _StorageInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showBorder,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorTokens.onSurfaceVariant),
          const SizedBox(width: SpacingTokens.base),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ColorTokens.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
