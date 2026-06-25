# 03 - UI Rules

> Version: 1.0
> Status: Active

---

# Purpose

This document defines how every screen in College Companion should look, behave and feel.

These rules are mandatory for every screen, component and future feature.

---

# 1. UI Philosophy

The interface should disappear.

Students should focus on managing their college life—not learning how to use the app.

Every UI element must exist for a reason.

Never add visual elements purely for decoration.

The best compliment the UI can receive is:

> "This app is so easy to use."

---

# 2. General Principles

Every screen should be:

* Clean
* Minimal
* Fast
* Consistent
* Predictable

Never overload the user with information.

---

# 3. One Screen, One Purpose

Each screen has one primary responsibility.

Examples:

Home → Today's overview

Attendance → Attendance

Assignments → Assignments

Calendar → Calendar

Settings → Settings

Avoid combining multiple unrelated functions on the same screen.

---

# 4. Visual Hierarchy

Every screen must follow this order.

1. Screen Title
2. Primary Information
3. Primary Action
4. Secondary Information
5. Secondary Actions
6. Metadata

The user's eyes should naturally move from top to bottom.

---

# 5. Screen Layout

Every screen follows this structure.

```
Safe Area

↓

App Bar

↓

Scrollable Content

↓

Bottom Padding

↓

Bottom Navigation
```

Never allow content to hide behind navigation.

---

# 6. Padding & Spacing

Never hardcode spacing.

Always use design tokens.

Spacing should remain visually consistent across the application.

Whitespace is intentional.

Do not try to fill every empty area.

---

# 7. Cards

Cards should represent one idea.

Examples:

✓ Attendance Summary

✓ Today's Lecture

✓ Assignment

✗ Dashboard inside Card

✗ Card inside Card

Avoid nested elevated surfaces.

---

# 8. Typography

Typography creates hierarchy.

Do not rely on colors or font sizes alone.

Only use typography defined in Design Tokens.

---

# 9. Buttons

Buttons should clearly communicate their action.

Good:

* Save
* Add Subject
* Mark Present

Bad:

* Submit
* Continue
* Click Here

Primary buttons should be limited to one per screen.

---

# 10. Icons

Only Material Symbols Rounded.

Icons should support labels.

Never replace labels with icons unless universally understood.

---

# 11. Forms

Forms should request the minimum amount of information.

Prefer progressive forms over long forms.

Group related fields together.

Validate input immediately where appropriate.

---

# 12. Lists

Lists should be easy to scan.

Keep each row consistent.

Avoid unnecessary dividers.

Support pull-to-refresh where it improves the experience.

---

# 13. Search

Search should always appear at the top of searchable content.

Never hide search inside menus.

Searching should begin immediately while typing.

---

# 14. Empty States

Never display:

"No Data"

Instead explain:

* Why it's empty.
* What the user can do next.

Example:

"No assignments yet.

Tap the + button to create your first assignment."

---

# 15. Loading States

Never show blank screens.

Prefer skeleton loading.

Preserve the layout while loading.

---

# 16. Error States

Explain:

* What happened.
* What the user can do.

Never blame the user.

Example:

"Couldn't sync your data.

We'll try again automatically."

---

# 17. Success Feedback

Successful actions should receive subtle confirmation.

Examples:

* Snackbar
* Success animation
* Check icon
* Haptic feedback

Do not interrupt the workflow.

---

# 18. Dialogs

Dialogs are for important decisions only.

Use Bottom Sheets for selection menus whenever possible.

Dialogs must have:

* Clear title
* Short description
* Primary action
* Cancel action

---

# 19. Bottom Sheets

Prefer Bottom Sheets over dialogs for:

* Selecting attendance status
* Choosing subjects
* Picking semesters
* Filters
* Sort options

Bottom Sheets should never exceed the necessary height.

---

# 20. Navigation

Users must always know:

* Where they are.
* How to go back.
* What the current screen represents.

Navigation should never be surprising.

---

# 21. Dashboard Rules

The dashboard is an overview.

It should not become a control panel.

Priority:

1. Today's Lectures
2. Attendance
3. Assignments
4. Calendar
5. Internal Marks

Only surface the most relevant information.

---

# 22. Attendance Screen

Attendance is the flagship feature.

The screen should prioritize:

* Today's lectures
* Quick attendance logging
* Current percentage
* Safe bunk information

Common actions should require no more than two taps.

---

# 23. Calendar Screen

Calendar should emphasize readability.

Selecting a date should immediately reveal associated lectures, assignments and events.

---

# 24. Assignment Screen

Assignments should be grouped by status.

Examples:

* Pending
* Due Today
* Completed

Completed assignments should visually de-emphasize.

---

# 25. Settings

Settings should be organized into categories.

Examples:

* Account
* Appearance
* Notifications
* Modules
* Data & Sync
* About

Avoid long scrolling lists.

---

# 26. Animations

Animations should explain changes.

Never animate for decoration.

Keep animations fast and subtle.

---

# 27. Haptics

Use haptic feedback sparingly.

Examples:

✓ Attendance marked

✓ Assignment completed

✗ Every button press

---

# 28. Accessibility

Touch targets must remain comfortable.

Text should remain readable.

Never communicate information using color alone.

---

# 29. Performance

UI should remain smooth.

Avoid unnecessary rebuilds.

Prefer lazy rendering.

Avoid heavy shadows and excessive blur.

---

# 30. Anti-Patterns

Do NOT:

* Use glassmorphism.
* Use neon gradients.
* Use inconsistent spacing.
* Mix icon libraries.
* Overuse colors.
* Nest cards inside cards.
* Create dashboard clutter.
* Hide important actions.
* Surprise the user with unexpected navigation.

---

# 31. Flutter Guidelines

* Build reusable widgets.
* Keep widgets small.
* Business logic never belongs inside UI.
* Use design tokens everywhere.
* Use theme values instead of hardcoded values.

---

# 32. Final Rule

Every screen should pass the Three Second Test.

Within three seconds the user must know:

* Where am I?
* What is most important?
* What should I do next?

If the answer is unclear, redesign the screen.

---

# Revision History

## v1.0

Initial UI rules document.
