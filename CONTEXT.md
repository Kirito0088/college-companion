# College Companion — Living System Context

> **Status:** Active Source of Living Context (Matt Pocock Paradigm)  
> **Version:** 1.0.0  
> **Architecture:** Offline-First Mobile (Flutter / Drift SQLite / Riverpod / Supabase)  

---

## 1. Core Axioms & Product Tenets

1. **Offline-First & Local-First**: Drift SQLite is the local source of truth. UI reads strictly from local SQLite stream providers. Writes go to SQLite first, then enqueue to the FIFO `sync_queue`.
2. **Cloud Replication**: Supabase PostgreSQL exists for backup, multi-device synchronization, and semester verification. Cloud synchronization never blocks the local UI.
3. **Student-First Product Design**:
   - Reassurance, calm confidence, actionable empathy.
   - Eliminate cognitive load: synthesize data into clear status (e.g. "Safe to bunk 2 classes" rather than raw percentages).
   - Quiet confidence: neutral errors, no panic alerts or aggressive notifications.
4. **Material Design 3 (M3)**: Dark-first, purple accent (`#6750A4`), 8pt grid, Material Symbols Rounded icons only (`material_symbols_icons`), Inter typography (`google_fonts`).

---

## 2. Tech Stack & Invariant Conventions

| Layer | Technology | Key Patterns & Conventions |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart 3.x) | Portrait-only (`DeviceOrientation.portraitUp`), Android API 31–35. |
| **State** | Riverpod 2.x | Sealed union states (`AuthState`), dynamic stream providers (`assignmentsStreamProvider`, `safeBunkStreamProvider`, `dashboardSnapshotProvider`). |
| **Local Database** | Drift SQLite (`AppDatabase`) | Schema v2, 15 tables, 4 DAOs (`LectureRecordDao`, `LectureEvidenceDao`, `SyncQueueDao`, `SyncMetadataDao`). |
| **Cloud Sync** | Supabase Flutter | Native Google Sign-In with ID token exchange (`signInWithIdToken`), RLS policies, FIFO exponential backoff sync engine (`SyncService`). |
| **Navigation** | GoRouter 15.x | Declarative routes, bottom navigation via `StatefulShellRoute.indexedStack`, synchronous auth state redirect guards. |
| **Design Tokens** | `lib/theme/` | `ColorTokens`, `TypographyTokens`, `SpacingTokens`, `RadiusTokens`, `MotionTokens`. Zero hardcoded colors or spacing. |

---

## 3. Critical Domain Invariants

- **Lecture Records**: Exactly 1:1 with a timetable lecture. An immutable academic ledger. After submission, status, timestamp, notes, and metadata are permanently locked (enforced via SQLite triggers and repository API contracts).
- **Lecture Evidence**: Tamper-proof camera photo. Maximum 1 photo per lecture, captured via camera only (gallery prohibited). **Stored locally only — NEVER synced to the cloud**. SHA-256 hash verified on open and export.
- **Sync Pipeline**: `UI Action -> Local Drift Write -> SyncQueue Insert -> Background SyncService -> Supabase PostgreSQL Upsert`.
- **Semester Export**: Pre-flight requires Google authenticated session, clean sync queue (0 pending items), and cryptographic ledger parity check between local Drift and Supabase PostgreSQL.

---

## 4. The 6 Milestone Epics (Matt Pocock Backlog)

1. **Milestone 1: Core Feature Completeness & Real Data Wiring** (Issues #101–#104: Timetable Screen, Dynamic Subjects/Resources, SQLite Profile).
2. **Milestone 2: Tamper-Proof Lecture Ledger & Camera Pipeline** (Issues #105–#107: Immutable Ledger UI, Camera Hashing, Table Registry Sync).
3. **Milestone 3: Background Notifications & Academic Reminders** (Issues #108–#109: Local Notification Scheduler, Channel Settings).
4. **Milestone 4: Verified Semester Export & Canonical PDF** (Issues #110–#112: Cloud Parity Verification, PDF Generator, Share Flow).
5. **Milestone 5: Production UX Polish & Accessibility** (Issues #113–#115: 48dp Touch Targets, 2.0x Font Scaling, Realtime Sync HUD).
6. **Milestone 6: Hardening, Automated E2E QA & Release v1.0.0** (Issues #116–#118: Emulator E2E Suite, ProGuard AAB, Release Tag).

---

## 5. Development & Quality Gate Protocol

Every task is executed as an atomic **Tracer-Bullet Vertical Slice** via GitHub Issues:
1. **Red**: Write failing unit/widget/integration tests in `test/` based on issue acceptance criteria.
2. **Green**: Implement minimal vertical slice (UI $\rightarrow$ Provider $\rightarrow$ Repo $\rightarrow$ Drift/Supabase).
3. **Refactor**: Clean up M3 tokens, ensure accessibility touch targets ($\ge 48\times 48\text{ dp}$), format code.
4. **Verification Gate**:
   - `dart analyze` $\rightarrow$ 0 errors, 0 warnings.
   - `flutter test` $\rightarrow$ 100% passing.
   - Automated virtual device check on `Automated_Device` (`emulator-5554`).
