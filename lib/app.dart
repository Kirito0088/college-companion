/// College Companion App
///
/// The root [MaterialApp] configured with:
/// - Material Design 3
/// - Dark theme only
/// - GoRouter navigation
/// - Inter typography
/// - Riverpod-aware routing for authentication redirects
library;

import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/providers/app_providers.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/app_theme.dart';
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

class _CollegeCompanionAppState extends ConsumerState<CollegeCompanionApp> {
  /// Notifies GoRouter to re-evaluate redirects when auth state changes.
  final _authRefreshNotifier = ValueNotifier<int>(0);

  late final ProviderSubscription<AuthState> _authStateSubscription;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    ref.read(syncServiceProvider);
    _authStateSubscription = ref.listenManual<AuthState>(
      authStateProvider,
      (_, _) => _authRefreshNotifier.value++,
    );
    _router = createRouter(ref, refreshListenable: _authRefreshNotifier);
  }

  @override
  void dispose() {
    _authStateSubscription.close();
    _router.dispose();
    _authRefreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── App Identity ─────────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme (Dark only, Material Design 3) ─────────────────────────
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // ── Routing (GoRouter) ───────────────────────────────────────────
      routerConfig: _router,
    );
  }
}
