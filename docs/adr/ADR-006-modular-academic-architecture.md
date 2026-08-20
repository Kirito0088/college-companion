# ADR-006: Feature-First Modular Architecture

- **Status:** Accepted
- **Date:** 2026-06-25
- **Deciders:** Architecture Team

## Context
A complex academic app with 15 distinct functional areas (Attendance, Timetable, Subjects, Assignments, Calendar, Internal Marks, Resources, Focus, etc.) becomes unmaintainable if organized in layered buckets (`screens/`, `models/`, `controllers/`).

## Decision
Structure the codebase using a **feature-first package architecture** under `lib/features/<feature_name>/` containing `models/`, `repositories/`, `providers/`, `screens/`, and `widgets/`.

## Consequences
- **Positive:** High cohesion, low coupling, easy domain navigation, localized testing, and independent vertical slice delivery.
- **Negative:** Shared domain logic must be cleanly factored into `lib/core/` or `lib/shared/`.
