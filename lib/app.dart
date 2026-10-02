/// College Companion App
///
/// The root [MaterialApp] configured with:
/// - Material Design 3
/// - User-selectable light/dark theme + accent (ADR-011)
/// - GoRouter navigation
/// - Plus Jakarta Sans / Newsreader / IBM Plex Mono typography
/// - Riverpod-aware routing for authentication redirects
/// - Local academic reminders kept in step with the student's data (#10)
library;

import 'dart:async';

import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/notifications/providers/notification_provider.dart';
import 'package:college_companion/features/notifications/providers/reminder_provider.dart';
import 'package:college_companion/features/onboarding/providers/onboarding_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/services/local_notification_service.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:college_companion/theme/providers/app_theme_provider.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The root widget of College Companion.
///
/// Uses [ConsumerStatefulWidget] so the router can access
/// Riverpod providers for authentication redirect logic.
///
/// A [ValueNotifier] bridges auth state changes to GoRouter's
/// [refreshListenable], keeping all navigation decisions centralized
/// in the redirect function.
class CollegeCompanionApp extends ConsumerStatefulWidget {
  /// Creates a [CollegeCompanionApp].
  const CollegeCompanionApp({super.key});

  @override
  ConsumerState<CollegeCompanionApp> createState() =>
      _CollegeCompanionAppState();
}

class _CollegeCompanionAppState extends ConsumerState<CollegeCompanionApp>
    with WidgetsBindingObserver {
  /// Notifies GoRouter to re-evaluate redirects when auth or onboarding
  /// state changes. Onboarding must be included: [OnboardingNotifier]
  /// loads its persisted flag from SharedPreferences asynchronously, so
  /// the redirect can fire once (still seeing the default `false`) before
  /// that load resolves — without this listener nothing tells GoRouter to
  /// re-evaluate once the real value arrives, leaving a returning user
  /// stuck on the onboarding screen despite having already completed it.
  final _authRefreshNotifier = ValueNotifier<int>(0);

  late final ProviderSubscription<AuthState> _authStateSubscription;
  late final ProviderSubscription<bool> _onboardingSubscription;
  late final ProviderSubscription<void> _reminderSync;
  StreamSubscription<ReminderTap>? _reminderTaps;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    ref.read(syncServiceProvider);
    _authStateSubscription = ref.listenManual<AuthState>(
      authStateProvider,
      (_, _) => _authRefreshNotifier.value++,
    );
    _onboardingSubscription = ref.listenManual<bool>(
      onboardingCompletedProvider,
      (_, _) => _authRefreshNotifier.value++,
    );
    _router = createRouter(ref, refreshListenable: _authRefreshNotifier);

    // Reminders (#10): keep the OS schedule in step with the student's
    // data for the app's lifetime.
    _reminderSync = ref.listenManual<void>(reminderSyncProvider, (_, _) {});
    WidgetsBinding.instance.addObserver(this);
    final notifications = ref.read(localNotificationServiceProvider);
    _reminderTaps = notifications.taps.listen(_openReminder);
    unawaited(
      notifications.launchTap().then((tap) {
        if (tap != null) _openReminder(tap);
      }),
    );
  }

  /// Re-plan on return to the foreground: the plan is relative to "now",
  /// so this rolls the seven-day window forward.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(reminderPlanProvider);
    }
  }

  /// Opens the screen a tapped reminder points to and marks it read.
  void _openReminder(ReminderTap tap) {
    final auth = ref.read(authStateProvider);
    if (auth is AuthAuthenticated) {
      unawaited(
        ref
            .read(notificationRepositoryProvider)
            .markRead(auth.user.uid, tap.id)
            .catchError((Object error, StackTrace stackTrace) {
              AppLogger.error(
                'Could not mark reminder read',
                error: error,
                stackTrace: stackTrace,
              );
            }),
      );
    }
    // After the current frame, so a cold start's initial redirect settles
    // before navigating on top of it. A bottom-nav tab is gone to, which
    // selects it; pushing it would stack it on whichever tab is current.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shellTabs.contains(tap.route)) {
        _router.go(tap.route);
      } else {
        _router.push(tap.route);
      }
    });
  }

  /// Top-level routes of the bottom-navigation shell.
  static const Set<String> _shellTabs = {
    RoutePaths.home,
    RoutePaths.attendance,
    RoutePaths.calendar,
    RoutePaths.assignments,
    RoutePaths.profile,
  };

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderSync.close();
    unawaited(_reminderTaps?.cancel());
    _authStateSubscription.close();
    _onboardingSubscription.close();
    _router.dispose();
    _authRefreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themePreference = ref.watch(appThemeProvider);

    return MaterialApp.router(
      // ── App Identity ─────────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme (user-selectable light/dark + accent — ADR-011) ────────
      theme: AppTheme.theme(Brightness.light, themePreference.accent),
      darkTheme: AppTheme.theme(Brightness.dark, themePreference.accent),
      themeMode: themePreference.themeMode,

      // ── Routing (GoRouter) ───────────────────────────────────────────
      routerConfig: _router,
    );
  }
}
