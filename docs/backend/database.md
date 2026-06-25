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

## attendance

Stores:

* Subject
* Date
* Status
* Lecture Type
* Proof Image
* Notes

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

Attendance

↓

Assignments

↓

Internal Marks

Timetable references Subjects.

Attendance references Subjects.

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

Every table should support:

* Insert
* Update
* Delete
* Sync Status

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
