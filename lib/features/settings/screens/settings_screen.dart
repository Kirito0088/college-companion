import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _lectureReminders = true;

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
          'Settings',
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
            _buildSection(
              context: context,
              title: 'Account',
              children: [
                _SettingsRow(
                  icon: Symbols.person,
                  label: 'Account Information',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.accountInformation),
                ),
                _SettingsRow(
                  icon: Symbols.lock,
                  label: 'Privacy & Security',
                  showBorder: false,
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSection(
              context: context,
              title: 'Notifications',
              children: [
                _SettingsSwitchRow(
                  icon: Symbols.notifications,
                  label: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (val) {
                    setState(() {
                      _pushNotifications = val;
                    });
                  },
                  showBorder: true,
                ),
                _SettingsSwitchRow(
                  icon: Symbols.schedule,
                  label: 'Lecture Reminders',
                  value: _lectureReminders,
                  onChanged: (val) {
                    setState(() {
                      _lectureReminders = val;
                    });
                  },
                  showBorder: false,
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSection(
              context: context,
              title: 'Study & Focus',
              children: [
                _SettingsRow(
                  icon: Symbols.timer,
                  label: 'Focus Mode',
                  showBorder: false,
                  onTap: () => context.push(RoutePaths.focusMode),
                ),
              ],
            ),

            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSection(
              context: context,
              title: 'Data & Sync',
              children: [
                _SettingsRow(
                  icon: Symbols.sync,
                  label: 'Sync Data',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.dataSync),
                ),
                _SettingsRow(
                  icon: Symbols.delete,
                  label: 'Clear Cache',
                  textColor: ColorTokens.error,
                  iconColor: ColorTokens.error,
                  showBorder: false,
                  hideChevron: true,
                  onTap: () {
                    CCDialogs.showDeleteConfirmation(
                      context,
                      title: 'Clear Cache',
                      message:
                          'Are you sure you want to clear the local cache? This will not delete your account data.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSection(
              context: context,
              title: 'About',
              children: [
                const _SettingsRow(
                  icon: Symbols.info,
                  label: 'App Version',
                  trailingText: 'v1.0.0',
                  hideChevron: true,
                  showBorder: true,
                ),
                _SettingsRow(
                  icon: Symbols.description,
                  label: 'Terms of Service',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.termsConditions),
                ),
                _SettingsRow(
                  icon: Symbols.policy,
                  label: 'Privacy Policy',
                  showBorder: false,
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.huge),
          ],
        ),
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
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailingText,
    this.textColor,
    this.iconColor,
    this.hideChevron = false,
    required this.showBorder,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? trailingText;
  final Color? textColor;
  final Color? iconColor;
  final bool hideChevron;
  final bool showBorder;
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
              Icon(icon, color: iconColor ?? ColorTokens.onSurfaceVariant),
              const SizedBox(width: SpacingTokens.base),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor ?? ColorTokens.onSurface,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  trailingText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                  ),
                ),
              ],
              if (!hideChevron) ...[
                const SizedBox(width: SpacingTokens.sm),
                const Icon(
                  Symbols.chevron_right,
                  color: ColorTokens.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
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
        vertical: SpacingTokens
            .sm, // Slightly less vertical padding due to switch size
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
