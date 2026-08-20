# [SLICE]: Dynamic Resource Details Screen & Local Storage File Handler

- **Issue:** #103
- **Labels:** `type:slice`, `milestone:1-core-features`, `layer:ui-ux`, `layer:drift-db`, `priority:p1-critical`

## 1. Student Context & Problem
`ResourceDetailsScreen` hardcodes "Operating Systems Unit 3 Notes" and has non-functional context menus. Students cannot view real subject notes or open downloaded files.

## 2. Tracer-Bullet Architecture Scope
- **UI Layer:** Refactor `ResourceDetailsScreen` to accept `required String resourceId`, displaying real file name, extension badge, size in KB/MB, and local storage status.
- **Data Layer:** Connect to `ResourcesRepository.getById(resourceId)` and integrate native Android file viewer intent.
- **Routing:** Update `RoutePaths.resourceDetails` to `/resource-details/:id` in `app_router.dart`.

## 3. Acceptance Criteria (Given / When / Then)
- [ ] **Scenario 1 (Dynamic Metadata):**
  - **Given** user taps a PDF resource in `ResourcesScreen`,
  - **When** screen opens,
  - **Then** display file title, file size, relative path, and associated subject.
- [ ] **Scenario 2 (Open Local File):**
  - **Given** user taps "Open File" and file exists at relative local path,
  - **When** tapped,
  - **Then** launch native Android file viewer.

## 4. Verification & Quality Gates
- [ ] `flutter test test/features/resource_details_screen_test.dart` passes.
