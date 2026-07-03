/// College Companion — Entry Point
///
/// Initializes environment configuration, Supabase,
/// and launches the application wrapped in Riverpod's [ProviderScope].
library;

import 'package:college_companion/app.dart';
import 'package:college_companion/core/config/env_config.dart';
import 'package:college_companion/services/supabase_service.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Application entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation (Android-first, mobile-first).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── Environment Configuration ──────────────────────────────────────────
  await EnvConfig.load();
  AppLogger.enableEnvBasedLogging();
  AppLogger.info('Environment loaded (${EnvConfig.appEnv})', tag: 'Main');

  // ── Supabase Initialization ────────────────────────────────────────────
  await SupabaseService.initialize();

  AppLogger.info('Application starting', tag: 'Main');

  runApp(const ProviderScope(child: CollegeCompanionApp()));
}
