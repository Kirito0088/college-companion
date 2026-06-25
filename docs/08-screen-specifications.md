# 08 - Screen Specifications

> Version: 1.0
> Status: Active

---

# Purpose

This document defines every screen in College Companion.

Each screen has a single responsibility.

Developers must not invent additional screens without updating this document.

---

# Design Rules

Every screen must:

* Follow Material Design 3.
* Follow Design Tokens.
* Follow UI Rules.
* Follow UX Principles.
* Have one primary purpose.
* Support Dark Theme.
* Be responsive.
* Handle loading, empty and error states.

---

# 1. Splash Screen

## Purpose

Initialize the application.

## Responsibilities

* Load local database.
* Restore session.
* Check internet connectivity.
* Start sync service.
* Navigate automatically.

## Navigation

Authenticated

↓

Dashboard

Unauthenticated

↓

Login

---

# 2. Login Screen

## Purpose

Authenticate the user.

## Components

* App Logo
* App Name
* Continue with Google Button
* Privacy Note

## Rules

No email/password.

No sign up form.

Google Sign-In only.

---

# 3. Onboarding

## Purpose

Configure the application.

## Steps

1. Welcome
2. Semester
3. Working Days
4. Subjects
5. Finish

Should never exceed five minutes.

---

# 4. Dashboard

## Purpose

Provide today's overview.

## Components

* Greeting
* Today's Lectures
* Attendance Summary
* Assignments
* Upcoming Events
* Quick Actions

## Rules

Never become a dashboard full of statistics.

Prioritize today's tasks.

---

# 5. Attendance

## Purpose

Track attendance.

## Components

* Today's Lectures
* Attendance Percentage
* Safe Bunks
* Subject List

## Actions

* Present
* Absent
* Cancelled
* Faculty Absent
* Holiday

---

# 6. Subject Details

## Purpose

Detailed attendance for one subject.

## Components

* Attendance %
* Present Count
* Absent Count
* History
* Attendance Trend

---

# 7. Calendar

## Purpose

Academic calendar.

## Components

* Monthly Calendar
* Events
* Lectures
* Assignments

Selecting a date updates the event list immediately.

---

# 8. Assignment List

## Purpose

Manage assignments.

## Sections

* Pending
* Due Today
* Completed

Supports sorting and filtering.

---

# 9. Assignment Details

## Components

* Title
* Description
* Subject
* Due Date
* Status

Supports edit and delete.

---

# 10. Add Assignment

## Components

* Title
* Subject
* Due Date
* Description

Keep the form short.

---

# 11. Internal Marks

## Purpose

Track internal assessment.

## Components

* Subject
* Test Scores
* Average
* Progress

---

# 12. Semester Management

## Purpose

Manage semesters.

## Features

* Add Semester
* Edit Semester
* Archive Semester
* Duplicate Semester

Never permanently delete data without confirmation.

---

# 13. Settings

## Categories

* Account
* Notifications
* Modules
* Data & Sync
* About

Avoid clutter.

---

# 14. Profile

## Components

* Name
* Google Account
* Current Semester
* Logout

---

# Common Screen States

Every screen must support:

### Loading

Skeleton UI.

---

### Empty

Helpful message.

Primary action.

---

### Error

Friendly explanation.

Retry action when appropriate.

---

# Common Navigation

Splash

↓

Login

↓

Onboarding

↓

Dashboard

↓

Feature Screens

---

# Common Actions

Attendance

↓

Mark Present

↓

Snackbar

↓

Auto Sync

---

Assignment

↓

Create

↓

Save

↓

Snackbar

↓

Auto Sync

---

# Future Screens

Reserved for:

* Notes
* CGPA
* Exam Countdown
* Semester Archive

These screens must follow the same standards before implementation.

---

# Revision History

## v1.0

Initial screen specification for Version 1.
