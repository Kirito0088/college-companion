# 02 - Design System

> Version: 1.0
> Status: Active

# Purpose

This document defines the visual language of College Companion.

The goal is to ensure every screen feels like it belongs to the same application regardless of who implements it.

---

# Design Principles

1. Clarity before decoration.
2. Consistency before creativity.
3. Motion should communicate.
4. Typography creates hierarchy.
5. Whitespace is intentional.
6. Every screen has one primary purpose.

---

# Visual Identity

The application should feel:

- Premium
- Calm
- Modern
- Native
- Trustworthy

Avoid flashy effects, excessive gradients, glassmorphism, or decorative visuals.

---

# Theme

- Dark mode only.
- Material Design 3.
- Android-first experience.
- Rounded Material Symbols only.

---

# Layout System

Every screen follows the same structure:

1. App Bar
2. Primary Content
3. Secondary Content
4. Bottom Navigation (when applicable)

No screen should feel overcrowded.

---

# Surface Hierarchy

Surface levels should clearly communicate importance.

1. Background
2. Surface
3. Elevated Surface
4. Modal / Bottom Sheet

Do not nest elevated cards inside elevated cards unless absolutely necessary.

---

# Typography Hierarchy

Typography should create visual hierarchy instead of relying on colors.

Priority:

Display
↓
Headline
↓
Title
↓
Body
↓
Label

---

# Spacing Philosophy

Spacing should remain consistent throughout the application.

Use only spacing tokens defined in `01-design-tokens.md`.

Never create one-off spacing values.

---

# Shape Language

Cards, dialogs, buttons and sheets share the same family of corner radii.

Avoid mixing multiple visual styles.

---

# Icons

Use Material Symbols Rounded exclusively.

Icons should support text, not replace it.

Navigation items always contain both icon and label.

---

# Cards

Cards should represent a single piece of information.

A card should never contain another elevated card.

Avoid dashboard clutter.

---

# Empty States

Every empty state should:

- Explain why the screen is empty.
- Tell the user what to do next.
- Maintain a positive tone.

---

# Loading States

Always prefer skeleton loading over full-screen loading indicators.

Preserve layout while data loads.

---

# Forms

Forms should be progressive.

Request only the information needed at the current step.

Avoid long forms whenever possible.

---

# Feedback

Every important action should provide immediate feedback.

Examples:

- Success snackbar
- Inline validation
- Progress indicator
- Subtle animation

---

# Responsiveness

The interface should scale gracefully across Android phones without redesigning layouts.

Use adaptive layouts where appropriate.

---

# Anti-Patterns

Do NOT:

- Use random gradients.
- Mix icon families.
- Introduce inconsistent spacing.
- Use multiple button styles for the same action.
- Overuse animations.
- Create dashboard-style clutter.

---

# Flutter Implementation Notes

- Use reusable widgets.
- Use theme extensions where appropriate.
- Reference design tokens instead of hardcoded values.
- Keep UI components stateless whenever possible.

---

# Revision History

## v1.0

Initial design system specification.
