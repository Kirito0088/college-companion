# 10 - Rules (Project Constitution)

> Status: Active
> Priority: Highest

## Purpose

This document is the constitution of College Companion. If any other document contradicts this one, this document takes precedence.

## Project Philosophy

- Android-first
- Dark mode only
- Offline-first (Local-first, Cloud-synced)
- Fast
- Secure
- Consistent
- Minimal
- Reliable

## AI Development Rules

AI assistants implement. They do not invent.

They must:
- Read documentation before coding.
- Follow documentation exactly.
- Ask when documentation is ambiguous.
- Never invent UI, colors, spacing, architecture, or features.

## Engineering Principles

1. Simplicity over cleverness.
2. Readability over brevity.
3. Consistency over novelty.
4. Composition over duplication.
5. Performance by default.
6. Security by default.

## Architecture Rules

- Feature-first architecture.
- Repository pattern.
- No business logic inside UI.
- Shared code belongs in core.
- Feature-specific code stays inside the feature.

## UI Rules

- Material Design 3 only.
- Dark theme only.
- Material Symbols Rounded only.
- One typography system.
- One spacing system.
- One radius system.
- Every visual value comes from design tokens.

Hardcoded colors, spacing, durations, typography and radii are forbidden.

## Performance Rules

- Target Android 12+.
- Avoid unnecessary rebuilds.
- Prefer lazy loading.
- Optimize for smooth scrolling.

## Offline Rules

- Local database is the source of truth.
- Write locally first.
- Sync afterwards.
- UI always reads local data.

## Security Rules

- Google Sign-In only.
- Row Level Security on every table.
- Never expose secrets.
- Principle of least privilege.

## Documentation Rules

Documentation must exist before implementation.

## Code Quality Rules

- Small functions.
- Reusable components.
- No dead code.
- No TODOs in production.
- No commented-out code.

## Documentation Hierarchy

1. 10-rules.md
2. 00-project-vision.md
3. 01-design-tokens.md
4. 02-design-system.md
5. Remaining documents

## Revision History

### v1.0
Initial constitution.
