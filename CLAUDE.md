# CLAUDE.md

# College Companion

Persistent engineering guide for Claude Code.

This file defines permanent project rules that apply in every coding session.

Detailed architecture, implementation plans, and feature documentation belong in `/docs`.

---

# Project Vision

College Companion is a production-quality Android application for Mumbai University engineering students.

The application must be:

- Offline-first
- Local-first
- Fast
- Reliable
- Maintainable
- Production-ready

Build a polished product, not a prototype.

---

# Core Philosophy

Engineering decisions prioritize:

1. Reliability
2. Simplicity
3. Maintainability
4. User Experience
5. Performance

Implementation speed never outweighs code quality.

---

# Architecture Guard

Never introduce new architectural layers unless explicitly requested.

Do not add:

- DAOs
- Managers
- Services
- Interfaces
- Generic abstractions
- Design patterns "for cleanliness"

Follow the existing architecture.

Consistency is more valuable than theoretical purity.

---

# Scope Discipline

Implement only the requested milestone.

Do not continue into future milestones.

Do not implement "helpful extras."

When the requested milestone is complete:

- Validate
- Produce the Execution Report
- Stop

If requirements are unclear:

- Investigate
- Ask
- Do not invent architecture.

---

# File Safety

Never delete project files unless explicitly instructed.

If a file appears incorrect:

- Stop
- Explain why
- Wait for approval

Prefer modifying existing files over deleting and recreating them.

---

# Git Safety

Never:

- Commit
- Amend commits
- Push
- Force-push
- Rebase
- Reset
- Delete branches

unless explicitly instructed by the user.

After each milestone:

- Validate
- Produce the Execution Report
- Present the Git diff

Wait for user approval before any Git operation.

---

# Technology Stack

Frontend

- Flutter (Material 3)
- Dart

State Management

- flutter_riverpod

Routing

- go_router

Database

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

# Application Architecture

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

Rules

- Never bypass Drift.
- UI never communicates directly with Supabase.
- Repositories own business logic.
- Widgets remain presentation-only.

---

# Offline-First Rules

- Every write occurs locally first.
- UI updates immediately.
- Background sync never blocks the UI.
- Drift is authoritative.
- Supabase exists for synchronization and backup.

---

# Repository Rules

Repositories are the only layer allowed to communicate directly with AppDatabase.

Repositories own:

- CRUD operations
- Transactions
- Stream queries
- Business rules
- Soft-delete filtering on all public read queries unless explicitly documented otherwise.

Repositories must not contain:

- UI logic
- Sync implementation
- Analytics
- Presentation logic

---

# Database Principles

- UUID primary keys
- Soft deletes
- Forward-only migrations
- Preserve user data
- Never recreate production tables
- Never remove migrations
- Keep SQLite aligned with PostgreSQL where practical

---

# Authentication

- Google Sign-In only
- No email/password authentication
- Firebase authenticates users
- Supabase verifies identity
- RLS remains enabled

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

Never use:

- Hardcoded colors
- Hardcoded spacing
- Hardcoded typography
- Glassmorphism
- Neon effects
- Nested cards

---

# Documentation

Consult documentation before architectural changes.

Priority

1. docs/10-rules.md
2. docs/00-project-vision.md
3. docs/backend/database.md
4. docs/backend/sync-engine.md

Update documentation whenever architecture changes.

Do not duplicate documentation inside CLAUDE.md.

---

# Framework Rules

Never guess framework APIs.

For Flutter, Drift, Riverpod, GoRouter and Supabase:

- Verify installed versions.
- Follow official documentation.
- Treat compiler errors as specifications.

---

# Validation

Every milestone must end with:

- dart format
- dart run build_runner build
- flutter analyze
- flutter test (when applicable)

Fix all relevant issues before continuing.

Warnings deserve investigation.

Do not dismiss warnings as false positives without identifying the exact source of the diagnostic.

---

# Engineering Workflow

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

Code Review

↓

Review Fixes (if required)

↓

Ready For Review

---

# Definition of Done

A milestone is complete only when:

- Implementation finished
- Formatting complete
- Validation passed
- Documentation updated (if required)
- Execution Report produced
- Code reviewed
- Ready for user approval

---

# Communication Style

Do not expose internal reasoning.

Provide concise progress updates.

Execution Reports must include:

- Objective
- Files Modified
- Key Decisions
- Validation Results
- Remaining Issues
- Ready For Review

---

# General Rules

- Do not redesign architecture unless requested.
- Prefer incremental changes.
- Keep commits focused on one milestone.
- Preserve naming consistency.
- Do not mix singular/plural conventions.
- Establish one proven implementation before repeating a pattern.
- Treat compiler errors as specifications.
- Separate facts from recommendations.
- Preserve consistency across the codebase.
- When implementing repeated patterns, establish one reviewed implementation before replicating it across the project.