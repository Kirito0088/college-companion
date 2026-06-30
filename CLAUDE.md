# CLAUDE.md

# College Companion

Persistent engineering guide for Claude Code.

This file defines the project's engineering principles, architecture, workflow, and coding standards.

Detailed documentation belongs in `/docs`. This file contains only information that should be loaded in every coding session.

---

# Project Vision

College Companion is a production-quality Android application built specifically for Mumbai University engineering students.

The application is designed to be:

- Offline-first
- Local-first
- Fast
- Reliable
- Maintainable
- Production-ready

The goal is to build a polished product, not a prototype or demo.

---

# Core Philosophy

Engineering decisions should prioritize:

1. Reliability
2. Simplicity
3. Maintainability
4. User Experience
5. Performance

Implementation speed is never more important than code quality.

---

# Non-Goals

These features are intentionally excluded from the MVP.

- AI Assistant
- Placement Tracker

Do not implement them unless explicitly requested.

---

# Technology Stack

Frontend

- Flutter (Material 3)
- Dart

State Management

- flutter_riverpod

Routing

- go_router

Local Database

- Drift (SQLite)

Backend

- Supabase

Authentication

- Firebase Google Sign-In
- Supabase Third-Party Auth

Platform

- Android only
- Portrait only
- Dark mode only

---

# Architecture

The application is Local-First.

Source of Truth

UI

↓

Repositories

↓

Drift (SQLite)

↓

Background Sync

↓

Supabase

Never bypass Drift.

The UI must never communicate directly with Supabase.

Repositories own business logic.

Widgets never contain business logic.

---

# Offline-First Rules

- Every write occurs locally first.
- UI updates immediately.
- Sync happens in the background.
- Sync failures never block the UI.
- Drift is always authoritative.
- Supabase exists for synchronization and backup.

---

# Database Principles

- UUID primary keys
- Soft deletes
- Forward-only migrations
- Preserve user data
- Never recreate production tables
- Never remove migrations
- Keep SQLite schema aligned with PostgreSQL where practical

---

# Authentication

- Google Sign-In only
- No email/password authentication
- Firebase authenticates users
- Supabase verifies identity for database access
- RLS must remain enabled

---

# Project Structure

Feature-first architecture.

lib/

- core/
- database/
- features/
- routing/
- services/
- shared/
- theme/

Business logic belongs in repositories and services.

Widgets remain presentation-only.

---

# UI Rules

- Material Design 3
- Material Symbols Rounded
- Dark mode only
- Portrait only
- Design tokens only
- No hardcoded colors
- No hardcoded spacing
- No hardcoded typography
- No glassmorphism
- No neon effects
- No nested cards

---

# Documentation

Always consult documentation before making architectural changes.

Priority

1. docs/10-rules.md
2. docs/00-project-vision.md
3. docs/backend/database.md
4. docs/backend/sync-engine.md
5. Remaining documentation

When architecture changes, update the relevant documentation.

Do not duplicate documentation in this file.

---

# Engineering Workflow

Every task follows this sequence.

Plan

↓

Review

↓

Build

↓

Validate

↓

Execution Report

↓

Review

↓

Commit

Never skip validation.

---

# Framework Rules

Never guess framework APIs.

For Drift, Riverpod, GoRouter, Supabase, and Flutter:

- Verify the installed version.
- Follow official documentation.
- Do not rely on memory.
- The compiler is the specification.

---

# Validation

Before considering a milestone complete:

- dart format
- dart run build_runner build
- flutter analyze
- flutter test (when applicable)

Fix all relevant errors before continuing.

Never continue development on a broken build.

---

# Definition of Done

A milestone is complete only when:

- Implementation finished
- Formatting complete
- Validation passes
- Documentation updated (if required)
- Execution Report produced
- Changes reviewed
- Ready to commit

---

# Communication Style

Do not expose internal reasoning.

Provide concise progress updates.

At the end of every milestone produce an Execution Report containing:

- Objective
- Files Modified
- Key Decisions
- Validation Results
- Remaining Issues
- Ready For Review

---

# General Rules

- Do not redesign architecture unless explicitly requested.
- Do not create unnecessary abstractions.
- Prefer incremental changes.
- Keep commits focused on a single milestone.
- Treat compiler errors as specifications.
- Separate Facts from Recommendations.
- When uncertain, investigate before editing.
- Preserve consistency across the codebase.

---

# Remember

The objective is not to generate code.

The objective is to engineer a production-quality application.