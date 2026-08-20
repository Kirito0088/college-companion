# Technical Context & Constraints

## Stack Overview
- **Flutter**: 3.33+
- **Riverpod**: 2.x (`StateNotifierProvider`, `StreamProvider`, `Provider`)
- **Database**: Drift 2.34 SQLite (`XxxCompanion` pattern, UUID primary keys, soft-delete `deletedAt`, sync queue)
- **Routing**: GoRouter 15.x with `StatefulShellRoute.indexedStack`
- **Auth**: Supabase Google Sign-In (`ref.read(authStateProvider)` as `AuthAuthenticated.userId`)
- **Design Tokens**: `lib/theme/` (`ColorTokens`, `SpacingTokens`, `RadiusTokens`, `TypographyTokens`)

## Core Guidelines
1. No direct source code modifications by Orchestrator.
2. Require workers to run `dart analyze lib` and `flutter test`.
3. Require Forensic Auditor verification for integrity (no mock/fake logic bypasses).
4. Material 3 design consistency across all screens and dialogs.
