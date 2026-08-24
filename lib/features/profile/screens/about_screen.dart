import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/shared/widgets/cc_section.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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
    final cc = context.cc;

    return Scaffold(
      backgroundColor: cc.bg,
      appBar: AppBar(
        backgroundColor: cc.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: cc.fg,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'About',
          style: theme.textTheme.titleLarge?.copyWith(
            color: cc.fg,
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
            const CCSection(
              title: 'INFORMATION',
              children: [
                CCListRow(
                  icon: Symbols.info,
                  label: 'About the App',
                  showBorder: true,
                ),
                CCListRow(
                  icon: Symbols.target,
                  label: 'Our Mission',
                  showBorder: true,
                ),
                CCListRow(
                  icon: Symbols.featured_play_list,
                  label: 'Features',
                  showBorder: true,
                ),
                CCListRow(
                  icon: Symbols.groups,
                  label: 'Credits & Contributors',
                  showBorder: false,
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'LEGAL',
              children: [
                CCListRow(
                  icon: Symbols.gavel,
                  label: 'Open Source Licenses',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.openSourceLicenses),
                ),
                CCListRow(
                  icon: Symbols.policy,
                  label: 'Privacy Policy',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
                CCListRow(
                  icon: Symbols.description,
                  label: 'Terms of Service',
                  showBorder: false,
                  onTap: () => context.push(RoutePaths.termsConditions),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'LINKS',
              children: [
                CCListRow(
                  icon: Symbols.language,
                  label: 'Website',
                  showBorder: true,
                  trailing: Icon(Symbols.open_in_new, color: cc.mut, size: 20),
                ),
                CCListRow(
                  icon: Symbols.code,
                  label: 'GitHub Repository',
                  showBorder: true,
                  trailing: Icon(Symbols.open_in_new, color: cc.mut, size: 20),
                ),
                CCListRow(
                  icon: Symbols.contact_support,
                  label: 'Contact Developer',
                  showBorder: false,
                  trailing: Icon(Symbols.open_in_new, color: cc.mut, size: 20),
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
    final cc = context.cc;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cc.priSoft,
            borderRadius: RadiusTokens.borderRadiusXxl,
          ),
          child: Center(child: Icon(Symbols.school, size: 40, color: cc.pri)),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          'College Companion',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Version 1.0.0 (Build 42)',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cc.mut,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'Your ultimate academic sidekick.',
          style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Column(
      children: [
        Text(
          '© 2026 College Companion',
          style: theme.textTheme.bodySmall?.copyWith(color: cc.mut),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          'Built with Flutter',
          style: theme.textTheme.bodySmall?.copyWith(color: cc.mut),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Made with ',
              style: theme.textTheme.bodySmall?.copyWith(color: cc.mut),
            ),
            Icon(Symbols.favorite, size: 14, color: cc.risk),
            Text(
              ' for students',
              style: theme.textTheme.bodySmall?.copyWith(color: cc.mut),
            ),
          ],
        ),
      ],
    );
  }
}
