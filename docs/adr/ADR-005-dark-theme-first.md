# ADR-005: Dark Theme-First Visual Direction

- **Status:** Superseded by [ADR-011](ADR-011-user-selectable-theme-and-accent.md)
- **Date:** 2026-06-25
- **Deciders:** Design & Architecture Team

## Context
Target users are college students who use their phones extensively in dim lecture halls, libraries, and late at night. Maintaining dual themes in early phases increases QA surface area.

## Decision
Adopt a **dark theme-first** design system built on Material Design 3 tokens, featuring a deep dark background (`#121212`) and vibrant purple primary accents (`#6750A4`).

## Consequences
- **Positive:** Reduced eye strain in low-light study environments, consistent visual branding, reduced token duplication.
- **Negative:** Light theme postponed to post-v1.0.0 milestones.
