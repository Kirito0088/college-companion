/// College Companion — Entry Point
///
/// Initializes Firebase, Supabase, and launches the application
/// wrapped in Riverpod's [ProviderScope].
library;

import 'package:college_companion/app.dart';
import 'package:college_companion/utilities/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO(firebase): Uncomment after running `flutterfire configure`.
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'firebase_options.dart';

// TODO(supabase): Uncomment after configuring Supabase credentials.
// import 'package:college_companion/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation (Android-first, mobile-first).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // ── Firebase Initialization ────────────────────────────────────────────
  // TODO(firebase): Uncomment after running `flutterfire configure`
  //   and placing the generated firebase_options.dart in lib/.
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //
  // // Pass all uncaught Flutter errors to Crashlytics.
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // ── Supabase Initialization ────────────────────────────────────────────
  // TODO(supabase): Replace placeholder credentials in supabase_service.dart
  //   before enabling this initialization.
  //
  // await SupabaseService.initialize();

  AppLogger.info('Application starting', tag: 'Main');

  runApp(
    const ProviderScope(
      child: CollegeCompanionApp(),
    ),
  );
}
