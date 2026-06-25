# 06 - Motion

> Version: 1.0
> Status: Active

---

# Purpose

This document defines all motion and animation guidelines for College Companion.

Animations should improve understanding, not attract attention.

If removing an animation improves usability, remove it.

---

# Motion Philosophy

Motion should:

* Explain state changes
* Provide feedback
* Improve continuity
* Feel natural
* Never distract

Animations are functional, not decorative.

---

# Motion Principles

Every animation should answer one question:

"What changed?"

If an animation doesn't answer that question, it probably shouldn't exist.

---

# General Rules

Animations should be:

* Smooth
* Fast
* Predictable
* Consistent

Avoid exaggerated animations.

---

# Animation Speed

Use Design Token durations only.

Recommended:

* Instant
* Fast
* Normal
* Slow

Do not hardcode durations.

---

# Page Transitions

Screen transitions should:

* Fade
* Slide naturally
* Feel lightweight

Avoid dramatic transitions.

---

# Bottom Navigation

Switching tabs should feel immediate.

Do not animate every element individually.

Preserve scroll position.

---

# Cards

Cards may animate when:

* Expanded
* Collapsed
* Added
* Removed

Avoid bounce effects.

---

# Attendance

When attendance is marked:

* Small success animation
* Optional haptic feedback
* Snackbar confirmation

Do not navigate away automatically.

---

# Buttons

Buttons should provide:

* Press feedback
* Disabled state
* Loading state

Avoid scaling animations.

---

# Lists

Items may animate when:

* Added
* Deleted
* Reordered

Animations should remain subtle.

---

# Bottom Sheets

Bottom Sheets should:

* Slide from bottom
* Dim background
* Close smoothly

Support swipe-to-dismiss.

---

# Dialogs

Dialogs should:

* Fade in
* Scale slightly
* Fade out on close

Avoid large zoom animations.

---

# Loading

Prefer:

* Skeletons
* Shimmer (subtle)

Avoid large spinning indicators whenever possible.

---

# Success

Examples:

Attendance Saved

Assignment Created

Subject Added

Feedback should be:

* Immediate
* Brief
* Non-intrusive

---

# Errors

Errors should:

* Shake only input fields when necessary
* Display clear messages
* Never flash the whole screen

---

# Pull to Refresh

Supported where appropriate.

Animation should follow Material Design.

---

# Haptic Feedback

Allowed:

* Attendance marked
* Successful save
* Long press
* Drag start

Avoid haptic feedback on every tap.

---

# Scroll Behavior

Scrolling should remain:

* Smooth
* Natural
* Responsive

Avoid unnecessary parallax.

---

# Hero Animations

Avoid Hero animations unless they significantly improve navigation.

---

# Motion Accessibility

Respect system animation settings whenever possible.

Avoid rapid flashing.

---

# Anti-Patterns

Do NOT:

* Bounce everything
* Use flashy transitions
* Overuse Hero animations
* Rotate UI elements unnecessarily
* Delay user interaction for animations

---

# Final Rule

Users should remember the experience—not the animations.

If a user notices the animation more than the content, it is too strong.

---

# Revision History

## v1.0

Initial motion specification.
