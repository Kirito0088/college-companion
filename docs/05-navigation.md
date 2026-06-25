# 05 - Navigation

> Version: 1.0
> Status: Active

---

# Purpose

This document defines how users navigate throughout College Companion.

Navigation should be intuitive, predictable and require little to no learning.

Users should always know:

* Where they are.
* Where they came from.
* Where they can go next.

---

# Navigation Principles

Navigation should be:

* Simple
* Consistent
* Predictable
* Fast

Avoid unnecessary navigation levels.

---

# Root Navigation

The application uses **Bottom Navigation** as the primary navigation method.

Maximum tabs:

**5**

---

# Bottom Navigation Tabs

1. Home
2. Attendance
3. Calendar
4. Assignments
5. Profile

The order must never change.

---

# Home

Purpose:

Quick overview of today's academic life.

Contains:

* Today's lectures
* Attendance summary
* Pending assignments
* Upcoming events
* Quick actions

---

# Attendance

Purpose:

Everything related to attendance.

Contains:

* Today's attendance
* Attendance history
* Subject-wise attendance
* Safe bunk calculator

---

# Calendar

Purpose:

Academic schedule.

Contains:

* Monthly calendar
* Lecture schedule
* Assignment due dates
* Holidays

---

# Assignments

Purpose:

Assignment management.

Contains:

* Pending
* Completed
* Due Today
* Overdue

---

# Profile

Purpose:

User information and application settings.

Contains:

* Account
* Semester Management
* Modules
* Notifications
* Data & Sync
* About

---

# Secondary Navigation

Secondary screens open using standard push navigation.

Examples:

Attendance

↓

Subject Details

↓

Attendance History

---

Assignments

↓

Assignment Details

↓

Edit Assignment

---

# Back Navigation

Back should always return to the previous logical screen.

Never unexpectedly close the application.

Support Android back gesture.

---

# Deep Navigation

Maximum recommended navigation depth:

**3 levels**

Example:

Home

↓

Attendance

↓

Subject Details

Good.

---

Home

↓

Attendance

↓

Subject

↓

Monthly History

↓

Lecture Details

Too deep.

---

# Quick Actions

Frequently used actions should never require more than two taps.

Examples:

Mark Attendance

Home

↓

Present

Done.

---

Create Assignment

Assignments

↓

*

↓

Save

Done.

---

# Floating Action Button

Only appears where it represents the primary action.

Allowed:

Assignments

Attendance (optional)

Semester Management

Not Allowed:

Home

Calendar

Profile

---

# Bottom Sheets

Use Bottom Sheets for:

* Subject selection
* Attendance status
* Filters
* Sort options

Do not navigate to a new page for simple selections.

---

# Dialogs

Only for confirmation.

Examples:

Delete Assignment

Reset Semester

Logout

---

# Navigation Animations

Navigation transitions should be:

* Fast
* Smooth
* Consistent

Avoid flashy transitions.

---

# State Preservation

Switching Bottom Navigation tabs should preserve:

* Scroll position
* Filters
* Search
* Temporary UI state

The user should feel like each tab remains "alive."

---

# Notifications

If the user opens the app from a notification:

Navigate directly to the relevant screen.

Example:

Assignment reminder

↓

Assignment Details

---

# Future Modules

Disabled modules should:

* Not appear in Bottom Navigation.
* Not appear on the Dashboard.
* Not be reachable through navigation.

---

# Empty Navigation

Avoid dead ends.

Every screen should provide a clear way forward.

---

# Anti-Patterns

Do NOT:

* Nest Bottom Navigation.
* Use Hamburger Menu.
* Hide primary features.
* Open unnecessary screens.
* Force users through multiple confirmation pages.

---

# Final Rule

The user should never need to ask:

"Where do I find this?"

Navigation should feel obvious after only a few minutes of use.

---

# Revision History

## v1.0

Initial navigation specification.
