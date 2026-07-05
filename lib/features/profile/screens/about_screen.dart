import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
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
          children: [
            _buildHeader(context),
            const SizedBox(height: SpacingTokens.xl),
            _buildSectionCard(
              context,
              title: 'Information',
              children: const [
                _ActionRow(
                  icon: Symbols.info,
                  label: 'About the App',
                  showBorder: true,
                ),
                _ActionRow(
                  icon: Symbols.target,
                  label: 'Our Mission',
                  showBorder: true,
                ),
                _ActionRow(
                  icon: Symbols.featured_play_list,
                  label: 'Features',
                  showBorder: true,
                ),
                _ActionRow(
                  icon: Symbols.groups,
                  label: 'Credits & Contributors',
                  showBorder: false,
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSectionCard(
              context,
              title: 'Legal',
              children: [
                _ActionRow(
                  icon: Symbols.gavel,
                  label: 'Open Source Licenses',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.openSourceLicenses),
                ),
                _ActionRow(
                  icon: Symbols.policy,
                  label: 'Privacy Policy',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
                _ActionRow(
                  icon: Symbols.description,
                  label: 'Terms of Service',
                  showBorder: false,
                  onTap: () => context.push(RoutePaths.termsConditions),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSectionCard(
              context,
              title: 'Links',
              children: const [
                _ActionRow(
                  icon: Symbols.language,
                  label: 'Website',
                  showBorder: true,
                  trailingIcon: Symbols.open_in_new,
                ),
                _ActionRow(
                  icon: Symbols.code,
                  label: 'GitHub Repository',
                  showBorder: true,
                  trailingIcon: Symbols.open_in_new,
                ),
                _ActionRow(
                  icon: Symbols.contact_support,
                  label: 'Contact Developer',
                  showBorder: false,
                  trailingIcon: Symbols.open_in_new,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xxl),
            _buildFooter(context),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: ColorTokens.primaryContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          child: const Center(
            child: Icon(Symbols.school, size: 40, color: ColorTokens.primary),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          'College Companion',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Version 1.0.0 (Build 42)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'Your ultimate academic sidekick.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
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
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
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

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '© 2026 College Companion',
          style: theme.textTheme.bodySmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Built with Flutter',
          style: theme.textTheme.bodySmall?.copyWith(
            color: ColorTokens.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Made with ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
            const Icon(Symbols.favorite, size: 14, color: ColorTokens.error),
            Text(
              ' for students',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.showBorder,
    this.trailingIcon = Symbols.chevron_right,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool showBorder;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        hoverColor: ColorTokens.surfaceContainerHigh,
        child: Container(
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
              Icon(icon, color: ColorTokens.onSurfaceVariant, size: 22),
              const SizedBox(width: SpacingTokens.base),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: ColorTokens.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Icon(trailingIcon, color: ColorTokens.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
