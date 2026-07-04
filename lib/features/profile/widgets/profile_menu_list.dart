import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(
            alpha: 0.2,
          ), // simulating surface-variant border
        ),
      ),
      clipBehavior: Clip.antiAlias, // ensure ripple respects border radius
      child: Column(
        children: [
          const _MenuItem(
            icon: Symbols.layers,
            label: 'Semesters',
            showBorder: true,
          ),
          _MenuItem(
            icon: Symbols.view_module,
            label: 'Modules',
            showBorder: true,
            onTap: () => context.push(RoutePaths.manageModules),
          ),
          _MenuItem(
            icon: Symbols.settings,
            label: 'Settings',
            showBorder: true,
            onTap: () => context.push(RoutePaths.settings),
          ),
          _MenuItem(
            icon: Symbols.sync,
            label: 'Data & Sync',
            subtitle: 'Last synced: Today, 9:30 AM',
            trailingIcon: Symbols.check_circle,
            trailingIconColor: ColorTokens.success,
            trailingIconFilled: true,
            showBorder: true,
            onTap: () => context.push(RoutePaths.dataSync),
          ),
          _MenuItem(
            icon: Symbols.help,
            label: 'Help & Support',
            showBorder: true,
            onTap: () => context.push(RoutePaths.helpSupport),
          ),
          _MenuItem(
            icon: Symbols.info,
            label: 'About College Companion',
            showBorder: false,
            onTap: () => context.push(RoutePaths.about),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingIcon,
    this.trailingIconColor,
    this.trailingIconFilled = false,
    required this.showBorder,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final bool trailingIconFilled;
  final bool showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {}, // TODO: Navigate
        hoverColor: ColorTokens.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.all(
            LayoutTokens.cardPadding,
          ), // p-card-padding
          decoration: BoxDecoration(
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: ColorTokens.outlineVariant.withValues(
                        alpha: 0.3,
                      ), // simulate divide
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: ColorTokens.onSurfaceVariant),
              const SizedBox(width: SpacingTokens.base), // gap-4
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: ColorTokens.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorTokens.onSurfaceVariant,
                          fontSize: 12, // text-xs
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                Icon(
                  trailingIcon,
                  color: trailingIconColor ?? ColorTokens.onSurfaceVariant,
                  fill: trailingIconFilled ? 1.0 : 0.0,
                ),
              ],
              const SizedBox(width: SpacingTokens.sm),
              const Icon(
                Symbols.chevron_right,
                color: ColorTokens.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
