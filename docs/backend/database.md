# backend/database.md

> Version: 1.0
> Status: Active

---

# Purpose

This document defines the database architecture of College Companion.

The database should be:

* Secure
* Scalable
* Offline-first
* Relational
* Easy to maintain

---

# Database Philosophy

SQLite (Drift) is the source of truth.

Supabase exists for synchronization.

Every write operation follows this flow:

User Action

↓

SQLite

↓

UI Update

↓

Sync Queue

↓

Supabase

---

# Cloud Database

Provider

Supabase

Database

PostgreSQL

---

# Authentication

Supabase Auth

Google Sign-In only.

Every record belongs to exactly one authenticated user.

---

# Core Tables

## users

Stores:

* User ID
* Name
* Email
* Profile Photo
* Created At

---

## semesters

Stores:

* Semester Name
* Working Days
* Current Semester
* Archived Status

---

## subjects

Stores:

* Subject Name
* Faculty
* Type
* Semester ID

---

## timetable

Stores:

* Day
* Start Time
* End Time
* Subject
* Room
* Lecture Type

---

## lecture_records

The immutable lecture attendance ledger (Phase 4). Exactly one record
per timetable lecture (1:1 `UNIQUE` on `timetable_id`). Records are
**permanent** — there is no soft delete and no `update()`/`delete()` in
the repository; SQLite `BEFORE UPDATE`/`BEFORE DELETE` triggers are the
runtime backstop (business columns frozen, sync-bookkeeping columns
writable).

This table **replaces** the legacy `attendance` table.

Stores:

* Timetable ID (1:1 link, unique)
* Subject ID, Semester ID (denormalized for per-semester export/verify)
* User ID (RLS filter)
* `status_text` — encoded `primary|secondary|other_text` (spec §5)
* Note (optional, immutable — spec §7)
* Recorded At (UTC instant — spec §11)
* Device Timezone, App Version (spec §11 metadata)
* Standard sync-metadata block (see Sync Entity Convention below)

---

## lecture_evidence

**Local-only — never synced** (spec §8/§16). One-to-one with
`lecture_records` (`ON DELETE CASCADE`). Stores **relative** file paths
(resolved against the app documents directory at runtime) plus integrity
metadata (`sha256`, `state`) re-verified on open/export. Carries no
sync-metadata columns and has no cloud counterpart.

---

## assignments

Stores:

* Title
* Description
* Due Date
* Subject
* Status

---

## internal_marks

Stores:

* Subject
* Exam Name
* Marks Obtained
* Maximum Marks

---

## settings

Stores:

* Notifications
* Enabled Modules
* Theme
* User Preferences

---

# Relationships

User

↓

Semester

↓

Subjects

↓

Assignments

↓

Internal Marks

Timetable references Subjects.

Lecture Records reference Timetable (1:1) and Subjects.

Lecture Evidence references Lecture Records (1:1, local-only).

Calendar Events reference Subjects (optional).

Assignments reference Subjects.

---

# IDs

Every table should use UUIDs.

Never expose sequential IDs.

---

# Timestamps

Every table should include:

Created At

Updated At

Deleted At (optional)

---

# Soft Delete

Prefer soft delete whenever practical.

Archive instead of permanently deleting.

---

# Sync

Every **syncable business table** carries a standard sync-metadata block
(the Syncable Entity Convention, Phase 4 §2):

* `createdAt` / `updatedAt` (UTC; `updatedAt` touched on every local change)
* `deletedAt` (nullable — soft delete; **omitted** on `lecture_records`
  and `user_settings`, which are justified exceptions)
* `syncStatus` (`pending` | `synced` | `failed`, default `pending`)
* `syncVersion` (bumped on each local change; conflict-detection input)
* `createdOffline` (boolean, default true — offline-first origin)
* `lastSyncedAt` (nullable — last successful push timestamp, spec §11)

Justified exceptions (no sync block, or partial): `lecture_evidence`
(local-only, never synced), `sync_queue_items` and `sync_metadata`
(internal local-only tracking), `users` (download-only projection —
`UserRepository` upserts directly, never through the queue; keeps
`createdAt`/`updatedAt` only).

Every table should support:

* Insert
* Update
* Delete
* Sync Status

> **Migration note:** the v2 schema foundation is a fresh `createAll`
> baseline (no production data exists, per Phase 4 §A1). The legacy
> `attendance` table was dropped and replaced by `lecture_records`;
> cloud-side this is migration `00003`.

---

# Indexing

Index:

* User ID
* Semester ID
* Subject ID
* Date
* Status

Avoid unnecessary indexes.

---

# Migration

Database migrations must preserve existing data.

Never break older databases.

---

# Backup

Cloud synchronization acts as backup.

No manual backup system is required.

---

# Offline

The application must remain fully usable without internet.

No feature should depend on constant connectivity.

---

# Final Rule

The database exists to support the product.

It should never complicate development.

---

# Revision History

## v1.0

Initial database architecture.
