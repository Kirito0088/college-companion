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

## Revision History

### v1.0
Initial decision log created.
