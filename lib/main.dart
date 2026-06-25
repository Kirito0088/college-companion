/// College Companion — Entry Point
///
/// Initializes environment configuration, Firebase, Supabase,
/// and launches the application wrapped in Riverpod's [ProviderScope].
library;

import 'package:college_companion/app.dart';
import 'package:college_companion/core/config/env_config.dart';
import 'package:college_companion/services/supabase_service.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation (Android-first, mobile-first).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ── Environment Configuration ──────────────────────────────────────────
  await EnvConfig.load();
  AppLogger.enableEnvBasedLogging();
  AppLogger.info('Environment loaded (${EnvConfig.appEnv})', tag: 'Main');

  // ── Firebase Initialization ────────────────────────────────────────────
  // Uses google-services.json via the Google Services Gradle plugin.
  // TODO(firebase): Generate firebase_options.dart via FlutterFire CLI
  //   for multi-platform support: `flutterfire configure`
  if (EnvConfig.firebaseAndroidEnabled) {
    await _initializeFirebase();
  }

  // ── Supabase Initialization ────────────────────────────────────────────
  await SupabaseService.initialize();

  // TODO(crashlytics): Configure Crashlytics error reporting
  //   in a later milestone.

  AppLogger.info('Application starting', tag: 'Main');

  runApp(const ProviderScope(child: CollegeCompanionApp()));
}

/// Initializes Firebase using the Android google-services.json
/// configuration injected by the Gradle plugin.
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    AppLogger.info('Firebase initialized', tag: 'Main');
  } on Exception catch (error, stackTrace) {
    // Firebase failure should not prevent the app from launching.
    // The app is offline-first — it can function without Firebase services.
    AppLogger.error(
      'Firebase initialization failed',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
