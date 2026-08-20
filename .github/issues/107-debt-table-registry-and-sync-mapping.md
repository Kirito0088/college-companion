# [DEBT]: Synchronize Table Registry & SyncService Table Payload Mappings

- **Issue:** #107
- **Labels:** `type:tech-debt`, `milestone:2-lecture-ledger`, `layer:drift-db`, `layer:sync-cloud`, `priority:p1-critical`

## 1. Context & Motivation
`table_registry.dart` only lists 11 of the 15 Drift tables. `SyncService._fetchRowPayload` lacks cases for `lecture_records` and `notifications`, preventing lecture ledger mutations from replicating to Supabase.

## 2. Tracer-Bullet Architecture Scope
- Update `lib/database/tables/table_registry.dart` to include all 15 tables.
- Update `SyncService._fetchRowPayload` to handle `'lecture_records'` and `'notifications'`.

## 3. Acceptance Criteria
- [ ] **Given** mutation enqueued for `lecture_records`,
  - **When** `SyncService.syncPendingMutations()` runs,
  - **Then** successfully extract snake_case row payload and upsert to Supabase PostgreSQL table.

## 4. Verification
- [ ] `flutter test test/unit/services/sync_service_test.dart` passes.
