/// CCListRow — Shared Grouped List Row
///
/// The single row primitive for every "grouped settings/menu list" section
/// across the app (ADR-011 redesign). Consolidates what had been five
/// near-identical private row widgets (`profile_menu_list.dart`'s
/// `_MenuItem`, `settings_screen.dart`'s `_SettingsRow`/`_SettingsSwitchRow`,
/// `about_screen.dart`/`help_support_screen.dart`'s `_ActionRow`,
/// `data_sync_screen.dart`'s `_SettingsSwitchRow`/`_StorageInfoRow`) into one
/// token-driven widget.
library;

import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A single row inside a grouped list container (see [CCSection]).
///
/// Supports an optional [subtitle], and at most one trailing element —
/// [trailingText], a custom [trailing] widget (e.g. a [Switch]), or the
/// default chevron (suppressed via [hideChevron]).
class CCListRow extends StatelessWidget {
  const CCListRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailingText,
    this.trailing,
    this.iconColor,
    this.labelColor,
    this.hideChevron = false,
    required this.showBorder,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final bool hideChevron;
  final bool showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: cc.raise2,
        child: Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            border: showBorder
                ? Border(bottom: BorderSide(color: cc.line))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? cc.mut),
              const SizedBox(width: SpacingTokens.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: labelColor ?? cc.fg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: SpacingTokens.xxs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cc.mut,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                Flexible(
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                trailing!,
              ],
              if (!hideChevron && trailing == null) ...[
                const SizedBox(width: SpacingTokens.sm),
                Icon(Symbols.chevron_right, color: cc.mut),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
