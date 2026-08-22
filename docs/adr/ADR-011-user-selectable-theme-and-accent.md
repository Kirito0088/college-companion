# ADR-011: User-Selectable Theme (Light/Dark) and Accent

- **Status:** Accepted
- **Date:** 2026-08-22
- **Deciders:** Design & Architecture Team
- **Supersedes:** [ADR-005](ADR-005-dark-theme-first.md)

## Context

A full visual redesign (sourced from a Claude Design canvas, "College Companion Redesign") replaces the obsidian/cobalt palette from the "De-Vibecode" pass (Issue #21) with a jade/teal palette, and — unlike ADR-005's dark-only decision — defines both a light and a dark theme, plus a user-selectable accent color (jade, sand, azure). QA surface area was the reason ADR-005 postponed light theme; the redesign explicitly asks for it, and the user has confirmed adopting it in full.

## Decision

1. **Both themes ship.** `ThemeMode` is user-selectable (Settings → Appearance), not fixed to dark. Falls back to `ThemeMode.system` pre-login.
2. **Accent is user-selectable** (jade/sand/azure), independent of light/dark.
3. **Mechanism:** `static const` design tokens (`ColorTokens`, etc.) can't change at runtime, so a `ThemeExtension<CCTokens>` (`lib/theme/cc_tokens.dart`) carries the semantic slots that vary per `(Brightness, Accent)` — background/surface/elevation steps, foreground/muted/dim text, the accent color and its soft tint, warning/risk colors, and a bespoke shadow/sheen. `AppTheme.theme(Brightness, Accent)` (`lib/theme/app_theme.dart`) builds a `ThemeData` carrying both a standard MD3 `ColorScheme` (derived from `CCTokens`, for stock widgets) and the `CCTokens` extension (for custom surfaces). Call sites read `Theme.of(context).colorScheme` or `context.cc` instead of the old static `ColorTokens.*`.
4. **Persistence:** reuses the existing `user_settings.theme` column (already present, previously unread) for light/dark/system, and stores `accent` inside the existing `user_settings.preferences` JSONB catch-all column — no schema migration needed.
5. **Migration is incremental, not a single sweep.** `ColorTokens`/`RadiusTokens` keep serving as a `static const` fallback (repointed to the new dark/jade values) for the ~130 call sites that haven't migrated to `Theme.of(context)`/`context.cc` yet. Those call sites render the new dark/jade palette but do not yet react to the user's light/dark or accent choice — they get migrated screen-by-screen as each is re-skinned.

## Consequences

- **Positive:** Matches the approved redesign; no new dependency (fonts and persistence already available); reactive theming built on a documented, idiomatic Flutter mechanism (`ThemeExtension`).
- **Negative:** During the incremental migration window, screens not yet re-skinned will render the dark/jade palette regardless of the user's actual theme/accent selection — an intentional, temporary inconsistency, not a bug.
- **Negative:** `secondary`/`tertiary` MD3 slots (calendar/resources) are not yet part of the redesign and keep their prior indigo/violet values for both brightnesses until those screens are addressed in a later slice.
