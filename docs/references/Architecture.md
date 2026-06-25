# Architecture Reference

## Purpose

This document summarizes the architectural principles used by College Companion.

It is a quick reference, not a project specification.

---

# Architecture Style

- Feature-first architecture
- Clean separation of concerns
- Repository Pattern
- Offline-first
- Local-first
- Modular

---

# Folder Philosophy

Each feature owns:

- UI
- Models
- Repository
- Services
- Providers
- Widgets

Shared functionality belongs inside `core`.

---

# Data Flow

User Action

↓

Repository

↓

SQLite (Drift)

↓

Riverpod Updates UI

↓

Background Sync

↓

Supabase

---

# Principles

- Single Responsibility Principle
- Separation of Concerns
- Composition over Inheritance
- Reusability
- Predictability

---

# Forbidden

- Business logic inside Widgets
- Direct database access from UI
- Duplicate components
- Tight coupling

---

# Goal

Architecture should make future features easier—not more complicated.