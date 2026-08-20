# ADR-010: Immutable Lecture Ledger & Local SHA-256 Evidence

- **Status:** Accepted
- **Date:** 2026-07-15
- **Deciders:** Product & Security Team

## Context
Attendance tracking must be trustworthy and tamper-evident for verified semester exports, while protecting student privacy by not uploading personal photos to cloud servers.

## Decision
1. `lecture_records` table is an **append-only immutable ledger** (1:1 with timetable lecture). Once saved, rows cannot be edited or deleted (enforced by SQLite triggers and repository contracts).
2. Camera evidence is **strictly local-only** (never synced to Supabase). On-device photos are hashed using SHA-256 and verified during export and inspection.

## Consequences
- **Positive:** Cryptographically verifiable academic ledger, high student trust, zero cloud storage costs for photo evidence, absolute privacy guarantee.
- **Negative:** Evidence photos do not survive device wipes unless backed up via local Android file transfer.
