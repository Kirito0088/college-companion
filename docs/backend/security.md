# backend/security.md

> Version: 1.0
> Status: Active

---

# Purpose

This document defines the security architecture for College Companion.

Security is a core feature of the application and must never be compromised for convenience.

---

# Security Principles

The application should be:

* Secure by default
* Private by default
* Least privilege
* User isolated
* Cloud synchronized
* Offline capable

---

# Authentication

Authentication Provider:

* Supabase Auth

Supported Login:

* Google Sign-In only

Not Supported:

* Email & Password
* Phone OTP
* Anonymous Login
* Guest Accounts

---

# Session Management

The user logs in once.

The session should persist until:

* User logs out.
* Session becomes invalid.
* Authentication is revoked.

Never ask users to repeatedly sign in.

---

# Authorization

Every request must be authenticated.

Never trust client-side authorization.

---

# Row Level Security (RLS)

Every table MUST have Row Level Security enabled.

Every query must be restricted to the authenticated user.

Example:

User A must never be capable of viewing, editing or deleting User B's data.

No exceptions.

---

# Database Policies

Every table must support:

* SELECT
* INSERT
* UPDATE
* DELETE

All policies must verify the authenticated user's ID.

---

# Local Database

SQLite stores user data locally.

The local database is isolated per device.

Sensitive tokens should never be stored in plain text.

---

# API Security

Never expose:

* Service Role Keys
* Database Passwords
* API Secrets

Public application keys are acceptable where intended.

---

# File Storage

Lecture evidence (classroom photos) is **local-only and never stored in
the cloud** (spec §8/§16). Evidence:

* Stays on the device (app documents directory, relative paths)
* Carries no sync-metadata and has no Supabase Storage counterpart
* Is re-verified (sha256) on open and before export

> Cloud Supabase Storage is **not** used for attendance evidence. (Earlier
> drafts referenced proof-image URLs in Supabase Storage; superseded by
> the locked Attendance Record spec — Phase 4 §7, D7.)

Each local evidence file belongs to exactly one user and is never shared.

---

# Input Validation

Always validate:

* Client Side
* Server Side

Client validation improves UX.

Server validation provides security.

---

# Sensitive Data

Never collect unnecessary user information.

Store only what is required for application functionality.

---

# Logging

Do not log:

* Tokens
* Passwords
* Authentication credentials
* Sensitive user data

Debug logs should be disabled in production.

---

# Error Messages

Never expose internal errors.

Good:

"Couldn't save attendance."

Bad:

"PostgreSQL Error: Constraint violation..."

---

# Internet Communication

Use HTTPS only.

Never send sensitive data over insecure connections.

---

# Data Ownership

Users own their data.

Deleting an account should remove all associated cloud data.

---

# Offline Security

Offline mode must never bypass security rules.

Synchronization should authenticate every request.

---

# Third-Party Services

Only approved services:

* Supabase


Avoid unnecessary SDKs.

---

# Security Checklist

Before every release verify:

✓ RLS enabled

✓ HTTPS only

✓ No exposed secrets

✓ No debug logs

✓ Session persistence works

✓ Google Sign-In works

✓ User isolation works

✓ File permissions correct

---

# Final Rule

If there is ever a conflict between convenience and security,

**security wins.**

---

# Revision History

## v1.0

Initial security specification.
