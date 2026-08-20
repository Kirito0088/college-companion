# ADR-002: Supabase Cloud Backend & PostgreSQL RLS

- **Status:** Accepted
- **Date:** 2026-06-25
- **Deciders:** Architecture Team

## Context
The app needs a scalable cloud backend for Google authentication, multi-device backup synchronization, and semester export verification with strict per-user data isolation.

## Decision
Adopt **Supabase** (PostgreSQL with Row Level Security) as the cloud backend provider.

## Consequences
- **Positive:** PostgreSQL relational integrity, native Google OAuth exchange, strict RLS per user ID, and cloud backup.
- **Negative:** Schema must be kept in sync with local SQLite schema via migrations.
