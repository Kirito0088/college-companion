# CLAUDE.md

> **College Companion v1.0**
>
> **Status:** Active Project Instructions
>
> This document defines the permanent engineering rules, architectural
> principles, and implementation constraints for College Companion.
> Treat this file as the primary implementation guide after consulting
> the project roadmap and feature specifications.

------------------------------------------------------------------------

# Project Mission

College Companion is an **offline-first academic companion** for
engineering students.

The objective is **not** to build the largest feature set. The objective
is to build a polished, reliable, fast, and maintainable application
that students can confidently use throughout their academic journey.

------------------------------------------------------------------------

# Source of Truth Priority

When implementing features, consult documents in this order:

1.  ROADMAP.md
2.  Locked Feature Specification (if available)
3.  DESIGN.md
4.  Development Workflow v2.0
5.  This file
6.  Existing codebase

If a feature specification exists, do **not** invent or change
behaviour.

------------------------------------------------------------------------

# Product Principles

Every implementation must follow these principles:

-   Offline-first
-   Local-first
-   Student-first
-   Production quality over speed
-   Material Design 3
-   Consistency over novelty
-   Minimal cognitive load
-   Accessibility by default

Every feature should solve a real student problem.

------------------------------------------------------------------------

# Architecture Principles

## Local Database

-   Drift is the local source of truth.
-   UI reads from local repositories.
-   Never couple UI directly to Supabase.

## Cloud

-   Supabase exists for:
    -   Authentication
    -   Synchronization
    -   Backup
    -   Verification

Cloud should enhance the experience, never replace local functionality.

------------------------------------------------------------------------

# UI Principles

Every new screen must:

-   Match the existing design language.
-   Use design tokens exclusively.
-   Preserve existing navigation unless explicitly instructed.
-   Make additive changes whenever possible.
-   Avoid unnecessary redesigns.

Always ask:

-   Does this fit College Companion?
-   Does it reduce friction?
-   Does it improve student workflow?

Never create generic application UI.

------------------------------------------------------------------------

# Feature Specifications

When a feature has a locked specification:

-   Follow it exactly.
-   Do not reinterpret requirements.
-   Do not introduce additional behaviour without approval.

Current locked specifications include:

-   Lecture Record
-   Roadmap milestones

Future specifications should be added here.

------------------------------------------------------------------------

# Coding Standards

Prefer:

-   Small focused widgets
-   Feature-first architecture
-   Clear naming
-   Reusable components
-   Composition over duplication

Avoid:

-   Magic numbers
-   Hardcoded colors
-   Hardcoded spacing
-   Premature abstraction
-   Unrelated refactors

------------------------------------------------------------------------

# Backend Principles

Repositories own business logic.

UI should remain presentation-focused.

Synchronization must never block local usage.

Authentication must remain Google Sign-In only unless the roadmap
changes.

------------------------------------------------------------------------

# Quality Gates

No implementation is complete until:

-   Code formatted
-   flutter analyze passes
-   Relevant tests pass
-   Physical device validation completed (UI)
-   Documentation updated (if needed)

------------------------------------------------------------------------

# Git Policy

Each milestone should end with:

-   git status review
-   Clean commit
-   Push to GitHub
-   Tag significant milestones

Keep commits focused on a single milestone.

------------------------------------------------------------------------

# Documentation Policy

Whenever architecture or product behaviour changes:

Update the relevant documentation before considering the milestone
complete.

Documentation is part of the implementation.

------------------------------------------------------------------------

# AI Collaboration

## Antigravity 2.0

Responsible for:

-   Flutter UI
-   UX
-   Material 3
-   Motion
-   Accessibility
-   Device QA

## Claude Code

Responsible for:

-   Drift
-   Supabase
-   Repositories
-   Business logic
-   Synchronization
-   Performance
-   Security

## ChatGPT

Responsible for:

-   Architecture
-   Planning
-   Specifications
-   Technical review
-   Roadmap
-   Prompt engineering

------------------------------------------------------------------------

# Stop Rules

Do not:

-   Implement future roadmap items.
-   Redesign unrelated screens.
-   Remove existing functionality without approval.
-   Change architecture without discussion.

Complete only the requested milestone, then stop and report.

------------------------------------------------------------------------

# Definition of Success

A successful implementation:

-   Solves the intended student problem.
-   Matches the roadmap.
-   Matches the feature specification.
-   Matches the design language.
-   Preserves architectural consistency.
-   Is maintainable.
-   Is production-ready.

------------------------------------------------------------------------

# Final Principle

> Build deliberately.

Every feature should feel like it belongs to one cohesive product.
Prefer long-term maintainability, consistency, and student value over
short-term convenience or unnecessary complexity.
