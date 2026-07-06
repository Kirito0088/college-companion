# 11 - Decision Log

> Status: Active
> Purpose: Record every significant product, design, architecture, and engineering decision made during the project.

---

# Why this document exists

This document answers one question:

> "Why was this decision made?"

Do not modify or delete historical decisions. If a decision changes, add a new entry explaining the change.

---

# Entry Template

## Decision ID
CC-XXXX

### Date
YYYY-MM-DD

### Category
- Product
- Design
- Architecture
- Backend
- Security
- UI/UX
- Performance
- Database
- Other

### Decision

Describe the decision.

### Reason

Explain why this approach was chosen.

### Alternatives Considered

- Option A
- Option B

### Impact

- Benefits
- Trade-offs

### Status

- Active
- Superseded
- Deprecated

---

# Project Decisions

## CC-0001

### Date
2026-06-25

### Category
Architecture

### Decision
Flutter was selected as the application framework.

### Reason
Native-feeling UI, excellent Material Design 3 support, smooth animations, strong Android performance, and a single codebase.

### Alternatives Considered
- React Native
- PWA

### Status
Active

---

## CC-0002

### Date
2026-06-25

### Category
Backend

### Decision
Supabase will be the cloud backend.

### Reason
Provides PostgreSQL, Google authentication, Row Level Security, Storage, and a generous free tier.

### Alternatives Considered
- Firebase
- MongoDB Atlas

### Status
Active

---

## CC-0003

### Date
2026-06-25

### Category
Database

### Decision
SQLite (via Drift) is the local source of truth.

### Reason
Offline-first architecture with background synchronization to Supabase.

### Status
Active

---

## CC-0004

### Date
2026-06-25

### Category
Authentication

### Decision
Google Sign-In only.

### Reason
Simple onboarding, secure authentication, and familiar user experience.

### Status
Active

---

## CC-0005

### Date
2026-06-25

### Category
Design

### Decision
Dark theme only.

### Reason
Reduces maintenance, provides a focused visual identity, and matches the intended product direction.

### Status
Active

---

## CC-0006

### Date
2026-06-25

### Category
Product

### Decision
College Companion will be modular.

### Reason
Users can enable or disable modules over time without affecting the core experience.

### Status
Active

---

## CC-0007

### Date
2026-06-26 (updated 2026-06-29)

### Category
Architecture

### Decision
Supabase Auth owns authentication. Supabase owns data storage. Native Google Sign-In via `google_sign_in` + `signInWithIdToken()`.

### Reason
Per official Supabase Flutter documentation, the recommended approach for mobile is:
1. Use `google_sign_in` package for native Google Sign-In (system dialog)
2. Exchange the ID token via `supabaseClient.auth.signInWithIdToken()`

This eliminates the need for:
- JWT bridge / Edge Functions
- Firebase Authentication
- Browser-based OAuth flow (`signInWithOAuth()`)

Firebase is retained only for Analytics, Crashlytics, and FCM — not for authentication.

### OAuth Configuration
**Google Cloud Console** (apis.cloud.google.com):
1. Create OAuth 2.0 Client ID → Application type: **"Web application"**
2. The resulting **Web Client ID** (`*.apps.googleusercontent.com`) is stored in `GOOGLE_WEB_CLIENT_ID`
3. For Android: Add the SHA-1 certificate fingerprint to the OAuth client
   - Debug: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - Release: Use your release keystore

**Supabase Dashboard** (supabase.com/dashboard):
1. Authentication → Providers → Google → Enable
2. Enter:
   - **Client ID**: Your Web Client ID from Google Cloud
   - **Client Secret**: Your Web Client Secret from Google Cloud
   
**Note**: Android OAuth clients do NOT have a client secret. Only Web OAuth clients have secrets. Android only requires the SHA-1 fingerprint.

### Alternatives Considered
- Firebase Auth + Supabase data (requires JWT bridge, adds complexity)
- Dual authentication with both Firebase and Supabase Auth (unnecessary complexity)
- Browser-based OAuth via `signInWithOAuth()` (poorer UX on mobile)

### Impact
- Native Google Sign-In dialog (better UX)
- No custom Edge Functions required
- Direct Supabase session management
- Google Web Client ID required in `.env`

### Status
Active

---

## CC-0008

### Date
2026-06-26

### Category
Architecture

### Decision
Authentication state is managed via Riverpod `Notifier` with a sealed `AuthState` class containing five states: Initial, Loading, Authenticated, Unauthenticated, Error.

### Reason
A sealed class provides exhaustive pattern matching in Dart, ensuring every auth state is explicitly handled. Riverpod's `Notifier` integrates with the existing state management approach and allows GoRouter redirects to read auth state synchronously.

### Alternatives Considered
- StreamProvider watching Firebase authStateChanges
- AsyncNotifier with AsyncValue wrapping

### Status
Active

---

## Revision History

### v1.1
Added CC-0007 (Firebase/Supabase auth split) and CC-0008 (auth state management).

### v1.0
Initial decision log created.

---

## CC-0009

### Date
2026-07-06

### Category
Architecture

### Decision
Completely removed every Firebase-related artifact from the project. 
Firebase is no longer used for Analytics, Crashlytics, or FCM.

### Reason
Firebase was not part of the current architecture. The application currently uses Drift (local source of truth) and Supabase for authentication and synchronization. This simplifies the tech stack and removes unnecessary dependencies.

### Impact
- Removes unused Firebase dependencies and plugins
- Simplifies Android build configuration

### Status
Active

