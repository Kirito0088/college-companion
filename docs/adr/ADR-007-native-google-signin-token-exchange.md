# ADR-007: Native Google Sign-In via ID Token Exchange

- **Status:** Accepted
- **Date:** 2026-06-26 (Updated 2026-06-29)
- **Deciders:** Architecture & Security Team

## Context
Browser-based OAuth redirects (`signInWithOAuth`) degrade user experience on Android by launching external browser tabs.

## Decision
Use `google_sign_in` for native Android system dialogs and exchange the resulting Google ID Token directly with Supabase via `supabaseClient.auth.signInWithIdToken()`.

## Consequences
- **Positive:** Seamless native system prompt UX, zero external browser redirects, eliminates the need for custom Supabase Edge Functions or JWT bridges.
- **Negative:** Requires Web Client ID and SHA-1 certificate configuration in Google Cloud Console.
