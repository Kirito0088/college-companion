# Comprehensive Analysis: Core Screens & Provider Architecture

**Target Project**: `c:\Projects\college_companion`  
**Branch**: `main`  
**Inspector**: Explorer 2  
**Date**: 2026-07-24  

---

## Executive Summary

An in-depth investigation of the core application screens and state management architecture was conducted. The application entry point initializes Riverpod via `ProviderScope(child: CollegeCompanionApp())` in `lib/main.dart`, and global repositories/services are exposed in `lib/providers/app_providers.dart` as well as feature-level provider files. 

However, **all 6 core screens (`CalendarScreen`, `AssignmentsScreen`, `ResourcesScreen`, `SettingsScreen`, `DashboardScreen`, and `AttendanceScreen`) are currently legacy `StatefulWidget`s containing hardcoded mock data, static lists, local UI state variables, or simulated timers.** 

To transition the application to a dynamic, reactive architecture while maintaining visual fidelity, each screen must be converted to `ConsumerWidget` or `ConsumerStatefulWidget`, and connected to stateful Riverpod providers (e.g. `StreamProvider`, `StateNotifierProvider`, or `NotifierProvider`) backed by Drift database repositories. All Material Design 3 styling, color tokens, font styles, and layout structures must be strictly preserved during this conversion.

---

## 1. Riverpod Architecture & Provider Setup

### 1.1 Root Setup (`main.dart` & `app.dart`)
- **`lib/main.dart`**: Wraps `CollegeCompanionApp` in Riverpod's `ProviderScope`:
  ```dart
  runApp(const ProviderScope(child: CollegeCompanionApp()));
  ```
- **`lib/app.dart`**: Declared as a `ConsumerStatefulWidget`. It initializes `syncServiceProvider` (`ref.read(syncServiceProvider)`), listens manually to `authStateProvider` to trigger router updates, and passes `ref` to `createRouter(ref, refreshListenable: ...)`.

### 1.2 Global Providers (`lib/providers/app_providers.dart`)
- `databaseProvider`: `Provider<AppDatabase>` (closes database on dispose).
- `connectivityServiceProvider`: `Provider<ConnectivityService>`.
- `supabaseClientProvider`: `Provider<SupabaseClient>`.
- `syncQueueRepositoryProvider`: `Provider<SyncQueueRepository>`.
- `userSettingsRepositoryProvider`: `Provider<UserSettingsRepository>`.
- `syncServiceProvider`: `Provider<SyncService>`.

### 1.3 Feature Repository Providers (`lib/features/*/providers/`)
- `calendarRepositoryProvider`: `Provider<CalendarRepository>` (`features/calendar/providers/calendar_provider.dart`)
- `assignmentRepositoryProvider`: `Provider<AssignmentRepository>` (`features/assignments/providers/assignments_provider.dart`)
- `resourcesRepositoryProvider`: `Provider<ResourcesRepository>` (`features/resources/providers/resources_provider.dart`)
- `attendanceRepositoryProvider`: `Provider<AttendanceRepository>` (`features/attendance/providers/attendance_provider.dart`)
- `dashboardSnapshotProvider`: `Provider<DashboardSnapshot>` (`features/dashboard/providers/dashboard_provider.dart`) — currently returns static `DashboardSnapshot.mockHeavyDay()`.

### 1.4 Architecture Gap Summary
While repositories and database tables (`calendar_events`, `assignments`, `resources`, `attendance`, `user_settings`) are defined with full Drift CRUD methods and sync queue triggers, **the 6 core screens do not consume these repository providers**. The screens rely on local state variables (e.g. `_selectedDate`, `_selectedFilterIndex`, `_selectedCategory`, `_uiState`) and in-memory mock models.

---

## 2. Detailed Screen-by-Screen Inspection

---

### 2.1 `CalendarScreen` (`lib/features/calendar/screens/calendar_screen.dart`)

#### Mock Data & Hardcoded Values
1. **Mock Models & Imports**: Uses `MockEvent` (`features/calendar/models/mock_event.dart`) and `MockUiState` (`shared/models/mock_ui_state.dart`).
2. **Hardcoded State**:
   - `int _selectedDate = 13;` (hardcoded day number for today).
   - `MockUiState _uiState = MockUiState.success;`.
3. **Hardcoded Events List (`_allEvents`)**:
   - `Midterm Physics` (exam, 2025-05-14, 10:00 AM - 12:00 PM, Physics 101, Room 304).
   - `Lab Report Due` (assignment, 2025-05-14, 11:59 PM, Physics 101).
   - `Team Meeting` (academic, 2025-05-16, 2:00 PM - 3:00 PM).
   - `CS Guest Lecture` (academic, 2025-05-20, 4:00 PM, Computer Science).
   - `Database Project` (assignment, 2025-05-20, 11:59 PM, DBMS).
   - `Dentist Appointment` (personal, 2025-05-28, 9:00 AM).
4. **Hardcoded Month Filter**: Filter getter `_events` hardcodes `event.date.month == 5 && event.date.year == 2025`.
5. **Static UI Text & Actions**:
   - Header text: `'May 2025'` with empty month picker `onTap: () {}`.
   - Navigation arrows (`chevron_left`, `chevron_right`) have empty `onPressed: () {}`.
   - Today button resets `_selectedDate = 13;`.

#### Current Riverpod Status
- Extends `StatefulWidget`. **No Riverpod integration**.

#### Widget Structure & Material 3 Styling (Must Preserve)
- **Root**: `Scaffold` (`backgroundColor: theme.colorScheme.surface`) -> `SafeArea` -> `Column`.
- **Header (`_buildHeader`)**:
  - Screen title: `Text('Calendar', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: ColorTokens.onSurface))`
  - Month dropdown trigger: `InkWell` (radius `RadiusTokens.borderRadiusSm`) containing `Text('May 2025', style: theme.textTheme.titleMedium?.copyWith(color: ColorTokens.primary, fontWeight: FontWeight.w600))` and dropdown icon `Icon(Symbols.arrow_drop_down, color: ColorTokens.primary)`.
  - Icon buttons: Today (`Symbols.today`, `ColorTokens.onSurfaceVariant`), Previous Month (`Symbols.chevron_left`), Next Month (`Symbols.chevron_right`).
- **Body**: `Expanded` -> `SingleChildScrollView` (padding: `LayoutTokens.screenPadding`, top: `SpacingTokens.md`, bottom: `SpacingTokens.huge`).
  - `CalendarMonthView`: Renders 7-column grid of date cells. Highlighted today/selected cell uses `ColorTokens.primary` circle and `ColorTokens.onPrimary` text. Event dots use `event.type.color`.
  - `SizedBox(height: SpacingTokens.xxl)`
  - Agenda Header: Row with `Text('Agenda', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: ColorTokens.onSurface, letterSpacing: 0.5))` and count label `Text('X events', style: theme.textTheme.labelMedium?.copyWith(color: ColorTokens.onSurfaceVariant))`.
  - Agenda List: `AnimatedSwitcher` containing `AgendaCard` items (or `EmptyCalendar()`, `SkeletonList()`, `NetworkErrorWidget()`).
- **FAB**: `FloatingActionButton` (`backgroundColor: ColorTokens.primary`, `foregroundColor: ColorTokens.onPrimary`, elevation 2, `Icon(Symbols.add)`, pushes `RoutePaths.addEditEvent`).

---

### 2.2 `AssignmentsScreen` (`lib/features/assignments/screens/assignments_screen.dart`)

#### Mock Data & Hardcoded Values
1. **Hardcoded State**:
   - `_selectedFilterIndex = 0` (All).
   - `MockUiState _uiState = MockUiState.success`.
   - `_isFabExtended = true` (scroll listener toggling extension).
2. **Hardcoded Filter Chips**:
   - `_filters = ['All', 'Pending', 'Due Today', 'Overdue', 'Completed']`.
   - Index 3 (`Overdue`) explicitly returns `EmptyAssignments()`.
3. **Hardcoded Overview Card**:
   - Linear progress value: `0.75`.
   - Stat percentage text: `'75%'`.
   - Stat count text: `'8 of 12 done'`.
4. **Hardcoded Assignment Items (`_buildAssignmentList`)**:
   - Item 1: Title `'Operating Systems Assignment 3'`, subject `'Operating Systems'`, subjectColor `Colors.blue`, dueDate `'Tomorrow'`, status `'Pending'`, statusColor `ColorTokens.warning`, priority `'High Priority'`.
   - Item 2: Title `'Database Lab Report'`, subject `'DBMS'`, subjectColor `Colors.green`, dueDate `'Aug 5'`, status `'Due Today'`, statusColor `ColorTokens.primary`.
   - Item 3: Title `'WT Mini Project'`, subject `'Web Technology'`, subjectColor `Colors.amber`, dueDate `'Completed'`, status `'Completed'`, statusColor `ColorTokens.success`.
5. **Search Input**: `TextField` hint `'Search assignments...'` without text controller/search filter query logic.

#### Current Riverpod Status
- Extends `StatefulWidget`. **No Riverpod integration**.

#### Widget Structure & Material 3 Styling (Must Preserve)
- **Root**: `Scaffold` (`backgroundColor: theme.colorScheme.surface`) -> `SafeArea` -> `Stack`.
- **Header (`_buildHeader`)**:
  - Title: `Text('Assignments', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: ColorTokens.onSurface))`.
  - Subtitle: `Text('Track all assignments across your subjects.', style: theme.textTheme.bodyLarge?.copyWith(color: ColorTokens.onSurfaceVariant))`.
- **Content Scroll Area**: `SingleChildScrollView` (`controller: _scrollController`, padding: `LayoutTokens.screenPadding` horizontal, `SpacingTokens.md` vertical).
  - Search Field: `TextField` (`fillColor: ColorTokens.surfaceContainerHigh`, `OutlineInputBorder` with `RadiusTokens.borderRadiusLg`, `Symbols.search`).
  - Filter Chips: Horizontal `SingleChildScrollView` of `FilterChip` (`backgroundColor: ColorTokens.surfaceContainer`, `selectedColor: ColorTokens.primaryContainer`, `labelStyle` matching `ColorTokens.onPrimaryContainer` / `onSurfaceVariant`, `shape: RoundedRectangleBorder(borderRadius: RadiusTokens.borderRadiusMd)`).
  - Overview Card (`_buildProgressSummaryCard`): `Container` (`color: ColorTokens.surfaceContainer`, `borderRadius: RadiusTokens.borderRadiusMd`, `border: Border.all(color: ColorTokens.surfaceVariant)`) containing `LinearProgressIndicator` (`value: 0.75`, `color: ColorTokens.primary`, `backgroundColor: ColorTokens.surfaceVariant`, minHeight 6) and percentage text (`ColorTokens.primary`, `FontWeight.w900`).
  - Assignment List: `TweenAnimationBuilder` list of `AssignmentCard` components.
- **FAB Overlay**: `Positioned` at bottom right (`AssignmentsFab(isExtended: _isFabExtended)`).

---

### 2.3 `ResourcesScreen` (`lib/features/resources/screens/resources_screen.dart`)

#### Mock Data & Hardcoded Values
1. **Architecture Note**: Comment in lines 13–20 notes offline-first architecture (Drift SQLite local indexing, local storage files, Supabase NOT used for binary assets).
2. **Hardcoded State**:
   - `MockUiState _uiState = MockUiState.success`.
   - `String _selectedCategory = 'All'`.
3. **Hardcoded Categories List**:
   - `_categories = ['All', 'Favorites', 'Lecture Notes', 'Lab Manuals', 'Question Papers', 'Books', 'Syllabus', 'Other']`.
   - Selecting any non-'All' category returns `EmptyResources()`.
4. **Hardcoded Recently Viewed Section**:
   - Card 1: Icon `Symbols.picture_as_pdf`, title `'Data Structures...'`, subject `'Computer Science'`, timeAgo `'2 hours ago'`, color `Colors.redAccent`.
   - Card 2: Icon `Symbols.description`, title `'Math Assignment'`, subject `'Mathematics'`, timeAgo `'Yesterday'`, color `Colors.blueAccent`.
5. **Hardcoded Main Resource Cards (`_buildResourcesList`)**:
   - Resource 1: Title `'Operating Systems Unit 3 Notes'`, subject `'Operating Systems'`, fileType `'PDF'`, fileSize `'2.4 MB'`, lastModified `'Yesterday'`, iconColor `Colors.redAccent`, `isFavorite: true`.
   - Resource 2: Title `'DBMS Lab Manual'`, subject `'Database Management'`, fileType `'PDF'`, fileSize `'5.1 MB'`, lastModified `'Monday'`, iconColor `Colors.redAccent`, `isFavorite: false`.
   - Resource 3: Title `'Question Paper 2025'`, subject `'Computer Networks'`, fileType `'PDF'`, fileSize `'1.2 MB'`, lastModified `'2 weeks ago'`, iconColor `Colors.blueAccent`, `isFavorite: true`.
6. **Search Bar**: `_buildSearchBar` is a visual container showing static text `'Search resources...'`.

#### Current Riverpod Status
- Extends `StatefulWidget`. **No Riverpod integration**.

#### Widget Structure & Material 3 Styling (Must Preserve)
- **Root**: `Scaffold` (`backgroundColor: theme.colorScheme.surface`) -> `SafeArea` -> `Column`.
- **Header (`_buildHeader`)**: Back `IconButton` (`backgroundColor: ColorTokens.surfaceContainer`, `RadiusTokens.borderRadiusMd`), Title `Text('Resources', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: ColorTokens.onSurface))`, Subtitle `Text('Manage all your study materials in one place.', style: theme.textTheme.bodyMedium?.copyWith(color: ColorTokens.onSurfaceVariant))`.
- **CustomScrollView**:
  - `SliverToBoxAdapter` containing Search Bar (`ColorTokens.surfaceContainer`, `RadiusTokens.borderRadiusXl`), Recently Viewed horizontal list (`Container` width 160, `ColorTokens.surfaceContainer`, `RadiusTokens.borderRadiusLg`), and Categories horizontal `FilterChip` list (`ColorTokens.surfaceContainer`, `ColorTokens.primaryContainer`, `showCheckmark: false`).
  - `_buildResourcesList` (`SliverPadding` -> `SliverList`): Items wrapped in `Material` (`color: ColorTokens.surfaceContainer`, `borderRadius: RadiusTokens.borderRadiusXl`, `InkWell` pushing `RoutePaths.resourceDetails`). Contains file icon box, title, subject, file metadata row (`fileType • fileSize • lastModified`), bookmark icon (`Symbols.bookmark` / `Symbols.bookmark_border`), and chevron.

---

### 2.4 `SettingsScreen` (`lib/features/settings/screens/settings_screen.dart`)

#### Mock Data & Hardcoded Values
1. **Hardcoded Switch State**:
   - `bool _pushNotifications = true;`
   - `bool _lectureReminders = true;`
2. **Hardcoded Strings & Version**:
   - App Version text: `'v1.0.0'`.
3. **Hardcoded Action Handlers**:
   - Clear Cache row triggers `CCDialogs.showDeleteConfirmation` dialog, but no underlying cache directory deletion or database purge service is invoked.
   - Settings rows have hardcoded route pushes or empty callbacks (`onTap ?? () {}`).

#### Current Riverpod Status
- Extends `StatefulWidget`. **No Riverpod integration** (does not read `userSettingsRepositoryProvider`).

#### Widget Structure & Material 3 Styling (Must Preserve)
- **Root**: `Scaffold` (`backgroundColor: theme.colorScheme.surface`).
- **AppBar**: `AppBar` (`backgroundColor: theme.colorScheme.surface`, `scrolledUnderElevation: 0`), centered title `Text('Settings', style: theme.textTheme.titleLarge?.copyWith(color: ColorTokens.onSurface, fontWeight: FontWeight.w600))`, leading back `IconButton(icon: Icon(Symbols.arrow_back), color: ColorTokens.onSurface)`.
- **Body**: `SingleChildScrollView` (padding: `LayoutTokens.screenPadding` horizontal, `SpacingTokens.md` vertical).
  - Categorized Sections (`_buildSection`): Section label `Text(title, style: theme.textTheme.labelLarge?.copyWith(color: ColorTokens.onSurfaceVariant, fontWeight: FontWeight.bold))` over a container (`color: ColorTokens.surfaceContainer`, `borderRadius: RadiusTokens.borderRadiusXl`, `border: Border.all(color: ColorTokens.outlineVariant.withValues(alpha: 0.2))`).
  - Sections:
    1. **Account**: `Account Information` (`Symbols.person`, pushes `RoutePaths.accountInformation`), `Privacy & Security` (`Symbols.lock`, pushes `RoutePaths.privacyPolicy`).
    2. **Notifications**: `Push Notifications` switch (`Symbols.notifications`), `Lecture Reminders` switch (`Symbols.schedule`). Uses custom `Switch` colors (`activeThumbColor: ColorTokens.surface`, `activeTrackColor: ColorTokens.primary`, `inactiveThumbColor: ColorTokens.outline`, `inactiveTrackColor: ColorTokens.surfaceContainerHighest`).
    3. **Study & Focus**: `Focus Mode` (`Symbols.timer`, pushes `RoutePaths.focusMode`).
    4. **Data & Sync**: `Sync Data` (`Symbols.sync`, pushes `RoutePaths.dataSync`), `Clear Cache` (`Symbols.delete`, error color `ColorTokens.error`, opens delete dialog).
    5. **About**: `App Version` (`Symbols.info`, trailing text `'v1.0.0'`), `Terms of Service` (`Symbols.description`), `Privacy Policy` (`Symbols.policy`).

---

### 2.5 `DashboardScreen` (`lib/features/dashboard/screens/dashboard_screen.dart`)

#### Mock Data & Hardcoded Values
1. **Hardcoded Screen State & Timers**:
   - `MockUiState _uiState = MockUiState.loading`.
   - `initState` delay timer `Future.delayed(const Duration(milliseconds: 600), ...)` setting state to `MockUiState.success` to trigger staggered entrance animations.
   - Retry delay timer `Future.delayed(const Duration(seconds: 1))` in network error fallback.
2. **Dashboard Provider Static Data**:
   - `dashboardSnapshotProvider` in `lib/features/dashboard/providers/dashboard_provider.dart` calls `DashboardSnapshot.mockHeavyDay()`.
   - Hardcoded values in `DashboardSnapshot.mockHeavyDay()`:
     - `greetingContext`: `'4 lectures today'`.
     - `nextAction`: HeroAction(`title: 'Statistics ML'`, `timeString: '09:00 AM'`, `location: 'Room 305'`, `urgencyString: 'Starts in 28m'`).
     - `timelineEvents` (4 events):
       1. Data Structures (Room 101, 08:00 AM, `isPast: true`).
       2. Statistics ML (Room 305, 09:00 AM, `isNow: true`).
       3. Artificial Intelligence (Room 302, 10:00 AM).
       4. DevOps (Lab 1, 12:00 PM).
     - `academicSnapshot`: AcademicSnapshot(`attendanceState: 'On Track'`, `workloadState: 'Heavy'`, `deadlinesState: '1 Due'`, `nextBreakState: 'In 2 hrs'`).

#### Current Riverpod Status
- `DashboardScreen` itself is a `StatefulWidget` (uses internal `AnimationController` and `_uiState`).
- **Child widgets ARE Riverpod-aware**: `WelcomeSection`, `NextLectureCard`, `TodayOverviewSection`, and `AcademicSnapshotSection` extend `ConsumerWidget` and watch `dashboardSnapshotProvider` and `authStateProvider`. However, the root snapshot data provider itself is un-dynamic (returns static mock constructor).

#### Widget Structure & Material 3 Styling (Must Preserve)
- **Root**: `DecoratedBox` with `RadialGradient` background (center `(0.0, -0.8)`, colors `[ColorTokens.primary.withValues(alpha: 0.06), Colors.transparent]`) -> `SafeArea` -> `_buildBody()`.
- **Content Scroll Area**: `SingleChildScrollView` (padding: `LayoutTokens.screenPadding` horizontal, `SpacingTokens.base` vertical).
  - `WelcomeSection`: Greeting `Text('${snapshot.greetingContext},\n$displayName.', style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500))` and circular notification button (`Symbols.notifications_rounded`, `ColorTokens.surfaceVariant`).
  - Hero Card (`FadeTransition` & `SlideTransition` wrapping `NextLectureCard`): `Material` with `LinearGradient` decoration from `ColorTokens.surfaceContainerHigh.withValues(alpha: 0.6)` to `ColorTokens.surfaceContainer`, border, `InkWell` to `RoutePaths.subjectDetails`. Next Action label, urgency string (`ColorTokens.primary`), title (`headlineSmall`), schedule icon & time, location icon & location.
  - Timeline Section (`FadeTransition` & `SlideTransition` wrapping `TodayOverviewSection`): Title "Today's Flow" + `Symbols.tune_rounded`, list of class timeline items with past events set to opacity `0.4`, time/meridiem column, card container with `isNow` highlight (`ColorTokens.primary` border alpha 0.2), subject title, room, "NOW" badge (`ColorTokens.success`), chevron icon.
  - Academic Snapshot Section (`FadeTransition` & `SlideTransition` wrapping `AcademicSnapshotSection`): Header "Academic Snapshot", container (`ColorTokens.surfaceContainerLow`, `RadiusTokens.borderRadiusLg`), 4 stat columns with icons (`Symbols.fact_check_rounded`, `Symbols.school_rounded`, `Symbols.assignment_rounded`, `Symbols.coffee_rounded`), status strings, and labels.

---

### 2.6 `AttendanceScreen` (`lib/features/attendance/screens/attendance_screen.dart`)

#### Mock Data & Hardcoded Values
1. **Hardcoded Tab Index**: `int _selectedIndex = 0;` (0 for Overview, 1 for Subjects).
2. **Overview Tab Mock Data**:
   - `OverallGauge`: Gauge painter progress `0.82`, display percentage `'82%'`, badge text `'You can miss 12 lectures'`.
   - `StatsRow`: Present `'148'` (`ColorTokens.success`), Absent `'32'` (`ColorTokens.error`), Total `'180'`.
   - `AttendanceTrendCard`: Hardcoded 7-point line chart (`Offset(0, 0.5)` to `Offset(1.0, 0.45)`), Y-axis labels (`100%`, `75%`, `50%`, `25%`, `0%`), X-axis labels (`Mon` - `Sun`).
   - `_buildHealthCard`: Health status `'Safe'` with message `'You can miss approximately 8 more lectures before reaching 75%.'` inside green container (`ColorTokens.success.withValues(alpha: 0.1)`).
   - `_buildInsightsCard`: Highest `'DBMS (96%)'`, Lowest `'CN (71%)'`, Below Target `'1 Subject'`, Average `'82%'`.
   - `_buildRequirementCard`: Min Required `'75%'`, Current `'82%'`, Status `'Eligible'`.
   - `_buildQuickActions`: 3 cards ('Attendance History', 'Attendance Calculator', 'Attendance Settings') with empty `onTap: () {}`.
3. **Subjects Tab Mock Data**:
   - Search bar placeholder: static container with `'Search subjects...'`.
   - Subject Card 1: `'Operating Systems'`, `'84%'`, 42/50 lectures, progress `0.84` (`ColorTokens.success`).
   - Subject Card 2: `'Database Management'`, `'96%'`, 48/50 lectures, progress `0.96` (`ColorTokens.success`).
   - Subject Card 3: `'Computer Networks'`, `'71%'`, 35/49 lectures, progress `0.71` (`ColorTokens.error`).

#### Current Riverpod Status
- Extends `StatefulWidget`. **No Riverpod integration** (does not read `attendanceRepositoryProvider`).

#### Widget Structure & Material 3 Styling (Must Preserve)
- **Root**: `Scaffold` (`backgroundColor: Theme.of(context).colorScheme.surface`) -> `SafeArea` -> `Column`.
- **Top Bar**: `AttendanceHeader()` (title "Attendance", calendar/action buttons).
- **Body**: `Expanded` -> `SingleChildScrollView` (padding: `LayoutTokens.screenPadding` horizontal, `SpacingTokens.md` top, `LayoutTokens.bottomNavigationHeight + SpacingTokens.xl` bottom).
  - `SegmentedControl`: Renders custom 2-tab pill slider for Overview vs Subjects.
  - `AnimatedSwitcher` -> `Column` displaying active tab content.
  - Overview Tab:
    - `OverallGauge`: `GestureDetector` pushing `RoutePaths.safeBunk`, `CustomPaint` with `_GaugePainter` (circle background `ColorTokens.surfaceContainer`, arc `ColorTokens.success`, strokeWidth 12), display text (`displayLarge`, `FontWeight.w700`, `letterSpacing: -2.0`), badge chip (`ColorTokens.success.withValues(alpha: 0.1)`).
    - `StatsRow`: 3 equal-width stat containers (`ColorTokens.surfaceContainer`, `RadiusTokens.borderRadius12`, border alpha 0.15) for Present, Absent, Total.
    - `AttendanceTrendCard`: `Container` (`ColorTokens.surfaceContainer`), week picker dropdown, 160-height stack with grid lines, Y-labels, X-labels, and `CustomPaint(_TrendChartPainter)`.
    - Health, Insights, Requirement, and Quick Action cards with rounded corners (`RadiusTokens.borderRadiusXl`, `RadiusTokens.borderRadiusLg`).
  - Subjects Tab:
    - Search field container (`ColorTokens.surfaceContainer`, `RadiusTokens.borderRadiusXl`), list of `_buildSubjectCard` items with name, percentage, `LinearProgressIndicator` (minHeight 6, progress color based on >= 75% threshold), present/total counts, and chevron.

---

## 3. Summary Table of Hardcoded Data & Preserved Material 3 Styling Tokens

| Screen | Hardcoded Mock Data / State | Key Material 3 Styling Tokens to Preserve |
| :--- | :--- | :--- |
| **`CalendarScreen`** | `_selectedDate = 13`, `_allEvents` list (6 events for May 2025), month dropdown string `'May 2025'`, empty nav button callbacks. | `theme.colorScheme.surface`, `ColorTokens.primary`, `ColorTokens.onPrimary`, `ColorTokens.onSurface`, `ColorTokens.onSurfaceVariant`, `RadiusTokens.borderRadiusSm`, `SpacingTokens.screenPadding`, FAB styling (`ColorTokens.primary`, `Symbols.add`). |
| **`AssignmentsScreen`** | `_selectedFilterIndex`, filter list (`All`, `Pending`, `Due Today`, `Overdue`, `Completed`), 75% overview progress card, 3 hardcoded assignment cards, empty text field search. | `ColorTokens.surfaceContainer`, `ColorTokens.surfaceContainerHigh`, `ColorTokens.primaryContainer`, `ColorTokens.onPrimaryContainer`, `ColorTokens.outlineVariant`, `FilterChip` styling, `LinearProgressIndicator` (minHeight 6), `AssignmentsFab`. |
| **`ResourcesScreen`** | `_selectedCategory`, category list (8 categories), 2 recently viewed cards, 3 resource cards (OS Notes, DBMS Manual, Question Paper 2025), static search bar. | `ColorTokens.surfaceContainer`, `RadiusTokens.borderRadiusXl`, `RadiusTokens.borderRadiusLg`, `RadiusTokens.borderRadiusMd`, `FilterChip` styling, `Material` card containers, `Symbols.picture_as_pdf`, bookmark icons. |
| **`SettingsScreen`** | `_pushNotifications`, `_lectureReminders` initial booleans, app version string `'v1.0.0'`, static settings rows, empty clear cache operation. | `AppBar` (`scrolledUnderElevation: 0`), `ColorTokens.surfaceContainer`, `RadiusTokens.borderRadiusXl`, `Switch` track/thumb colors (`ColorTokens.primary`, `ColorTokens.surface`, `ColorTokens.outline`), section label text styles. |
| **`DashboardScreen`** | `_uiState` loading timer (600ms delay), retry timer (1s delay), `DashboardSnapshot.mockHeavyDay()` (4 lectures, Statistics ML hero, 4 timeline events, macro states). | `RadialGradient` background, `ColorTokens.surfaceContainerHigh`, `ColorTokens.surfaceContainer`, `ColorTokens.surfaceContainerLow`, `FadeTransition` + `SlideTransition` entrance animations, `headlineSmall`, `titleLarge`. |
| **`AttendanceScreen`** | `_selectedIndex`, overall gauge (82%, miss 12), stats (148/32/180), trend points (Mon-Sun), health card text, insights (DBMS 96%, CN 71%), 3 subject cards (OS 84%, DBMS 96%, CN 71%). | `_GaugePainter` custom arc, `LinearProgressIndicator` threshold colors (`ColorTokens.success` >=75% vs `ColorTokens.error`), `SegmentedControl` tab slider, `RadiusTokens.borderRadiusXl`, `RadiusTokens.borderRadius12`. |

---

## 4. Migration Plan for Consumer Widgets

When converting these 6 screens from legacy `StatefulWidget`s to `ConsumerWidget`/`ConsumerStatefulWidget`:

1. **Keep Visual Code Intact**: Retain all layout padding (`LayoutTokens.screenPadding`, `SpacingTokens`), decoration containers, theme references (`Theme.of(context)`), and Material 3 design tokens (`ColorTokens`, `RadiusTokens`).
2. **Inject Riverpod Providers**:
   - Replace static lists with reactive state providers (e.g., watching `calendarRepositoryProvider.watchAll(userId)`, `assignmentRepositoryProvider.watchAll(userId)`, `resourcesRepositoryProvider.watchAll(userId)`, `attendanceRepositoryProvider.watchAll(userId)`, `userSettingsRepositoryProvider.watch(userId)`).
   - Use `ref.watch()` for reactive UI updates and `ref.read()` for user actions/mutations.
3. **Preserve Interactive Polish**: Retain animations (`AnimatedSwitcher`, `TweenAnimationBuilder`, `FadeTransition`, `SlideTransition`), custom painters (`_GaugePainter`, `_TrendChartPainter`), and scroll controller mechanics (`AssignmentsFab` extension).

---

## 5. Verification Method

- **Static Verification**: Run `dart analyze` to ensure clean compilation without unused imports or type errors.
- **Visual Verification**: Run Flutter app on emulator or target device, verifying that UI layouts, Material 3 colors, cards, chips, typography, and animations render identically before and after Riverpod state binding.
