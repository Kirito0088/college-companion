# ADR-001: Flutter Application Framework

- **Status:** Accepted
- **Date:** 2026-06-25
- **Deciders:** Architecture Team

## Context
College Companion requires a responsive, high-performance, Android-first user experience with Material Design 3 compliance, smooth 60fps micro-animations, and clean offline SQLite persistence.

## Decision
Adopt **Flutter** (Dart 3.x) as the primary cross-platform mobile application framework.

## Consequences
- **Positive:** Single expressive codebase for UI, state, and local persistence. Native Material 3 widget support, declarative routing, and high testability.
- **Negative:** Requires Dart-specific code generation tooling (`build_runner`, `drift_dev`).
