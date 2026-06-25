# 01 - Design Tokens

> Version: 1.0
> Status: Active

# Purpose

Design Tokens are the single source of truth for every visual value used in College Companion.

No widget may use hardcoded colors, spacing, typography, radii, elevation or animation values.

---

# Token Hierarchy

Primitive Tokens
↓
Semantic Tokens
↓
Component Tokens
↓
Screens

---

# Color Tokens

## Primary

- Primary
- On Primary
- Primary Container
- On Primary Container

## Surface

- Background
- Surface
- Surface Variant
- Surface Container
- Surface Container High

## Semantic

- Success
- Warning
- Error
- Info

## Borders

- Outline
- Outline Variant
- Divider

---

# Typography Tokens

Single Font Family.

Recommended:
Inter

Scale:

- Display Large
- Display Medium
- Headline Large
- Headline Medium
- Title Large
- Title Medium
- Body Large
- Body Medium
- Label Large
- Label Medium

No custom font sizes outside the typography scale.

---

# Spacing Tokens

Spacing values:

- 2
- 4
- 8
- 12
- 16
- 20
- 24
- 32
- 40
- 48
- 64

Every margin, padding and gap must reference one of these values.

---

# Radius Tokens

- XS
- SM
- MD
- LG
- XL
- Pill
- Circle

---

# Elevation Tokens

- Level 0
- Level 1
- Level 2
- Level 3
- Overlay

---

# Motion Tokens

Durations:

- Instant
- Fast
- Normal
- Slow

Curves should follow Material Design motion.

---

# Icon Tokens

Library:

Material Symbols Rounded

No other icon libraries are allowed.

---

# Layout Tokens

- Screen Padding
- Section Gap
- Component Gap
- Card Padding
- Bottom Navigation Height
- Safe Area Top
- Safe Area Bottom

---

# Semantic Tokens

Attendance

- Present
- Absent
- Cancelled

Assignments

- Pending
- Completed
- Overdue

Calendar

- Lecture
- Practical
- Holiday

These tokens reference the primitive color tokens.

---

# Token Rules

- Never hardcode colors.
- Never hardcode spacing.
- Never hardcode border radius.
- Never hardcode durations.
- Never create duplicate tokens.
- Add new tokens only after updating this document.

---

# Revision History

## v1.0

Initial design token specification.
