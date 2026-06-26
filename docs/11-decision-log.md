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
2026-06-26

### Category
Architecture

### Decision
Firebase owns authentication. Supabase owns data storage. No dual authentication.

### Reason
Firebase Auth handles Google Sign-In, session persistence, and credential management. Supabase stores user profile data (uid, name, email, photo) for RLS-protected data queries. Duplicating authentication across both services would add unnecessary complexity and potential session conflicts.

### Alternatives Considered
- Supabase Auth only (lacks Firebase services: Crashlytics, Analytics, Messaging)
- Dual authentication with both Firebase and Supabase Auth

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
