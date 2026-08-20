# ADR-004: Google Sign-In Only Authentication

- **Status:** Accepted
- **Date:** 2026-06-25
- **Deciders:** Product & Security Team

## Context
Students need a fast, low-friction onboarding experience without maintaining separate email passwords or complex verification flows.

## Decision
Support **Google Sign-In exclusively** for all user authentication.

## Consequences
- **Positive:** Frictionless 1-tap sign in, secure OAuth 2.0 token management, zero custom credential storage vulnerability.
- **Negative:** Users without a Google account cannot register (acceptable trade-off for academic student target demographic).
