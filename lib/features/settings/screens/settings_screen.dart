import 'dart:io';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/models/notification_preferences.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/shared/widgets/cc_section.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/providers/app_theme_provider.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _cacheSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  /// Turns the master switch on or off. Turning it on asks for the Android
  /// 13+ notification permission first; if the student declines, the switch
  /// stays off and they are pointed to system settings.
  Future<void> _setPush(String userId, bool enabled) async {
    if (enabled) {
      final status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
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
        return;
      }
    }
    await _save(
      () => ref
          .read(userSettingsRepositoryProvider)
          .updateNotificationPreferences(userId, notificationsEnabled: enabled),
    );
  }

  /// Runs a settings write, telling the student if it did not stick rather
  /// than letting the error vanish into an unawaited future.
  Future<void> _save(Future<void> Function() write) async {
    try {
      await write();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Saving a setting failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save that setting. Please try again."),
        ),
      );
    }
  }

  /// A reminder-channel switch row.
  Widget _channelSwitch({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required bool enabled,
    required bool showBorder,
    required Future<void> Function(bool) save,
  }) {
    return CCListRow(
      icon: icon,
      label: label,
      subtitle: subtitle,
      showBorder: showBorder,
      trailing: Switch(
        value: value,
        onChanged: enabled ? (val) => _save(() => save(val)) : null,
      ),
    );
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
    // The database is the only source: the reminder scheduler plans from
    // the same row (#11).
    final notifications = notificationPreferencesFrom(
      settingsAsync.valueOrNull,
    );
    final repo = ref.read(userSettingsRepositoryProvider);
    // Nothing is editable until the stored values are known, so a slow or
    // failed load cannot be mistaken for "everything on".
    final loaded = settingsAsync.hasValue && !settingsAsync.hasError;
    // Channel switches mean nothing while everything is off.
    final channelsEnabled = loaded && notifications.notificationsEnabled;

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
                    value: notifications.notificationsEnabled,
                    onChanged: loaded ? (val) => _setPush(userId, val) : null,
                  ),
                ),
                _channelSwitch(
                  icon: Symbols.schedule,
                  label: 'Lecture Reminders',
                  subtitle:
                      '${lectureReminderLead.inMinutes} minutes before '
                      'each class',
                  value: notifications.lectureRemindersEnabled,
                  enabled: channelsEnabled,
                  showBorder: true,
                  save: (val) => repo.updateNotificationPreferences(
                    userId,
                    lectureRemindersEnabled: val,
                  ),
                ),
                _channelSwitch(
                  icon: Symbols.assignment,
                  label: 'Assignment Reminders',
                  subtitle:
                      'A day and ${assignmentFinalReminder.inHours} hours '
                      'before',
                  value: notifications.assignmentRemindersEnabled,
                  enabled: channelsEnabled,
                  showBorder: true,
                  save: (val) => repo.updateNotificationPreferences(
                    userId,
                    assignmentRemindersEnabled: val,
                  ),
                ),
                _channelSwitch(
                  icon: Symbols.wb_sunny,
                  label: 'Morning Briefing',
                  subtitle:
                      'A quiet summary of your day at '
                      '${morningBriefingTime.hour} AM',
                  value: notifications.morningBriefingEnabled,
                  enabled: channelsEnabled,
                  showBorder: false,
                  save: (val) => repo.updateNotificationPreferences(
                    userId,
                    morningBriefingEnabled: val,
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
                      // Only the temp directory is cache. SharedPreferences
                      // holds the student's onboarding state, Focus history
                      // and the notification-permission guard, which this
                      // used to wipe (#41).
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
/// existing settings row. A brand-new account has none yet, so each write
/// calls [UserSettingsRepository.ensureForUser] first, which creates the
/// row following the system theme (#37).
class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection({required this.userId});

  final String userId;

  Future<void> _setTheme(WidgetRef ref, String value) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    await repo.ensureForUser(userId);
    await repo.updateTheme(userId, value);
  }

  Future<void> _setAccent(WidgetRef ref, String accentName) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    await repo.ensureForUser(userId);
    await repo.updateAccent(userId, accentName);
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
