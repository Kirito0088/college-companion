Part of #2

## 1. Student Context & Design Brief
The current UI identity suffers from stereotypical AI "vibecoding" (heavy purple gradients `#9C6AFF`, deep purple containers `#2D1F5E`, neon glows, and dark glassmorphic cards). This aesthetic feels generic and fails to convey the focused, authentic, utilitarian clarity of a world-class academic operating system.

We are overhauling the visual identity using the `/frontend-design` methodology to give College Companion a distinctive, intentional, non-templated look grounded in real student workflows.

## 2. Aesthetic Direction & Design Principles
- **Grounding in Subject:** Precision academic tool meets modern editorial utility. Clean, high-legibility surfaces, crisp hierarchy, and calm confidence.
- **Palette Overhaul (`lib/theme/color_tokens.dart`):**
  - Kill the generic purple neon gradient scheme.
  - Adopt an intentional, sophisticated palette (deep slate / crisp obsidian foundation `#0D0F12` with warm graphite containers `#16191E`, crisp high-contrast off-white typography `#F0F2F5`, and purposeful semantic accents: vivid electric cobalt `#3B82F6` for primary actions, emerald `#10B981` for safe attendance, and coral `#EF4444` for attendance alerts).
- **Typography & Rhythm (`lib/theme/typography_tokens.dart`):**
  - Purposeful typographic hierarchy with deliberate weights and letter-spacing.
  - Clear distinction between metadata/labels and actionable data.
- **Structural Integrity:**
  - Replace diffuse glowing shadows with crisp, micro-borders (`outlineVariant`) and deliberate elevation tokens.
  - Restraint: Spend boldness in one memorable signature element (e.g. the attendance gauge & quick action hub) while keeping surrounding cards quiet and disciplined.

## 3. Tracer-Bullet Architecture Scope
- **Design Tokens Layer:**
  - Update `lib/theme/color_tokens.dart` with new curated color palette tokens.
  - Update `lib/theme/typography_tokens.dart`, `lib/theme/spacing_tokens.dart`, and `lib/theme/radius_tokens.dart`.
  - Update `lib/theme/app_theme.dart` with matching ThemeData (Dark theme first, light theme parity).
- **Component Layer:**
  - Update shared widgets in `lib/shared/` (`CcButton`, `CcCard`, `CcEmptyState`, `CcErrorState`, `CcLoading`).
- **Core Screens Pass:**
  - Apply new tokens to `DashboardScreen`, `AttendanceScreen`, `CalendarScreen`, `AssignmentsScreen`, `ProfileScreen`, and `LoginScreen`.

## 4. Acceptance Criteria (Given / When / Then)
- [ ] **Given** app opens on any screen, **When** rendered, **Then** zero clichéd purple neon gradients or generic AI glassmorphic glows are visible.
- [ ] **Given** student views Dashboard and Attendance screens, **When** evaluating visual hierarchy, **Then** typography and contrast ratios meet WCAG AA (>= 4.5:1 for body, >= 3:1 for large text).
- [ ] **Given** all 15 screens, **When** rendered with new tokens, **Then** all widgets consume `lib/theme/` tokens without hardcoded colors.

## 5. Verification & Quality Gates
- [ ] `dart analyze` reports 0 errors, 0 warnings.
- [ ] `flutter test` reports 100% pass rate across all tests.
- [ ] Visual verification on `Automated_Device` (`emulator-5554`).
