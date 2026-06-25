# Supabase Reference

## Purpose

Quick reference for backend development.

---

# Services Used

- PostgreSQL
- Authentication
- Row Level Security
- Storage

---

# Authentication

Google Sign-In only.

Persist sessions.

---

# Database

PostgreSQL

Every table:

- UUID primary key
- created_at
- updated_at

---

# Security

Enable RLS on every table.

Never bypass policies.

---

# Storage

Store:

- Attendance proof images

Every uploaded file belongs to one authenticated user.

---

# Sync

SQLite

↓

Supabase

SQLite is always the source of truth.

---

# Rules

Never expose Service Role Keys.

Never disable RLS.

Never trust client-side validation.

---

# Goal

Provide secure cloud synchronization while keeping the application offline-first.