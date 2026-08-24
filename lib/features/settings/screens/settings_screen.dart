import 'dart:convert';
import 'dart:io';
import 'package:college_companion/database/app_database.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/shared/widgets/cc_section.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/providers/app_theme_provider.dart';
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
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final userId =
        authState is AuthAuthenticated && authState.user.uid.isNotEmpty
        ? authState.user.uid
        : 'default_user';

    final settingsAsync = ref.watch(userSettingsStreamProvider(userId));
    final dbSettings = settingsAsync.valueOrNull;

    final pushNotifications =
        _localPushNotifications ?? (dbSettings?.notificationsEnabled ?? true);

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
          'Settings',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppearanceSection(userId: userId),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'Account',
              children: [
                CCListRow(
                  icon: Symbols.person,
                  label: 'Account Information',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.accountInformation),
                ),
                CCListRow(
                  icon: Symbols.lock,
                  label: 'Privacy & Security',
                  showBorder: false,
                  onTap: () => context.push(RoutePaths.privacyPolicy),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'Notifications',
              children: [
                CCListRow(
                  icon: Symbols.notifications,
                  label: 'Push Notifications',
                  showBorder: true,
                  trailing: Switch(
                    value: pushNotifications,
                    onChanged: (val) async {
                      if (val) {
                        final status = await Permission.notification.request();
                        if (status.isDenied || status.isPermanentlyDenied) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please enable notifications in system settings.',
                                ),
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
                  ),
                ),
                CCListRow(
                  icon: Symbols.schedule,
                  label: 'Lecture Reminders',
                  showBorder: false,
                  trailing: Switch(
                    value: _lectureReminders,
                    onChanged: (val) {
                      setState(() {
                        _lectureReminders = val;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),

            CCSection(
              title: 'Data & Sync',
              children: [
                CCListRow(
                  icon: Symbols.sync,
                  label: 'Sync Data',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.dataSync),
                ),
                CCListRow(
                  icon: Symbols.delete,
                  label: 'Clear Cache',
                  trailingText: _cacheSize,
                  labelColor: cc.risk,
                  iconColor: cc.risk,
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
                      final keysToKeep = [
                        'push_notifications',
                        'last_sync_timestamp',
                      ];
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
            CCSection(
              title: 'About',
              children: [
                const CCListRow(
                  icon: Symbols.info,
                  label: 'App Version',
                  trailingText: 'v1.0.0',
                  hideChevron: true,
                  showBorder: true,
                ),
                CCListRow(
                  icon: Symbols.description,
                  label: 'Terms of Service',
                  showBorder: true,
                  onTap: () => context.push(RoutePaths.termsConditions),
                ),
                CCListRow(
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
}

/// Dark/Light toggle + jade/sand/azure accent picker (ADR-011, Slice 3).
///
/// Reads the resolved preference from [appThemeProvider] and writes through
/// [UserSettingsRepository.updateTheme]/`updateAccent` — the same
/// read-stream/write-repo shape as the Push Notifications toggle above.
///
/// [UserSettingsRepository.updateTheme]/`updateAccent` both require an
/// existing settings row (an `UPDATE ... WHERE userId` and, for `updateAccent`,
/// an explicit null-check that throws). A brand-new account has no row yet —
/// the Push Notifications toggle above already handles this with a
/// get-or-create; [_setTheme]/[_setAccent] mirror that same pattern.
class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection({required this.userId});

  final String userId;

  Future<void> _setTheme(WidgetRef ref, String value) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final existing = await repo.getByUserId(userId);
    if (existing == null) {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await repo.saveSettings(
        UserSettingsCompanion(
          id: Value('settings_$userId'),
          userId: Value(userId),
          theme: Value(value),
          createdAt: Value(nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    } else {
      await repo.updateTheme(userId, value);
    }
  }

  Future<void> _setAccent(WidgetRef ref, String accentName) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final existing = await repo.getByUserId(userId);
    if (existing == null) {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await repo.saveSettings(
        UserSettingsCompanion(
          id: Value('settings_$userId'),
          userId: Value(userId),
          preferences: Value(jsonEncode({'accent': accentName})),
          createdAt: Value(nowIso),
          updatedAt: Value(nowIso),
        ),
      );
    } else {
      await repo.updateAccent(userId, accentName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cc = context.cc;
    final preference = ref.watch(appThemeProvider);
    final brightness = theme.brightness;

    return CCSection(
      title: 'Appearance',
      children: [
        Padding(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme',
                style: theme.textTheme.labelLarge?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  Expanded(
                    child: _ThemeOptionChip(
                      label: 'Light',
                      selected: preference.themeMode == ThemeMode.light,
                      onTap: () => _setTheme(ref, 'light'),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: _ThemeOptionChip(
                      label: 'Dark',
                      selected: preference.themeMode == ThemeMode.dark,
                      onTap: () => _setTheme(ref, 'dark'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'Accent',
                style: theme.textTheme.labelLarge?.copyWith(color: cc.mut),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Row(
                children: [
                  for (final accent in Accent.values)
                    Padding(
                      padding: const EdgeInsets.only(right: SpacingTokens.md),
                      child: _AccentSwatch(
                        label:
                            accent.name[0].toUpperCase() +
                            accent.name.substring(1),
                        color: CCTokens.resolve(brightness, accent).pri,
                        selected: preference.accent == accent,
                        onTap: () => _setAccent(ref, accent.name),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionChip extends StatelessWidget {
  const _ThemeOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Material(
      color: selected ? cc.priSoft : cc.raise2,
      borderRadius: RadiusTokens.borderRadiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.borderRadiusLg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: RadiusTokens.borderRadiusLg,
            border: Border.all(color: selected ? cc.pri : cc.line),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? cc.pri : cc.mut,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return InkWell(
      onTap: onTap,
      borderRadius: RadiusTokens.borderRadiusLg,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? cc.fg : Colors.transparent,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: selected
                ? Icon(Symbols.check, color: cc.bg, size: 18, fill: 1.0)
                : null,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: cc.mut),
          ),
        ],
      ),
    );
  }
}
