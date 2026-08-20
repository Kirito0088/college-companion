# ADR-008: Sealed Class Union Auth State Machine

- **Status:** Accepted
- **Date:** 2026-06-26
- **Deciders:** Architecture Team

## Context
Asynchronous authentication flows require unambiguous, compile-time verified states (Initial, Loading, Authenticated, Unauthenticated, Error) to prevent blank screen glitches and routing race conditions.

## Decision
Represent authentication state as a **sealed Dart class** (`AuthState`) managed via a Riverpod `Notifier`.

## Consequences
- **Positive:** Enables exhaustive pattern matching (`switch (state)`) in Dart, guarantees all edge cases are handled at compile time, allows GoRouter redirects to read state synchronously.
- **Negative:** None. Standard idiomatic Dart 3 pattern.
