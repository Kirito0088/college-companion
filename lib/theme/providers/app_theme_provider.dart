/// App Theme Provider
///
/// ADR-011 — derives the active `ThemeMode`/[Accent] from the signed-in
/// user's persisted settings, for [CollegeCompanionApp] to feed into
/// `MaterialApp.router`.
library;

import 'dart:convert';

import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/settings/providers/settings_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's active theme mode and accent, resolved from the signed-in
/// user's persisted settings (falls back to system/jade pre-login).
class AppThemePreference {
  const AppThemePreference({required this.themeMode, required this.accent});

  final ThemeMode themeMode;
  final Accent accent;

  static const fallback = AppThemePreference(
    themeMode: ThemeMode.system,
    accent: Accent.jade,
  );
}

/// Parses the `theme` column into a [ThemeMode].
ThemeMode themeModeFromString(String? theme) {
  switch (theme) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

/// Parses the `accent` key out of the `preferences` JSONB column.
Accent accentFromPreferences(String? preferencesJson) {
  if (preferencesJson == null) return Accent.jade;
  try {
    final decoded = jsonDecode(preferencesJson) as Map;
    return Accent.values.firstWhere(
      (a) => a.name == decoded['accent'],
      orElse: () => Accent.jade,
    );
  } catch (_) {
    return Accent.jade;
  }
}

/// Watches the signed-in user's settings and resolves them into an
/// [AppThemePreference]. Falls back to [AppThemePreference.fallback] before
/// login or while settings haven't loaded yet.
final appThemeProvider = Provider<AppThemePreference>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState is! AuthAuthenticated) return AppThemePreference.fallback;

  final settingsAsync = ref.watch(
    userSettingsStreamProvider(authState.user.uid),
  );
  return settingsAsync.when(
    data: (settings) => settings == null
        ? AppThemePreference.fallback
        : AppThemePreference(
            themeMode: themeModeFromString(settings.theme),
            accent: accentFromPreferences(settings.preferences),
          ),
    loading: () => AppThemePreference.fallback,
    error: (_, _) => AppThemePreference.fallback,
  );
});
