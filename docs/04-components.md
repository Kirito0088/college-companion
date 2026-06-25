# 04 - Components

> Version: 1.0
> Status: Active

---

# Purpose

This document defines every reusable UI component used throughout College Companion.

All screens must be built using these components.

Avoid creating one-off widgets unless absolutely necessary.

---

# Component Principles

Every component must be:

* Reusable
* Consistent
* Accessible
* Lightweight
* Responsive
* Stateless whenever possible

---

# Naming Convention

Use descriptive names.

Examples:

* PrimaryButton
* AttendanceCard
* SubjectChip
* EmptyState
* InfoTile

Avoid names like:

* Widget1
* Card2
* CustomButton

---

# Component Categories

The application consists of:

* Buttons
* Cards
* Text Fields
* Chips
* App Bars
* Bottom Navigation
* Lists
* Tiles
* Dialogs
* Bottom Sheets
* Snackbars
* Progress Indicators
* Empty States
* Loading States
* Badges
* Charts

---

# Buttons

## Primary Button

Purpose:

Primary action of the screen.

Examples:

* Save
* Add Subject
* Continue

Rules:

* One primary button per screen whenever possible.
* Supports loading state.
* Supports disabled state.

---

## Secondary Button

Purpose:

Alternative action.

Examples:

* Cancel
* Back
* Skip

---

## Icon Button

Purpose:

Compact actions.

Examples:

* Search
* Edit
* Delete
* Filter

Always include tooltip where appropriate.

---

## Floating Action Button

Use sparingly.

Allowed only when it represents the primary action of the screen.

Examples:

* Add Assignment
* Add Subject

Not allowed:

Dashboard

Settings

Profile

---

# Cards

## Attendance Card

Contains:

* Subject
* Attendance %
* Present
* Absent
* Safe Bunks

---

## Lecture Card

Contains:

* Subject
* Time
* Room
* Faculty
* Status

Supports quick attendance logging.

---

## Assignment Card

Contains:

* Title
* Due Date
* Subject
* Status

Supports swipe actions.

---

## Statistics Card

Displays summarized metrics.

Maximum four statistics per card.

---

# Text Fields

Supported types:

* Single Line
* Multi Line
* Search
* Numeric
* Date
* Time

Validation should occur immediately where appropriate.

---

# Search Bar

Always positioned near the top.

Supports:

* Clear button
* Instant search
* Placeholder text

---

# Chips

Used for:

* Filters
* Subjects
* Attendance Status
* Semester

Never use chips for navigation.

---

# Bottom Navigation

Maximum:

Five tabs.

Always display:

* Icon
* Label

Never hide labels.

---

# App Bar

Contains:

* Title
* Optional Back Button
* Maximum two action icons

Avoid clutter.

---

# Bottom Sheets

Preferred over dialogs for selections.

Examples:

* Select Attendance Status
* Choose Subject
* Filter Assignments

---

# Dialogs

Reserved for:

* Delete Confirmation
* Logout Confirmation
* Reset Data

Avoid using dialogs for simple selections.

---

# Snackbars

Purpose:

Temporary feedback.

Examples:

* Attendance Saved
* Assignment Deleted
* Sync Complete

Automatically dismiss.

---

# Progress Indicators

Types:

* Circular
* Linear

Avoid blocking the UI unless necessary.

---

# Empty State

Contains:

* Illustration or icon
* Title
* Description
* Primary action

Example:

"No assignments yet."

---

# Loading State

Prefer skeleton loaders.

Never replace an entire screen with a spinner.

---

# Badges

Used sparingly.

Examples:

* Due Today
* New
* Overdue

Do not overuse.

---

# Charts

Charts must remain simple.

Supported:

* Attendance Trend
* Subject Comparison

Avoid 3D charts.

Avoid unnecessary animations.

---

# Component Rules

Every component must support:

* Dark Theme
* Disabled State
* Loading State (where applicable)
* Accessibility Labels

---

# Reusability Rules

If the same UI appears on two screens:

Convert it into a reusable component.

Do not duplicate code.

---

# Performance Rules

Components should:

* Rebuild only when necessary.
* Avoid expensive layouts.
* Keep animations lightweight.

---

# Anti-Patterns

Do NOT:

* Duplicate components.
* Create screen-specific button styles.
* Hardcode colors.
* Hardcode spacing.
* Mix multiple interaction styles.

---

# Revision History

## v1.0

Initial reusable component specification.
