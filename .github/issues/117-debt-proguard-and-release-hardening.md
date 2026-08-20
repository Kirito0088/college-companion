# [DEBT]: Android Release Keystore, ProGuard Rules & Bundle Hardening

- **Issue:** #117
- **Labels:** `type:tech-debt`, `milestone:6-release`, `layer:drift-db`, `priority:p1-critical`

## 1. Context & Motivation
Prepare production Android App Bundle (`.aab`) with ProGuard obfuscation rules protecting Drift SQLite and Supabase C-bindings.

## 2. Tracer-Bullet Architecture Scope
- Configure `android/app/proguard-rules.pro`.
- Ensure all debug logs are stripped in release builds via `AppLogger`.

## 3. Acceptance Criteria
- [ ] **Given** `flutter build appbundle --release`,
  - **When** bundle generates,
  - **Then** output AAB is $< 25\text{ MB}$ and opens cleanly without SQLite crashes.

## 4. Verification
- [ ] `flutter build appbundle --release` succeeds.
