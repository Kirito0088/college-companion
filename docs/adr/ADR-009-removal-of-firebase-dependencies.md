# ADR-009: Complete Removal of Firebase Dependencies

- **Status:** Accepted
- **Date:** 2026-07-06
- **Deciders:** Architecture Team

## Context
Firebase dependencies (Auth, Firestore, Crashlytics, Analytics, FCM) added significant build time, APK size bloat, and redundant authentication layers alongside Supabase.

## Decision
Completely strip all Firebase plugins, Gradle dependencies, and configuration files from the project.

## Consequences
- **Positive:** Faster compilation times, smaller release APKs, cleaner Gradle scripts, unified Supabase/Drift tech stack.
- **Negative:** Firebase Analytics/Crashlytics replaced by local structured logging (`AppLogger`) and future open-source telemetry.
