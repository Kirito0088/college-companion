# College Companion Design System

> **Version:** 1.0.0  
> **Status:** Locked  
> **Last Updated:** TBD  
> **Applies To:** Entire College Companion Project

---

# 1. Design Lock

## Purpose

This document defines the official user interface and user experience of College Companion.

It serves as the single source of truth for every UI-related decision throughout the project.

Every screen, component, interaction, animation, spacing rule, and visual style must follow this document.

---

## Design Status

**LOCKED**

The current design language has been finalized.

Future development should focus on improving implementation quality rather than redesigning the application.

---

## Allowed Changes

The following improvements are encouraged:

- Better spacing
- Better typography
- Better animations
- Better accessibility
- Better responsiveness
- Better loading states
- Better empty states
- Better offline experience
- Better performance

These improvements must preserve the existing visual identity.

---

## Not Allowed

The following changes are not allowed without creating a new design version:

- Changing the navigation structure
- Redesigning existing screens
- Introducing a new design language
- Changing the application's visual identity
- Switching to an iOS-inspired interface
- Adding unnecessary visual effects
- Replacing reusable components with one-off implementations

Major redesigns must be documented separately (for example, `DESIGN_v2.md`).

---

# 2. Product Vision

## Purpose

College Companion is an offline-first Android application built to help engineering students manage their academic life from a single place.

The application combines academic management, productivity tools, and future AI-powered features into one consistent experience.

The goal is not to provide dozens of disconnected tools.

The goal is to create one application that students naturally rely on every day.

---

## User Experience Goal

When users open College Companion, they should immediately understand:

- What requires attention today.
- What happens next.
- Whether anything is overdue.
- What action they should take next.

The application should reduce stress, not increase it.

---

## Product Personality

College Companion should always feel:

- Simple
- Modern
- Reliable
- Fast
- Calm
- Professional
- Student-focused

The application should never feel:

- Flashy
- Cluttered
- Experimental
- Trend-driven
- Corporate
- Gamified
- Overwhelming

---

# 3. Design Philosophy

Every design decision must satisfy one simple goal:

> Help students complete academic tasks with the least possible effort.

The interface should never become something users have to learn.

It should feel natural from the first day and familiar after months of use.

---

## Simplicity First

Whenever multiple solutions exist, choose the simpler one.

Avoid unnecessary UI elements.

Avoid unnecessary interactions.

Avoid unnecessary complexity.

The best interface is usually the simplest one.

---

## Information Before Decoration

Every visual element must have a purpose.

Decorative elements should never reduce readability.

The application should communicate information before aesthetics.

A clean interface is more valuable than a visually busy one.

---

## Consistency Above Everything

Every screen should feel like it belongs to the same application.

Buttons should behave consistently.

Cards should look consistent.

Spacing should remain consistent.

Animations should remain consistent.

Users should never have to guess how something works.

---

## Android First

College Companion is designed for Android.

The interface should follow Android conventions.

The application should feel familiar to Android users.

Avoid copying iOS interaction patterns.

Avoid chasing short-lived UI trends.

---

## Reusability

Every repeated interface pattern should become a reusable component.

Avoid duplicate widgets.

Avoid duplicated layouts.

Build once.

Reuse everywhere.

---

# 4. Design Principles

The following principles guide every UI decision.

## Clear Information Hierarchy

Users should immediately know:

- What is important.
- What is secondary.
- What can be ignored.

The interface should naturally guide the user's attention.

---

## One Purpose Per Screen

Every screen should answer one primary question.

Examples:

Dashboard

"What should I do today?"

Attendance

"How is my attendance?"

Calendar

"What happens next?"

Profile

"How is my account configured?"

Avoid mixing unrelated responsibilities into a single screen.

---

## Progressive Disclosure

Show only the information users need right now.

Allow users to navigate deeper when they want more detail.

Avoid overwhelming users with unnecessary information.

---

## Comfortable Reading

The application should never feel crowded.

Whitespace is intentional.

Spacing improves readability.

Readable interfaces are more valuable than dense interfaces.

---

## Accessible By Default

Every feature should remain usable with:

- Large text
- Screen readers
- Dark mode
- One-handed use
- Reduced motion

Accessibility is part of the design, not an afterthought.

---

# AI Notes

When implementing any screen:

- Follow this document.
- Do not redesign existing layouts.
- Reuse shared components whenever possible.
- Keep spacing consistent.
- Follow design tokens.
- Prioritize usability over visual experimentation.

# 5. Visual Identity

## Purpose

This section defines the visual identity of College Companion.

The goal is to create a clean, modern, and familiar Android experience that students enjoy using every day.

The visual design should feel premium without being flashy.

Users should immediately recognize the application as organized, reliable, and easy to use.

---

## Overall Style

College Companion follows a modern Android design language inspired by Material Design 3.

The application maintains its own identity while respecting established Android interaction patterns.

The interface should feel:

- Clean
- Spacious
- Modern
- Professional
- Minimal
- Consistent

The interface should never feel:

- Cluttered
- Corporate
- Experimental
- Over-decorated
- Trend-driven
- iOS-inspired

---

## Theme

College Companion is a **Dark-First** application.

Dark mode is the primary design target.

Every screen must be designed for dark mode first.

If light mode is added in the future, it should mirror the same visual hierarchy and component behavior.

---

## Color Philosophy

Colors communicate meaning.

They should never exist purely for decoration.

The interface should primarily use neutral surfaces with purple acting as the primary accent.

Accent colors should guide user attention instead of dominating the interface.

Semantic colors should only represent status.

Examples:

- Green → Success
- Amber → Warning
- Red → Error
- Blue → Information

Avoid using multiple accent colors on the same screen unless they communicate different states.

---

## Typography

Typography should establish hierarchy before colors do.

Every screen should clearly communicate:

- Screen title
- Section title
- Card title
- Body content
- Supporting information

Typography should remain simple and readable.

Avoid decorative fonts.

Avoid excessive font weights.

Avoid unnecessary capitalization.

---

## Icons

The application uses **Material Symbols Rounded** exclusively.

Do not mix icon packs.

Icons should support recognition, not replace text.

Important actions should always include both an icon and a label.

---

## Cards

Cards are the primary building block of the interface.

Every card should represent one logical piece of information.

Examples:

- Semester Card
- Subject Card
- Attendance Card
- Assignment Card
- Lecture Card

Cards should never become mini dashboards.

Avoid placing cards inside cards whenever possible.

---

## Buttons

Buttons should clearly communicate priority.

Every screen should have one primary action.

Secondary actions should remain visually less prominent.

Destructive actions must always be visually distinguishable.

Buttons should remain large enough for comfortable one-handed interaction.

---

## Chips

Chips should only be used for:

- Status
- Filters
- Categories
- Quick selection

Avoid using chips as decorative labels.

---

## Progress Indicators

Progress indicators should communicate meaningful progress.

Examples include:

- Attendance percentage
- Assignment completion
- Sync progress
- Semester progress

Avoid decorative progress rings.

Every progress indicator should answer a useful question.

---

## Navigation Bar

The Bottom Navigation Bar is the primary navigation mechanism.

It should remain simple and predictable.

Navigation labels should always remain visible.

Avoid icon-only navigation.

---

## Floating Action Button

The Floating Action Button (FAB) should represent the most important action available on the current screen.

Not every screen requires a FAB.

If a FAB does not improve the user's workflow, it should not exist.

---

## App Bars

Every screen should have one clear title.

App bars should remain lightweight.

Avoid placing unnecessary actions in the App Bar.

Only actions directly related to the current screen should appear there.

---

## Dialogs

Dialogs should only be used for:

- Confirmation
- Small forms
- Important information

Do not build full screens inside dialogs.

---

## Bottom Sheets

Bottom Sheets are preferred over dialogs for contextual actions.

Examples:

- Quick Edit
- Select Semester
- Choose Subject
- Filter Options

Bottom Sheets should feel connected to the current screen.

---

## Empty States

Every feature must have a meaningful empty state.

An empty state should explain:

- Why nothing is shown
- What the user can do next
- How to get started

Never display a completely blank screen.

---

## Loading States

Loading should feel intentional.

Whenever practical, use skeleton loading instead of generic loading spinners.

Users should understand what content is currently loading.

---

## Error States

Errors should be human-readable.

Every error should explain:

- What happened
- Why it happened (if known)
- What the user can do next

Never expose technical exception messages to the user.

---

## Visual Consistency Rules

All screens must follow the same visual language.

Maintain consistency in:

- Card styling
- Typography
- Spacing
- Icons
- Button hierarchy
- Colors
- Navigation
- Component behavior

Users should never feel like they are using different applications while navigating through College Companion.

---

## AI Notes

When implementing UI:

- Preserve the existing visual identity.
- Do not redesign screens.
- Reuse shared components whenever possible.
- Use the design token system.
- Maintain consistent spacing and typography.
- Avoid introducing new visual styles without updating this document.

# 6. Design Tokens

## Purpose

Design Tokens define the reusable visual values used throughout College Companion.

They ensure every screen follows the same spacing, typography, colors, radius, elevation, and sizing rules.

Developers should always use design tokens instead of hardcoded values.

---

## Color Tokens

The application uses a dark-first color palette.

### Primary

Used for:

- Primary buttons
- Active navigation
- Selected chips
- Primary actions
- Important highlights

### Surface

Used for:

- Cards
- Containers
- Dialogs
- Bottom sheets

### Background

Used for:

- Screen backgrounds

### Success

Used for:

- Completed tasks
- Healthy attendance
- Successful operations

### Warning

Used for:

- Low attendance
- Upcoming deadlines
- Pending actions

### Error

Used for:

- Failed operations
- Overdue assignments
- Critical warnings

### Information

Used for:

- Neutral notifications
- Academic information

---

## Color Rules

- Purple is the only primary accent.
- Semantic colors communicate state only.
- Avoid excessive color usage.
- Never use color as the only indicator of meaning.
- Support color-blind accessibility.

---

## Typography Tokens

Typography creates hierarchy.

The hierarchy is:

1. Screen Title
2. Section Header
3. Card Title
4. Body Text
5. Supporting Text
6. Caption

Keep typography simple and readable.

Avoid excessive font weights.

---

## Spacing Tokens

Spacing follows an 8-point grid.

Allowed spacing values:

```
4
8
12
16
20
24
32
40
48
56
64
80
96
```

Never invent new spacing values.

---

## Screen Padding

Default horizontal padding:

```
20
```

Default vertical spacing between sections:

```
24
```

Large separation:

```
32
```

---

## Radius Tokens

Small

```
8
```

Medium

```
12
```

Large

```
16
```

Extra Large

```
24
```

Circular

```
999
```

Do not use arbitrary border radius values.

---

## Elevation

Use subtle elevation.

Prefer tonal surfaces over heavy shadows.

Hierarchy:

- Background
- Surface
- Elevated Surface
- Dialog
- Bottom Sheet
- Overlay

Avoid strong shadows.

---

## Icon Tokens

Use **Material Symbols Rounded**.

Default icon size:

```
24
```

Small:

```
20
```

Large:

```
28
```

Extra Large:

```
32
```

Do not mix icon libraries.

---

## Button Tokens

Primary Button

Highest priority action.

Only one primary button should exist within a logical section.

Secondary Button

Supporting actions.

Outlined or tonal.

Text Button

Low-priority actions.

Danger Button

Destructive actions only.

---

## Card Tokens

Cards are information containers.

Every card should have:

- Consistent padding
- Consistent radius
- Consistent elevation
- Clear hierarchy

Cards should never contain unrelated information.

---

## Motion Tokens

Animations should feel quick and natural.

Recommended durations:

Micro Interaction

```
100ms
```

Button Press

```
150ms
```

State Change

```
200ms
```

Screen Transition

```
300ms
```

Dialog

```
250ms
```

Bottom Sheet

```
300ms
```

Avoid animations longer than 400ms.

---

## Touch Targets

Minimum touch target:

```
48 × 48 dp
```

All interactive components must satisfy this requirement.

---

## Accessibility

The design token system must support:

- Large font scaling
- Screen readers
- High contrast
- Reduced motion
- Landscape mode
- Future tablet layouts

Accessibility should never require a separate design system.

---

## Implementation Rules

Developers should never write:

```dart
EdgeInsets.all(17)
```

Instead:

```dart
SpacingTokens.lg
```

Developers should never hardcode colors.

Instead:

```dart
ColorTokens.primary
```

Developers should never hardcode border radius.

Instead:

```dart
RadiusTokens.large
```

All reusable visual values should originate from the shared design token system.

---

## AI Notes

When implementing UI:

- Never hardcode spacing.
- Never hardcode colors.
- Never hardcode radius.
- Reuse design tokens everywhere.
- If a required token does not exist, add it to the shared token system before using it.

# 7. Navigation

## Purpose

Navigation allows users to move through College Companion quickly, predictably, and with minimal effort.

The navigation system should become muscle memory.

Users should never think about how to move around the application.

They should focus entirely on their academic tasks.

---

## Navigation Philosophy

College Companion uses a simple navigation structure.

Every feature should fit naturally into the existing navigation.

Avoid adding new navigation layers unless absolutely necessary.

The navigation system should remain stable throughout the lifetime of Version 1.

---

## Primary Navigation

College Companion uses **Bottom Navigation** as its primary navigation method.

The Bottom Navigation Bar contains exactly five destinations:

1. Home
2. Attendance
3. Academics
4. Calendar
5. Profile

This order is locked.

Do not add additional primary navigation items.

---

## Home

Purpose:

Provide a summary of today's academic life.

The Home screen answers:

- What should I do today?
- What happens next?
- Is anything urgent?

The Home screen is not a feature screen.

It is a summary screen.

---

## Attendance

Purpose:

Monitor attendance across all subjects.

Users should immediately understand:

- Current attendance
- Attendance health
- Safe bunk availability

---

## Academics

Purpose:

Manage academic information.

This includes:

- Semesters
- Subjects
- Internal Marks
- Academic Resources (Future)

Academics should organize information rather than summarize it.

---

## Calendar

Purpose:

Display academic events in chronological order.

This includes:

- Lectures
- Assignments
- Exams
- Personal events

Calendar should always prioritize upcoming events.

---

## Profile

Purpose:

Manage the user's account and application settings.

Examples:

- User profile
- Preferences
- Theme
- Backup
- Sync
- About

Profile should never become another dashboard.

---

## Navigation Hierarchy

The application should use a maximum of three navigation levels.

Level 1

Top-level destinations.

Example:

Home

↓

Attendance

↓

Academics

↓

Calendar

↓

Profile

---

Level 2

Feature screens.

Example:

Attendance

↓

Subject Attendance

↓

Semester Details

---

Level 3

Detail screens.

Example:

Assignment Details

Subject Details

Edit Subject

Edit Assignment

Avoid navigating deeper than three levels.

---

## Back Navigation

Android Back should always behave naturally.

Pressing Back should:

- Return to the previous screen.
- Preserve scroll position whenever possible.
- Never unexpectedly close the application.

Avoid custom back behavior unless required.

---

## Floating Action Button (FAB)

The FAB represents the most important action available on the current screen.

Examples:

Assignments

→ Create Assignment

Attendance

→ Add Attendance

Calendar

→ Add Event

Subjects

→ Add Subject

The Home screen should generally not use a FAB.

Do not add a FAB simply because space is available.

---

## Search

Search should only exist where it provides clear value.

Recommended screens:

- Subjects
- Assignments
- Resources (Future)
- Notes (Future)

Search should never replace good navigation.

---

## Filters

Filters refine information.

Search finds information.

Keep these concepts separate.

Filters should remain simple.

Avoid complex filtering systems.

---

## Sorting

Default sorting should require no user interaction.

Preferred order:

1. Time
2. Priority
3. Alphabetical

Users should rarely need manual sorting.

---

## Dialogs

Use dialogs for:

- Confirmation
- Small forms
- Critical information

Do not place full feature workflows inside dialogs.

---

## Bottom Sheets

Prefer Bottom Sheets for contextual interactions.

Examples:

- Quick Edit
- Filter Options
- Select Semester
- Select Subject

Bottom Sheets should feel connected to the current screen.

---

## Snackbars

Snackbars provide temporary feedback.

Examples:

- Assignment Created
- Attendance Updated
- Changes Saved
- Sync Complete

Snackbars should disappear automatically.

Do not use Snackbars for critical errors.

---

## Navigation Rules

- Keep navigation predictable.
- Keep navigation shallow.
- Avoid unnecessary screens.
- Avoid hidden navigation.
- Preserve Android conventions.
- Preserve user context whenever possible.

---

## AI Notes

When implementing navigation:

- Do not change the Bottom Navigation structure.
- Do not introduce additional primary destinations.
- Keep navigation depth to three levels or fewer.
- Preserve Android Back behavior.
- Follow existing navigation patterns before introducing new ones.

# 8. Screen Specifications

This section defines the purpose, layout, behavior, and implementation rules for every screen in College Companion.

Every screen must follow these specifications.

Do not redesign screens unless a new design version is approved.

---

# Dashboard

## Purpose

The Dashboard is the application's home screen.

It provides students with a quick overview of their academic day.

The Dashboard is designed to answer four questions:

- What should I do today?
- What happens next?
- Is anything urgent?
- What action should I take now?

The Dashboard is **not** a feature screen.

It is a summary screen that surfaces the most relevant information from the rest of the application.

---

## Goals

The Dashboard should help students:

- Start their day quickly.
- Identify urgent tasks.
- View important academic information at a glance.
- Navigate to feature screens when needed.

---

## Layout

The Dashboard contains the following sections in order.

1. Welcome Section

Displays:

- Greeting
- User name
- Current date

---

2. Current Semester

Displays:

- Active semester
- Semester status

---

3. Today's Overview

Displays:

- Number of lectures today
- Assignments due today
- Upcoming events

---

4. Next Lecture

Displays:

- Subject
- Time
- Classroom (if available)

If there are no remaining lectures today, display a friendly empty state.

---

5. Quick Stats

Displays summary information such as:

- Attendance Percentage
- Pending Assignments
- Internal Marks Summary
- Subjects

Quick Stats should never replace dedicated feature screens.

Only summaries belong here.

---

6. Recent Activity

Displays recent academic activity.

Examples:

- Assignment completed
- Attendance marked
- Subject added
- Semester created

Show only the most recent items.

---

7. Quick Actions

Provides shortcuts to frequently used actions.

Examples:

- Add Assignment
- Mark Attendance
- Add Subject
- View Calendar

Keep Quick Actions limited to the most commonly used workflows.

---

## Layout Rules

The Dashboard should scroll vertically.

Avoid horizontal scrolling.

Sections should appear in a predictable order.

Every section should be separated by consistent spacing.

Cards should align to the application's design system.

---

## Information Priority

Display information in the following order of importance.

1. Urgent
2. Today's Information
3. Upcoming Information
4. Recent Activity

Avoid showing information that is no longer relevant.

---

## Data Sources

Dashboard information should come from existing repositories.

Examples include:

- User Repository
- Semester Repository
- Subject Repository
- Attendance Repository
- Assignment Repository
- Internal Marks Repository

Avoid duplicate business logic inside the Dashboard.

The Dashboard should aggregate information rather than calculate it.

---

## Empty States

Each section should gracefully handle empty data.

Examples:

No active semester

Display:

"Create your first semester to get started."

No lectures today

Display:

"No lectures scheduled for today."

No assignments

Display:

"You're all caught up."

Avoid blank sections.

---

## Loading State

While data is loading:

- Show skeleton placeholders.
- Preserve the final layout.
- Avoid layout shifts.

Do not display large loading spinners unless absolutely necessary.

---

## Error State

If a section fails to load:

- Display a simple error message.
- Allow retry when appropriate.
- Continue showing other successfully loaded sections.

One failed section should never prevent the entire Dashboard from loading.

---

## Offline Behavior

The Dashboard must work offline.

Display locally available information immediately.

Show sync status unobtrusively.

Do not block interaction while waiting for network connectivity.

---

## Performance

The Dashboard should remain lightweight.

Avoid unnecessary rebuilds.

Lazy-load expensive operations when appropriate.

Avoid loading historical data that is not immediately visible.

---

## Accessibility

The Dashboard should support:

- Screen readers
- Large text scaling
- High contrast
- One-handed use

Interactive elements must satisfy minimum touch target requirements.

---

## Future Expansion

Future Dashboard sections may include:

- AI Planner
- Study Streak
- Exam Countdown
- Smart Insights
- Weekly Goals

Future additions must not disrupt the existing information hierarchy.

Avoid adding more than one new major section without reviewing the overall layout.

---

## Design Rules

The Dashboard should never:

- Duplicate feature screens.
- Become a statistics page.
- Show unnecessary information.
- Require horizontal scrolling.
- Become visually cluttered.
- Depend entirely on internet connectivity.

The Dashboard exists to summarize, not replace, the rest of the application.

---

## AI Notes

When implementing the Dashboard:

- Do not redesign the layout.
- Reuse shared components.
- Follow design tokens.
- Keep sections independent.
- Preserve the defined section order.
- Do not introduce additional sections without updating this document.

# Attendance

## Purpose

The Attendance screen helps students monitor and manage their attendance across all subjects.

It should immediately answer one question:

**"Can I safely maintain my attendance?"**

This screen is dedicated to attendance management and should not display unrelated academic information.

---

## Goals

The Attendance screen should help students:

- View attendance for every subject.
- Identify subjects below the required threshold.
- Understand attendance trends.
- Estimate safe bunk availability.
- Record attendance quickly.

---

## Layout

The Attendance screen contains the following sections in order.

### 1. Attendance Summary

Displays:

- Overall Attendance Percentage
- Safe Bunk Count (if applicable)
- Subjects Below Threshold
- Attendance Trend

This section provides a quick overview of attendance health.

---

### 2. Subject Attendance List

Displays every subject.

Each subject card contains:

- Subject Name
- Current Attendance Percentage
- Present Lectures
- Total Lectures
- Status Indicator

Selecting a subject opens its detailed attendance page.

---

### 3. Attendance Insights

Displays useful information such as:

- Highest Attendance
- Lowest Attendance
- Subjects Requiring Attention
- Weekly Attendance Trend

Only actionable insights should be displayed.

---

### 4. Quick Actions

Examples:

- Mark Attendance
- View Attendance History
- Attendance Calculator

Keep actions limited to commonly used tasks.

---

## Layout Rules

The screen scrolls vertically.

Subject cards should be displayed in a single column.

Avoid horizontal scrolling.

Maintain consistent spacing between sections.

---

## Information Priority

Display information in this order:

1. Critical Attendance Warnings
2. Overall Attendance
3. Subject List
4. Insights
5. Quick Actions

Students should immediately recognize subjects that require attention.

---

## Data Sources

Attendance information should use:

- Attendance Repository
- Subject Repository
- Semester Repository

Attendance calculations should remain inside repositories or services.

The UI should only display computed results.

---

## Subject Card

Each subject card should display:

- Subject Name
- Attendance Percentage
- Present / Total Lectures
- Attendance Status

Optional:

- Safe Bunk Remaining
- Required Lectures to Recover

Cards should remain compact and easy to scan.

---

## Attendance Status

Attendance status should use semantic colors.

Healthy

Green

Warning

Amber

Critical

Red

Color should support the status text, not replace it.

---

## Empty State

If no attendance records exist:

Display:

"No attendance records available."

Provide an action to begin recording attendance.

Do not display an empty list.

---

## Loading State

While attendance is loading:

- Show skeleton subject cards.
- Preserve layout.
- Avoid layout shifts.

---

## Error State

If attendance fails to load:

Display:

"Unable to load attendance."

Allow the user to retry.

Other sections should remain usable.

---

## Offline Behavior

Attendance must be fully usable offline.

Attendance changes should:

- Save locally.
- Sync automatically when connectivity returns.

Users should always know whether changes are pending synchronization.

---

## Performance

Avoid rebuilding the entire list after updating one subject.

Update only affected cards.

Support smooth scrolling regardless of subject count.

---

## Accessibility

Support:

- Large text
- Screen readers
- High contrast
- Minimum touch targets

Attendance status should never rely on color alone.

---

## Future Expansion

Future additions may include:

- Attendance Predictions
- AI Attendance Suggestions
- Smart Notifications
- Attendance Analytics
- Semester Comparisons

Future features should extend the existing layout instead of replacing it.

---

## Design Rules

The Attendance screen should never:

- Display assignments.
- Display timetable information.
- Duplicate dashboard summaries.
- Hide critical attendance warnings.
- Require unnecessary navigation.

The primary purpose is attendance management.

---

## AI Notes

When implementing the Attendance screen:

- Keep subject cards consistent.
- Reuse shared components.
- Use semantic colors correctly.
- Follow design tokens.
- Do not redesign the screen layout.

# Academics

## Purpose

The Academics screen is the central workspace for managing a student's academic structure.

It organizes all academic entities rather than summarizing them.

This screen answers one question:

**"How are my academics organized?"**

---

## Goals

The Academics screen should help students:

- Manage semesters.
- Organize subjects.
- Track internal marks.
- Access subject-specific information.
- Build the academic structure before using other features.

This screen serves as the foundation for Attendance, Timetable, Assignments, and Calendar.

---

## Layout

The Academics screen contains the following sections in order.

### 1. Current Semester

Displays:

- Active Semester
- Semester Status
- Academic Year
- Number of Subjects

Allow users to switch between semesters when multiple semesters exist.

---

### 2. Subjects

Displays every subject belonging to the active semester.

Each subject card displays:

- Subject Name
- Subject Code (if available)
- Faculty Name (optional)
- Lecture Count (optional)

Selecting a subject opens the Subject Details screen.

---

### 3. Internal Marks

Displays a summary of internal assessments.

Examples:

- Average Internal Marks
- Highest Subject Score
- Lowest Subject Score
- Recent Assessments

This section provides a quick overview only.

Detailed marks belong inside Subject Details.

---

### 4. Quick Actions

Examples:

- Add Semester
- Add Subject
- Add Internal Marks

Only include actions directly related to academics.

---

## Layout Rules

The Academics screen scrolls vertically.

Display subject cards in a single-column layout.

Maintain consistent spacing between sections.

Avoid horizontal scrolling.

---

## Information Priority

Display information in this order:

1. Active Semester
2. Subjects
3. Internal Marks Summary
4. Quick Actions

The active semester should always remain the primary focus.

---

## Data Sources

Academics should use:

- Semester Repository
- Subject Repository
- Internal Marks Repository

Business logic should remain inside repositories or services.

The UI should only display prepared data.

---

## Subject Card

Each Subject Card should display:

- Subject Name
- Subject Code (optional)
- Faculty Name (optional)
- Subject Status

Cards should remain clean and compact.

Avoid displaying excessive statistics.

---

## Semester Switching

Users should be able to switch between semesters easily.

Switching semesters should update:

- Subjects
- Internal Marks
- Related academic information

The transition should feel immediate.

---

## Empty State

If no semester exists:

Display:

"Create your first semester to begin."

Provide an action to create a semester.

If a semester exists but contains no subjects:

Display:

"No subjects added yet."

Provide an action to add a subject.

---

## Loading State

While loading:

- Display skeleton cards.
- Preserve screen layout.
- Avoid sudden layout changes.

---

## Error State

If academic data cannot be loaded:

Display a simple message.

Allow retry.

Do not block access to successfully loaded sections.

---

## Offline Behavior

Academics must work fully offline.

Creating or editing:

- Semesters
- Subjects
- Internal Marks

should update the local database immediately.

Synchronization should occur automatically when connectivity returns.

---

## Performance

Avoid rebuilding the complete subject list after editing one subject.

Update only affected components.

Support large semester structures without affecting scrolling performance.

---

## Accessibility

Support:

- Screen readers
- Large text
- High contrast
- One-handed navigation

Interactive components must satisfy minimum touch target requirements.

---

## Future Expansion

Future additions may include:

- Academic Resources
- Notes
- Study Materials
- Faculty Information
- Subject Analytics
- AI Study Recommendations

Future modules should extend existing subject workflows instead of introducing new navigation.

---

## Design Rules

The Academics screen should never:

- Display attendance summaries.
- Display timetable information.
- Display assignment summaries.
- Duplicate dashboard information.
- Become a statistics dashboard.

Its responsibility is academic organization.

---

## AI Notes

When implementing the Academics screen:

- Follow the existing information hierarchy.
- Reuse shared cards.
- Keep semester switching intuitive.
- Do not redesign the layout.
- Follow design tokens.
- Keep business logic outside the UI layer.

# Profile

## Purpose

The Profile screen allows users to manage their account, preferences, and application settings.

It should answer one question:

**"How is my College Companion configured?"**

The Profile screen is not intended to display academic information.

Its responsibility is user identity, preferences, synchronization, and application settings.

---

## Goals

The Profile screen should help users:

- View their account information.
- Manage application preferences.
- Configure sync behavior.
- Access settings.
- Learn about the application.

The screen should remain clean and organized.

---

## Layout

The Profile screen contains the following sections in order.

### 1. User Profile

Displays:

- Profile Picture
- Full Name
- Email Address

This information comes from the authenticated user account.

---

### 2. Academic Profile

Displays:

- Current Semester
- Number of Subjects
- Overall Attendance
- Pending Assignments

This section provides a brief academic summary only.

Detailed information belongs on dedicated feature screens.

---

### 3. Preferences

Examples:

- Notifications
- Theme (Future)
- Default Semester
- Calendar Preferences

Only application preferences belong here.

---

### 4. Data & Sync

Displays:

- Sync Status
- Last Successful Sync
- Pending Changes
- Storage Information

Users should always understand whether their data has been synchronized.

---

### 5. Settings

Examples:

- Application Settings
- Privacy
- Help & Support
- About

Group related settings together.

Avoid excessively long settings lists.

---

### 6. Account Actions

Examples:

- Export Data (Future)
- Sign Out

Destructive actions should always appear last.

---

## Layout Rules

The Profile screen scrolls vertically.

Each section should be visually separated.

Avoid excessive nesting.

Maintain consistent spacing.

---

## Information Priority

Display information in this order:

1. User Identity
2. Academic Summary
3. Preferences
4. Sync Status
5. Settings
6. Account Actions

---

## Data Sources

The Profile screen should use:

- User Repository
- User Settings Repository
- Semester Repository
- Assignment Repository
- Attendance Repository

Business logic should remain outside the UI layer.

---

## Empty State

If profile information is unavailable:

Display:

"Unable to load profile."

Allow the user to retry.

---

## Loading State

While loading:

- Display skeleton placeholders.
- Preserve layout.
- Avoid layout shifts.

---

## Error State

If profile information cannot be loaded:

Display a simple error message.

Allow retry.

Previously loaded information should remain visible whenever possible.

---

## Offline Behavior

Profile information should remain accessible offline.

User preferences should update immediately.

Synchronization should occur automatically when connectivity returns.

---

## Performance

Avoid rebuilding the entire screen after changing one preference.

Update only affected sections.

---

## Accessibility

Support:

- Screen readers
- Large text
- High contrast
- One-handed navigation

Interactive elements must satisfy minimum touch target requirements.

---

## Future Expansion

Future additions may include:

- Cloud Backup
- Multi-device Sync
- AI Preferences
- Notification Preferences
- Connected Services
- Privacy Dashboard

Future additions should integrate into existing sections instead of creating new screen structures.

---

## Design Rules

The Profile screen should never:

- Become another dashboard.
- Display detailed academic analytics.
- Duplicate feature screens.
- Hide important account actions.
- Mix settings with academic workflows.

The screen exists for account management and application configuration.

---

## AI Notes

When implementing the Profile screen:

- Keep the layout simple and predictable.
- Reuse shared setting tiles.
- Follow design tokens.
- Follow the existing information hierarchy.
- Do not redesign the screen.

# 9. Shared Components

## Purpose

Shared Components are reusable UI building blocks used throughout College Companion.

Their purpose is to provide a consistent user experience while reducing duplicate code.

Every repeated UI pattern should become a shared component.

Feature modules should compose these components instead of creating custom widgets whenever possible.

---

## Component Philosophy

Components should be:

- Reusable
- Consistent
- Lightweight
- Accessible
- Easy to maintain

A component should solve one UI problem well.

Avoid creating overly generic components that become difficult to understand or maintain.

---

# CCCard

## Purpose

The base container used throughout the application.

Used for:

- Dashboard sections
- Subject cards
- Assignment cards
- Attendance cards
- Information panels

Rules:

- Consistent padding
- Consistent border radius
- Consistent elevation
- No nested cards unless absolutely necessary

---

# CCSectionHeader

## Purpose

Separates major sections within a screen.

Displays:

- Section title
- Optional subtitle
- Optional action button

Examples:

- View All
- See More
- Manage

Rules:

- One header per section
- Keep actions optional
- Maintain consistent spacing

---

# CCStatCard

## Purpose

Displays one key metric.

Examples:

- Attendance
- Pending Assignments
- Subjects
- Internal Marks

Rules:

- One metric per card
- Keep text concise
- Avoid paragraphs

---

# CCSubjectCard

## Purpose

Displays summary information about a subject.

May include:

- Subject Name
- Subject Code
- Faculty
- Attendance
- Internal Marks

Rules:

- Compact layout
- Easy to scan
- Consistent hierarchy

---

# CCAttendanceCard

## Purpose

Displays attendance information for one subject.

Displays:

- Percentage
- Present Lectures
- Total Lectures
- Attendance Status

Rules:

- Highlight important changes
- Never rely only on color
- Keep calculations outside the UI

---

# CCAssignmentCard

## Purpose

Displays assignment information.

Displays:

- Assignment Title
- Subject
- Due Date
- Status

Rules:

- Prioritize upcoming deadlines
- Show overdue status clearly
- Keep content compact

---

# CCEventCard

## Purpose

Displays calendar events.

Examples:

- Lecture
- Assignment
- Exam
- Reminder

Rules:

- Display chronological information
- Include event type
- Keep layout consistent

---

# CCQuickAction

## Purpose

Represents a frequently used action.

Examples:

- Add Assignment
- Mark Attendance
- Add Subject
- View Calendar

Rules:

- Use recognizable icons
- Short labels only
- Avoid long descriptions

---

# CCEmptyState

## Purpose

Displayed when a feature contains no data.

Every empty state should include:

- Friendly illustration or icon
- Short explanation
- Suggested action

Example:

"No assignments yet."

Button:

"Create Assignment"

Never leave users staring at an empty screen.

---

# CCSkeleton

## Purpose

Displayed while content is loading.

Rules:

- Match final layout
- Avoid layout shifts
- Replace loading spinners whenever practical

---

# CCBadge

## Purpose

Display small pieces of supporting information.

Examples:

- Upcoming
- Overdue
- Completed
- Draft

Badges should never become primary information.

---

# CCChip

## Purpose

Display filters or categories.

Examples:

- Semester
- Subject
- Status

Rules:

- Keep labels short
- Use only for selection or filtering
- Avoid decorative usage

---

# CCProgressIndicator

## Purpose

Display meaningful progress.

Examples:

- Attendance
- Assignment Completion
- Sync Progress

Progress indicators should communicate useful information.

Avoid decorative progress bars.

---

# CCDialog

## Purpose

Display confirmations and small forms.

Examples:

- Delete Confirmation
- Rename Subject
- Sign Out

Rules:

- Keep dialogs focused
- Avoid large workflows
- Prefer Bottom Sheets when more space is required

---

# CCBottomSheet

## Purpose

Display contextual actions.

Examples:

- Quick Edit
- Filter
- Select Semester
- Select Subject

Rules:

- Context-specific
- Lightweight
- Easy to dismiss

---

# Component Rules

Every shared component should:

- Follow Design Tokens
- Support accessibility
- Support dark mode
- Support large text
- Remain reusable
- Avoid business logic

Components should receive data.

They should not fetch data themselves.

---

# AI Notes

When implementing UI:

- Always check whether an existing shared component can be reused.
- Avoid creating duplicate widgets.
- Keep shared components presentation-only.
- Business logic belongs in repositories, services, or providers.
- If a new reusable pattern appears in multiple places, promote it to a shared component.

# 10. Motion & Accessibility

## Purpose

Motion and accessibility improve the overall user experience.

Animations should help users understand the interface.

Accessibility ensures every student can comfortably use College Companion regardless of device, ability, or preferences.

Both are considered core features of the application.

---

# Motion

## Philosophy

Animations should communicate change.

They should never exist purely for decoration.

The interface should always feel responsive.

Users should immediately understand:

- What changed
- Why it changed
- Where it moved

---

## Motion Guidelines

Animations should be:

- Fast
- Smooth
- Subtle
- Consistent

Avoid:

- Excessive animations
- Bounce effects
- Dramatic scaling
- Long delays
- Flashy transitions

The interface should feel responsive rather than animated.

---

## Recommended Motion

Use animations for:

- Screen transitions
- Card expansion
- Bottom sheets
- Dialog appearance
- List insertions
- State changes
- Loading placeholders

Avoid animating every interaction.

Only animate meaningful changes.

---

## Loading Experience

Whenever possible:

- Use skeleton loading.
- Preserve layout while loading.
- Avoid sudden layout shifts.

Loading indicators should communicate progress without distracting the user.

---

## Feedback

Every important user action should provide feedback.

Examples:

- Button ripple
- Snackbar
- Progress indicator
- Confirmation dialog

Feedback should be immediate.

Users should never wonder whether an action was successful.

---

## Accessibility

Accessibility is required for every feature.

Every screen should support:

- Screen readers
- Large font scaling
- High contrast
- Reduced motion
- One-handed use
- Landscape orientation

Accessibility should be considered during implementation rather than added later.

---

## Touch Targets

Every interactive element should remain easy to tap.

Minimum touch target:

```
48 × 48 dp
```

Visual size and touch area do not need to be identical.

Usability takes priority.

---

## Text Scaling

Layouts should remain usable with larger accessibility fonts.

Avoid fixed-height containers that clip text.

Allow cards to expand naturally when additional space is required.

---

## Color Accessibility

Never rely on color alone.

Every status should also include:

- Text
- Icon
- Label

Examples:

✓ Healthy

⚠ Warning

✕ Critical

Users should understand information even with color vision deficiencies.

---

## Screen Readers

Every interactive component should provide meaningful labels.

Buttons should describe their action.

Icons should include semantic labels when appropriate.

Avoid unlabeled interactive elements.

---

## Performance

Animations should never reduce responsiveness.

Maintain smooth scrolling throughout the application.

Prefer subtle transitions over complex animations.

Users should always feel in control.

---

## Design Rules

Motion should support usability.

Accessibility should never be optional.

Performance is more important than animation.

If an animation negatively impacts usability, remove it.

---

## AI Notes

When implementing UI:

- Keep animations subtle.
- Preserve responsiveness.
- Support accessibility by default.
- Follow touch target requirements.
- Never sacrifice usability for visual effects.

# 11. AI Design Rules

## Purpose

These rules ensure that every AI assistant working on College Companion produces UI that remains consistent with the application's design language.

These rules apply to all AI systems used during development, including ChatGPT, Claude, Gemini, Qwen, Kimi, Codex, and future AI coding assistants.

Every generated UI should feel like it belongs to the same application.

---

## Primary Objective

When implementing UI, preserve consistency before introducing creativity.

The goal is to build College Companion—not redesign it.

---

## General Rules

Always:

- Follow this DESIGN.md.
- Follow the project's Design Tokens.
- Reuse Shared Components whenever possible.
- Respect the existing navigation structure.
- Keep the interface simple.
- Prioritize usability over visual experimentation.
- Follow Android design conventions.
- Build reusable widgets.
- Keep UI and business logic separate.

---

## Do Not

Never:

- Redesign existing screens.
- Change the Bottom Navigation structure.
- Introduce a different visual language.
- Create one-off widgets when reusable components exist.
- Hardcode colors, spacing, typography, or radius.
- Add decorative UI elements without purpose.
- Copy iOS interaction patterns.
- Introduce unnecessary animations.
- Overcomplicate layouts.

If a requested change conflicts with this document, preserve the existing design unless explicitly instructed otherwise.

---

## Before Implementing UI

Before modifying any screen:

1. Understand the screen's purpose.
2. Review existing shared components.
3. Follow the established information hierarchy.
4. Reuse existing patterns whenever possible.
5. Keep the implementation consistent with surrounding screens.

Do not begin implementation by redesigning the interface.

---

## Component Usage

Before creating a new widget, determine whether an existing shared component already solves the problem.

Examples:

- Use `CCCard` instead of creating another card.
- Use `CCSectionHeader` instead of custom headers.
- Use `CCStatCard` for summary metrics.
- Use `CCChip` for filters.
- Use `CCEmptyState` for empty screens.

Only introduce a new shared component when a reusable pattern appears multiple times.

---

## Layout Rules

When building screens:

- Maintain consistent spacing.
- Maintain consistent typography.
- Keep sections visually balanced.
- Avoid unnecessary nesting.
- Avoid deeply nested widget trees.

Prefer readability over clever layouts.

---

## Information Hierarchy

Always present information in the following order:

1. Critical
2. Important
3. Supporting
4. Optional

Do not allow decorative elements to compete with important information.

---

## Accessibility

Every UI implementation should support:

- Large text
- Screen readers
- High contrast
- One-handed usage
- Minimum touch targets

Accessibility should never be treated as an optional enhancement.

---

## Motion

Animations should:

- Explain state changes.
- Improve understanding.
- Remain subtle.

Avoid decorative motion.

Performance is always more important than animation.

---

## Code Quality

Generated UI code should:

- Follow Flutter best practices.
- Remain readable.
- Be modular.
- Avoid duplication.
- Reuse existing widgets.
- Keep widgets focused on presentation.

Business logic belongs outside the UI layer.

---

## Validation Checklist

Before considering a UI implementation complete, verify:

- The layout matches the design specification.
- Shared components were reused.
- Design tokens were used.
- Navigation remains unchanged.
- Accessibility requirements are satisfied.
- No unnecessary widgets were introduced.
- The implementation remains consistent with other screens.

---

## Design Changes

If a UI improvement is identified:

Do not implement it immediately.

Instead:

1. Explain the proposed improvement.
2. Describe its benefits.
3. Explain any trade-offs.
4. Wait for approval.
5. Update DESIGN.md if the change becomes permanent.

This document remains the single source of truth for all future UI implementations.

---

## Final Rule

College Companion values consistency over novelty.

A simple interface implemented consistently is better than a visually impressive interface that behaves differently across screens.

Every AI assistant should contribute to a single, unified user experience rather than introducing its own design preferences.