# [SLICE]: Real-Time Sync HUD & Non-Intrusive Offline State Indicator

- **Issue:** #114
- **Labels:** `type:slice`, `milestone:5-ux-polish`, `layer:ui-ux`, `layer:sync-cloud`, `priority:p1-critical`

## 1. Student Context & Problem
Students need quiet reassurance that their local SQLite changes are safely queued and synchronizing smoothly without modal loading spinners blocking their work.

## 2. Tracer-Bullet Architecture Scope
- Build top HUD status indicator reacting to `syncServiceProvider` and `connectivityServiceProvider`.
- States: "All changes saved" (idle), "Syncing..." (in progress), "Offline — queued locally" (offline).

## 3. Acceptance Criteria
- [ ] **Given** network disconnected,
  - **When** student logs attendance or edits assignments,
  - **Then** status chip smoothly transitions to "Offline — queued locally".
- [ ] **Given** connection restored,
  - **When** sync queue clears,
  - **Then** show "All changes synced" for 3 seconds, then dismiss.

## 4. Verification
- [ ] `flutter test test/empirical/stream_reactivity_stress_test.dart` passes.
