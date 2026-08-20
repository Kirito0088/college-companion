# [SLICE]: Wire Account Information Screen & User Profile to Drift SQLite Database

- **Issue:** #104
- **Labels:** `type:slice`, `milestone:1-core-features`, `layer:ui-ux`, `layer:drift-db`, `priority:p2-normal`

## 1. Student Context & Problem
`UserProfileNotifier` uses hardcoded fallback strings ("Jayesh Patil") and `SharedPreferences` instead of Drift SQLite `users` table and Supabase Auth session metadata.

## 2. Tracer-Bullet Architecture Scope
- **State Layer (Riverpod):** Refactor `userProfileProvider` to watch `userRepositoryProvider.watchUser(activeUserId)`.
- **Data Layer:** Update `UserRepository` to persist academic metadata (university, branch, semester, student ID) into Drift SQLite `users` table and enqueue mutations to `sync_queue`.

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Auth Metadata):**
  - **Given** user signs in via Google OAuth,
  - **When** opening Account Information,
  - **Then** display authenticated Google name, email, and profile avatar.
- [ ] **Scenario 2 (Update Profile):**
  - **Given** user updates college name or student ID,
  - **When** saved,
  - **Then** persist changes to Drift SQLite `users` table and sync to Supabase.

## 4. Verification & Quality Gates
- [ ] `flutter test test/unit/database/user_repository_test.dart` passes.
