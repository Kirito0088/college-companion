# [DEBT]: Shared Axis Page Transitions & Staggered Motion Tuning

- **Issue:** #115
- **Labels:** `type:tech-debt`, `milestone:5-ux-polish`, `layer:ui-ux`, `priority:p2-normal`

## 1. Context & Motivation
Elevate UI polish using Material Design 3 shared axis page transitions and respect device reduced-motion accessibility flags.

## 2. Tracer-Bullet Architecture Scope
- Configure `CustomTransitionPage` with `SharedAxisTransition` in `app_router.dart`.
- Ensure low-end Android devices maintain 60fps frame rate.

## 3. Acceptance Criteria
- [ ] **Given** navigation between list and detail views,
  - **When** route pushes,
  - **Then** transition smoothly along the horizontal/vertical shared axis.

## 4. Verification
- [ ] `flutter test test/widget/app_theme_test.dart` passes.
