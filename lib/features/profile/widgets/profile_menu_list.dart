import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ProfileMenuList extends StatelessWidget {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;

    return Container(
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXxl,
        border: Border.all(color: cc.line),
      ),
      clipBehavior: Clip.antiAlias, // ensure ripple respects border radius
      child: Column(
        children: [
          CCListRow(
            icon: Symbols.layers,
            label: 'Semesters',
            showBorder: true,
            onTap: () => context.push(RoutePaths.semester),
          ),
          CCListRow(
            icon: Symbols.timer,
            label: 'Focus Mode',
            showBorder: true,
            onTap: () => context.push(RoutePaths.focusMode),
          ),
          CCListRow(
            icon: Symbols.notifications,
            label: 'Notifications',
            showBorder: true,
            onTap: () => context.push(RoutePaths.notifications),
          ),
          CCListRow(
            icon: Symbols.settings,
            label: 'Settings',
            showBorder: true,
            onTap: () => context.push(RoutePaths.settings),
          ),
          CCListRow(
            icon: Symbols.sync,
            label: 'Data & Sync',
            subtitle: 'Last synced: Today, 9:30 AM',
            trailing: Icon(Symbols.check_circle, color: cc.pri, fill: 1.0),
            showBorder: true,
            onTap: () => context.push(RoutePaths.dataSync),
          ),
          CCListRow(
            icon: Symbols.help,
            label: 'Help & Support',
            showBorder: true,
            onTap: () => context.push(RoutePaths.helpSupport),
          ),
          CCListRow(
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
