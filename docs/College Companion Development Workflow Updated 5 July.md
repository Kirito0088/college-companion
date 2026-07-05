# College Companion Development Workflow v2.0

> **Status:** Locked Workflow\
> **Version:** 2.0\
> **Purpose:** This document defines the official engineering workflow
> for College Companion. Every implementation must follow this workflow
> unless an explicit architectural decision changes it.

------------------------------------------------------------------------

# 1. Core Philosophy

The project follows these principles:

-   Offline-first
-   Local-first
-   Production quality over development speed
-   Incremental milestones
-   Stable architecture
-   Design consistency
-   Student-first product thinking

Every feature should solve a real student problem before adding
technical complexity.

------------------------------------------------------------------------

# 2. Source of Truth

Before implementing any feature, consult the following documents (in
order):

1.  ROADMAP.md
2.  DESIGN.md
3.  Feature Specification (if available)
4.  CLAUDE.md
5.  Project source code

If a Feature Specification exists, it overrides assumptions.

Never invent behavior already defined by a specification.

------------------------------------------------------------------------

# 3. Parallel Development Strategy

## Google Antigravity 2.0 (Gemini 3.1 Pro High)

Primary ownership:

-   Flutter UI
-   Material 3
-   Animations
-   UX
-   Accessibility
-   Design token compliance
-   ADB device testing
-   UI polish

------------------------------------------------------------------------

## Claude Code

Primary ownership:

-   Drift
-   Repositories
-   Business logic
-   Database
-   Offline sync
-   Supabase
-   Authentication
-   Security
-   Performance

Preferred models:

-   GLM 5.2
-   DeepSeek V4 Pro
-   Claude Opus 4 (when available)

------------------------------------------------------------------------

## ChatGPT

Primary ownership:

-   Product architecture
-   Roadmap
-   Feature specifications
-   Technical planning
-   Prompt engineering
-   Design reviews
-   Cross-review of AI output

------------------------------------------------------------------------

# 4. Product Thinking Rules

Before implementing any screen or feature, ask:

-   Why does this exist?
-   What student problem does it solve?
-   Can the workflow require fewer taps?
-   Does it reduce cognitive load?
-   Does it match the purpose of College Companion?
-   Does it remain consistent with the design system?

Never create generic UI.

Always tailor UX specifically for College Companion.

------------------------------------------------------------------------

# 5. UI Development Workflow (Antigravity 2.0)

## Step 1 --- Audit

-   Read only relevant files.
-   Understand existing implementation.
-   Preserve architecture.

## Step 2 --- Research

Use:

-   Context7 for framework documentation.
-   Material Design MCP for Material 3 guidance.
-   21st.dev for inspiration only.

Never copy designs.

## Step 3 --- Planning

Create an implementation plan before coding.

List:

-   files affected
-   architecture impact
-   assumptions
-   risks

## Step 4 --- Implementation

Rules:

-   Preserve design hierarchy.
-   Use design tokens.
-   No hardcoded colors or spacing.
-   No redesigns unless explicitly requested.
-   Make additive changes whenever possible.

## Step 5 --- Validation

Run:

-   dart format
-   flutter analyze
-   flutter run

Deploy to the connected Android device.

## Step 6 --- Device QA

Use ADB to:

-   launch app
-   navigate modified screens
-   capture screenshots
-   verify interactions

Check for:

-   overflow
-   clipping
-   spacing
-   typography
-   animations
-   responsiveness
-   accessibility
-   Material 3 consistency

The user should not need to manually provide screenshots.

## Step 7 --- UX Review

Review the implementation as a Senior Product Designer.

Suggest improvements where appropriate.

Implement only approved improvements.

## Step 8 --- Report

Produce:

-   files changed
-   validation results
-   screenshots captured
-   UX observations
-   remaining issues
-   recommended git commit message

Stop after reporting.

------------------------------------------------------------------------

# 6. Backend Development Workflow (Claude Code)

## Step 1 --- Audit

Understand:

-   architecture
-   repositories
-   data flow
-   related modules

Read only relevant files.

## Step 2 --- Research

Use Context7 whenever APIs or libraries may have changed.

Consult official documentation before implementing.

## Step 3 --- Planning

Prepare an implementation plan covering:

-   schema changes
-   repository updates
-   migrations
-   risks
-   testing strategy

## Step 4 --- Implementation

Keep changes:

-   localized
-   maintainable
-   architecture-consistent

Avoid speculative abstractions.

## Step 5 --- Validation

Run:

-   dart format
-   dart run build_runner build (when applicable)
-   flutter analyze
-   flutter test (when applicable)

Validate migrations before continuing.

## Step 6 --- Quality Review

Use:

-   CodeRabbit for maintainability
-   Security Guidance for auth, storage, networking and sync
-   Serena for repository navigation and semantic refactoring

## Step 7 --- Report

Produce:

-   files modified
-   migration summary
-   validation results
-   risks
-   follow-up recommendations
-   suggested git commit

Stop after reporting.

------------------------------------------------------------------------

# 7. MCP Usage Policy

## Context7

Use for:

-   Flutter
-   Dart
-   Drift
-   Riverpod
-   GoRouter
-   Supabase
-   Package documentation

## 21st.dev

Use only for:

-   UI inspiration
-   Interaction ideas

Never replicate designs.

## Material Design MCP

Use for:

-   Material 3
-   Motion
-   Accessibility
-   Components

## Playwright

Use when applicable for automated UI validation.

ADB remains the primary validation method for Android.

## Supabase MCP

Use for:

-   schema
-   SQL
-   RLS
-   auth
-   storage
-   backend configuration

## Serena

Use for:

-   semantic search
-   repository navigation
-   large codebase understanding

## Security Guidance

Mandatory for:

-   authentication
-   networking
-   storage
-   synchronization
-   secrets

## CodeRabbit

Run before considering backend milestones complete.

------------------------------------------------------------------------

# 8. Git Workflow

After completing a milestone:

1.  git status
2.  Review changes
3.  Commit
4.  Push
5.  Tag major milestones
6.  Begin next milestone

Never mix unrelated work in one commit.

------------------------------------------------------------------------

# 9. Documentation Rules

Whenever architecture changes:

Update:

-   ROADMAP.md
-   CLAUDE.md
-   Feature Specifications
-   DESIGN.md (if required)

Documentation is part of the implementation.

------------------------------------------------------------------------

# 10. Prompt Standards

Every implementation prompt should encourage:

-   step-by-step reasoning
-   architecture preservation
-   reading only relevant files
-   validation
-   stopping after the requested milestone
-   producing a final report

------------------------------------------------------------------------

# 11. Stop Conditions

Stop immediately after the requested milestone.

Do NOT:

-   redesign unrelated screens
-   refactor unrelated code
-   implement future roadmap items
-   modify architecture without approval
-   remove existing functionality unless requested

------------------------------------------------------------------------

# 12. Definition of Done

A milestone is complete only when all are satisfied:

## Engineering

-   Builds successfully
-   Passes flutter analyze
-   Tests pass (where applicable)

## Product

-   Solves the intended student problem
-   Matches feature specification
-   Fits College Companion's purpose

## UX

-   Consistent with DESIGN.md
-   Material 3 compliant
-   Accessible
-   Polished
-   Reviewed on a physical Android device

## Documentation

Relevant documents updated if required.

## Git

Ready for commit and push.

------------------------------------------------------------------------

# Final Principle

Build deliberately.

Every completed milestone should be production-ready enough that it
could ship if the remaining milestones did not exist.
