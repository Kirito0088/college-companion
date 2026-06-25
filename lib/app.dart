/// College Companion App
///
/// The root [MaterialApp] configured with:
/// - Material Design 3
/// - Dark theme only
/// - GoRouter navigation
/// - Inter typography
library;

import 'package:college_companion/core/constants/app_constants.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The root widget of College Companion.
class CollegeCompanionApp extends StatefulWidget {
  /// Creates a [CollegeCompanionApp].
  const CollegeCompanionApp({super.key});

  @override
  State<CollegeCompanionApp> createState() => _CollegeCompanionAppState();
}

class _CollegeCompanionAppState extends State<CollegeCompanionApp> {
  late final _router = createRouter();

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
