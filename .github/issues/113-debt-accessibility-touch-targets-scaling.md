# [DEBT]: Universal Touch Targets, TalkBack Semantics & Dynamic Font Scaling

- **Issue:** #113
- **Labels:** `type:tech-debt`, `milestone:5-ux-polish`, `layer:ui-ux`, `priority:p1-critical`

## 1. Context & Motivation
Ensure full compliance with Material Design 3 and Android accessibility requirements across all 15 screens.

## 2. Tracer-Bullet Architecture Scope
- Audit all interactive components to guarantee minimum 48x48 dp touch bounds.
- Wrap icon-only action buttons in `Semantics(label: ...)`.
- Verify dynamic font scaling up to 2.0x without clipping or `RenderFlex` overflows.

## 3. Acceptance Criteria
- [ ] **Given** Android system text scale set to 2.0x,
  - **When** navigating Dashboard, Attendance, Timetable, and Settings,
  - **Then** all widgets reflow without layout overflow errors.

## 4. Verification
- [ ] `flutter test test/widget/core_screens_widget_test.dart` passes.
