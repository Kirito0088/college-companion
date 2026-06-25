# backend/sync-engine.md

> Version: 1.0
> Status: Active

---

# Purpose

This document defines how College Companion synchronizes data between the local database and Supabase.

The synchronization process should be automatic, reliable and invisible to the user.

---

# Sync Philosophy

SQLite (Drift) is the source of truth.

Supabase is the cloud backup and synchronization service.

The application should remain fully usable without internet.

---

# Sync Flow

Every write operation follows this sequence:

```text
User Action
      ↓
Write to SQLite
      ↓
Update UI Immediately
      ↓
Mark Record as Pending Sync
      ↓
Check Internet Connection
      ↓
Upload to Supabase
      ↓
Mark as Synced
```

The user should never wait for cloud synchronization.

---

# Sync Triggers

Synchronization should occur:

* After every successful data change (when online)
* On app launch
* When internet connection is restored
* When the user manually refreshes
* At periodic intervals while the app is open

---

# Sync Direction

Two-way synchronization.

### Upload

Local changes → Supabase

### Download

Supabase changes → SQLite

---

# Conflict Resolution

If the same record changes on multiple devices:

**Latest Updated Timestamp Wins**

Future versions may support manual conflict resolution if required.

---

# Sync Queue

Every local change is added to a sync queue.

Each queue item contains:

* Record ID
* Table Name
* Operation (Insert / Update / Delete)
* Timestamp
* Sync Status

---

# Sync Status

Each record should have one of the following states:

* Pending
* Syncing
* Synced
* Failed

---

# Retry Strategy

If synchronization fails:

1. Keep the local data.
2. Retry automatically.
3. Do not interrupt the user.

Never discard unsynced data.

---

# Offline Mode

When offline:

* Continue working normally.
* Save every change locally.
* Queue all sync operations.

When internet returns:

* Resume synchronization automatically.

---

# Deletion

Deleting a record:

1. Mark locally.
2. Queue delete operation.
3. Delete from cloud after successful sync.

Prefer soft delete where practical.

---

# Images

Attendance proof images follow the same process.

```text
Capture Photo
      ↓
Save Locally
      ↓
Queue Upload
      ↓
Upload to Supabase Storage
      ↓
Store Cloud URL
```

If upload fails, retry automatically.

---

# Sync Indicators

The UI should remain clean.

Only show sync status when useful.

Examples:

* "Syncing..."
* "All changes saved"
* "Offline — changes will sync automatically"

Avoid showing technical details.

---

# Error Handling

Temporary sync failures should not block the user.

Display friendly messages only when necessary.

Example:

"You're offline. Your changes are safe and will sync automatically."

---

# Performance

Batch sync operations where possible.

Avoid unnecessary API requests.

Only sync modified records.

---

# Security

Every sync request must:

* Be authenticated
* Respect Row Level Security
* Validate ownership

Never sync another user's data.

---

# Manual Sync

A manual **Sync Now** option may be provided in Settings.

This should:

* Retry pending operations
* Refresh cloud data

---

# Final Rule

Synchronization should feel invisible.

The user should never have to think about whether their data has been saved.

---

# Revision History

## v1.0

Initial synchronization engine specification.
