import 'dart:io';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _localPushNotifications;
  bool _lectureReminders = true;
  String _cacheSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _calculateCacheSize();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        if (prefs.containsKey('push_notifications')) {
          _localPushNotifications = prefs.getBool('push_notifications');
        }
      });
    }
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;
      if (tempDir.existsSync()) {
        tempDir.listSync(recursive: true, followLinks: false).forEach((entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
      if (mounted) {
        setState(() {
          _cacheSize = '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheSize = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final userId = authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final settingsAsync = ref.watch(userSettingsStreamProvider(userId));
    final dbSettings = settingsAsync.valueOrNull;

    final pushNotifications = _localPushNotifications ?? (dbSettings?.notificationsEnabled ?? true);

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
                  value: pushNotifications,
                  onChanged: (val) async {
                    if (val) {
                      final status = await Permission.notification.request();
                      if (status.isDenied || status.isPermanentlyDenied) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please enable notifications in system settings.'),
                              action: SnackBarAction(
                                label: 'Settings',
                                onPressed: () => openAppSettings(),
                              ),
                            ),
                          );
                        }
                        val = false;
                      }
                    }

                    setState(() {
                      _localPushNotifications = val;
                    });
                    
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('push_notifications', val);

                    final repo = ref.read(userSettingsRepositoryProvider);
                    final nowIso = DateTime.now().toUtc().toIso8601String();
                    final existing = await repo.getByUserId(userId);
                    if (existing != null) {
                      await repo.saveSettings(
                        UserSettingsCompanion(
                          id: Value(existing.id),
                          userId: Value(userId),
                          notificationsEnabled: Value(val),
                          updatedAt: Value(nowIso),
                        ),
                      );
                    } else {
                      await repo.saveSettings(
                        UserSettingsCompanion(
                          id: Value('settings_$userId'),
                          userId: Value(userId),
                          notificationsEnabled: Value(val),
                          createdAt: Value(nowIso),
                          updatedAt: Value(nowIso),
                        ),
                      );
                    }
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
                  trailingText: _cacheSize,
                  textColor: ColorTokens.error,
                  iconColor: ColorTokens.error,
                  showBorder: false,
                  hideChevron: true,
                  onTap: () async {
                    final confirmed = await CCDialogs.showDeleteConfirmation(
                      context,
                      title: 'Clear Cache',
                      message:
                          'Are you sure you want to clear the local cache? This will not delete your account data.',
                    );
                    if (confirmed == true && context.mounted) {
                      final prefs = await SharedPreferences.getInstance();
                      // Remove non-essential keys
                      final keysToKeep = ['push_notifications', 'last_sync_timestamp'];
                      final allKeys = prefs.getKeys();
                      for (final key in allKeys) {
                        if (!keysToKeep.contains(key)) {
                          await prefs.remove(key);
                        }
                      }
                      
                      try {
                        final tempDir = await getTemporaryDirectory();
                        if (tempDir.existsSync()) {
                          tempDir.listSync(recursive: true).forEach((entity) {
                            if (entity is File) {
                              entity.deleteSync();
                            }
                          });
                        }
                      } catch (e) {
                        // ignore
                      }
                      
                      await _calculateCacheSize();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Local cache cleared successfully'),
                          ),
                        );
                      }
                    }
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

