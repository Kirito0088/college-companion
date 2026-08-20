# Handoff Report — Milestone 1 Exploration (R1, R2, R3)

## 1. Observation

### R1. Onboarding — Fix 'Start' Button Label
- **File**: `lib/features/onboarding/screens/onboarding_screen.dart`
- **Lines**: 156–171 (specifically line 168)
- **Verbatim Code**:
  ```dart
  156: : FilledButton(
  157:     key: const ValueKey('start'),
  158:     onPressed: _finishOnboarding,
  159:     style: FilledButton.styleFrom(
  160:       backgroundColor: ColorTokens.primary,
  161:       foregroundColor: ColorTokens.onPrimary,
  162:       padding: const EdgeInsets.symmetric(
  163:         horizontal: SpacingTokens.xl,
  164:         vertical: SpacingTokens.md,
  165:       ),
  166:     ),
  167:     child: const Text(
  168:       'Start',
  169:       style: TextStyle(fontWeight: FontWeight.bold),
  170:     ),
  171:   ),
  ```
- **Observed State**: On the final page of onboarding (`_ReadyPage`), the `FilledButton` displays `'Start'`. Functionality (`_finishOnboarding`) is already fully functional and correctly sets onboarding status via Riverpod `onboardingCompletedProvider` before navigating to Home.

### R2. Calendar Event Details Screen
- **Files**:
  - `lib/features/calendar/screens/event_details_screen.dart` (lines 10–194)
  - `lib/routing/app_router.dart` (lines 89, 129, 389–393)
  - `lib/features/calendar/screens/calendar_screen.dart` (line 234)
  - `lib/features/calendar/providers/calendar_provider.dart` (lines 12–23)
  - `lib/features/calendar/repositories/calendar_repository.dart` (lines 32, 142)
- **Observed State**:
  1. `EventDetailsScreen` is a parameterless `StatelessWidget` displaying 100% hardcoded strings (`'Midterm Physics'`, `'Exam'`, `'Physics 101'`, `'May 14, 2025'`, `'10:00 AM - 12:00 PM'`, `'Room 304, Science Building'`, `'Covers chapters 4 through 7...'`).
  2. `app_router.dart` registers route `RoutePaths.eventDetails` as `/calendar/event-details` without a path parameter `:id`.
  3. `calendar_screen.dart` line 234 calls `context.push(RoutePaths.eventDetails)` without passing an event ID.
  4. Delete button on `EventDetailsScreen` (lines 163–174) shows a `CCDialogs.showDeleteConfirmation` dialog and calls `context.pop()` on confirmation without invoking `CalendarRepository.delete(userId, eventId)`.
  5. `CalendarRepository` already has `watchById(userId, id)` (line 32) and `delete(userId, id)` (line 142) implemented and tested with SQLite soft-deletion (`deletedAt`) and sync queue tracking (`DELETE` operation).

### R3. Assignment Details Screen
- **Files**:
  - `lib/features/assignments/screens/assignment_details_screen.dart` (lines 9–403)
  - `lib/routing/app_router.dart` (lines 87, 127, 377–381)
  - `lib/features/assignments/screens/assignments_screen.dart` (line 386)
  - `lib/features/assignments/providers/assignments_provider.dart` (lines 12–31)
  - `lib/features/assignments/repositories/assignments_repository.dart` (lines 123, 189, 209)
  - `lib/features/assignments/widgets/add_assignment_dialog.dart` (lines 16–284)
- **Observed State**:
  1. `AssignmentDetailsScreen` is a parameterless `StatelessWidget` displaying hardcoded content (`'Operating Systems Assignment 3'`, `'Pending'`, `'High Priority'`, `'Aug 1, 2026'`, etc.).
  2. Action buttons have `// TODO` placeholders:
     - Mark Complete button (line 332): `// TODO: Mark Complete`
     - Edit button (line 352): `// TODO: Edit`
     - Delete button (lines 372–383): calls `CCDialogs.showDeleteConfirmation` and pops without calling database delete.
  3. `app_router.dart` registers `RoutePaths.assignmentDetails` as `/assignment-details` without a path parameter `:id`.
  4. `assignments_screen.dart` line 386 calls `context.push(RoutePaths.assignmentDetails)` without an assignment ID.
  5. `AssignmentRepository` has `watchById(userId, id)` (line 123), `markCompleted(userId, id)` (line 189), `update(userId, id, data)` (line 168), and `delete(userId, id)` (line 209) implemented and fully tested.

---

## 2. Logic Chain

1. **R1 Analysis**:
   - Observation: Text on line 168 of `onboarding_screen.dart` is `'Start'`. Requirements specify changing it to `'Get Started'` or `'Continue to App'`.
   - Deduction: Changing line 168 from `'Start'` to `'Get Started'` completes R1 safely. No logic or state changes are required.

2. **R2 Analysis**:
   - Observation: Event details are hardcoded because `EventDetailsScreen` does not accept an `eventId` parameter, nor does the router capture `:id`.
   - Deduction: To load real data, the router route must be parameterized (`/calendar/event-details/:id`), `calendar_screen.dart` must pass `event.id` during `context.push`, and `EventDetailsScreen` must be converted to a `ConsumerWidget`/`ConsumerStatefulWidget` that watches `CalendarRepository.watchById(userId, eventId)`.
   - Deduction (Deletion): Delete action currently omits database calls. By invoking `ref.read(calendarRepositoryProvider).delete(userId, eventId)` after `CCDialogs.showDeleteConfirmation` returns `true`, the event will be soft-deleted in SQLite and filtered out reactively from stream providers.

3. **R3 Analysis**:
   - Observation: Assignment details screen contains static values and 3 `// TODO` callbacks for CRUD actions.
   - Deduction: The route must accept `:id` (`/assignment-details/:id`). `AssignmentDetailsScreen` should watch `AssignmentRepository.watchById(userId, assignmentId)`.
   - Deduction (Mark Complete): Calling `ref.read(assignmentRepositoryProvider).markCompleted(userId, assignmentId)` updates the SQLite record `status` to `'completed'` and sets `completedAt`, causing reactive UI updates.
   - Deduction (Edit): `AddAssignmentDialog` can accept an optional `assignment` parameter to pre-fill fields and execute `AssignmentRepository.update(userId, assignmentId, companion)` on save.
   - Deduction (Delete): Calling `ref.read(assignmentRepositoryProvider).delete(userId, assignmentId)` soft-deletes the record in SQLite, followed by `context.pop()`.

---

## 3. Caveats

- Explorer agent operates in read-only mode for application codebase (`lib/`). No changes to `lib/` files were made by this agent.
- `Location` field on `EventDetailsScreen` is not an explicit column in the `calendar_events` table; `AddEditEventScreen` encodes location inside the `description` string (`'Location: $locText\nNotes: ...'`). Parsing or displaying `description` handles notes and location cleanly.
- Attachments section on `AssignmentDetailsScreen` is a mockup for local file storage; the underlying `assignments` table schema stores `description`, `dueDate`, `status`, `subjectId`, etc., but does not have a separate attachments table.

---

## 4. Conclusion

All three Milestone 1 requirements (R1, R2, R3) are straightforward to implement and well-supported by existing backend infrastructure (`CalendarRepository`, `AssignmentRepository`, `CCDialogs`, Riverpod providers, Drift SQLite).

### Recommended Implementation Steps:

1. **R1**: Change line 168 of `lib/features/onboarding/screens/onboarding_screen.dart` from `'Start'` to `'Get Started'`.
2. **R2**:
   - Update `app_router.dart`: `RoutePaths.eventDetails` to `'/calendar/event-details/:id'`, builder passes `state.pathParameters['id']` to `EventDetailsScreen`.
   - Update `calendar_screen.dart` line 234: `context.push('/calendar/event-details/${event.id}')`.
   - Create `calendarEventStreamProvider` in `calendar_provider.dart` using `repo.watchById(userId, eventId)`.
   - Convert `EventDetailsScreen` to `ConsumerWidget`/`ConsumerStatefulWidget`, take `eventId`, watch provider, bind fields, and execute `delete(userId, eventId)` inside the confirmation dialog handler.
3. **R3**:
   - Update `app_router.dart`: `RoutePaths.assignmentDetails` to `'/assignment-details/:id'`, builder passes `state.pathParameters['id']` to `AssignmentDetailsScreen`.
   - Update `assignments_screen.dart` line 386: `context.push('/assignment-details/${entity.id}')`.
   - Create `singleAssignmentStreamProvider` in `assignments_provider.dart` using `repo.watchById(userId, assignmentId)`.
   - Convert `AssignmentDetailsScreen` to `ConsumerWidget`, take `assignmentId`, watch provider, bind fields.
   - Implement Mark Complete via `markCompleted(userId, assignmentId)`.
   - Implement Edit via `AddAssignmentDialog.show(context, initialAssignment: assignment)`.
   - Implement Delete via `delete(userId, assignmentId)` with M3 confirmation dialog.

---

## 5. Verification Method

To verify after implementation:

1. **Static Analysis & Build**:
   ```pwsh
   dart analyze lib
   ```
   *Expected Output*: 0 errors.

2. **Automated Test Suite**:
   ```pwsh
   flutter test
   ```
   *Expected Output*: All unit and widget tests pass.

3. **Manual / Widget Verification Steps**:
   - Launch onboarding flow -> scroll to final page -> verify button text reads `"Get Started"`.
   - In Calendar tab -> tap an event -> verify title, date, event type match database record -> tap Delete -> confirm M3 dialog -> verify event disappears from calendar list.
   - In Assignments tab -> tap an assignment -> verify real title and status load -> tap "Mark Complete" -> verify status updates to Completed -> tap "Delete" -> confirm -> verify assignment disappears from list.
