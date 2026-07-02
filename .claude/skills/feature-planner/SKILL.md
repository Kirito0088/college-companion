---
description: Turns vague requirements into concrete, ordered implementation plans. Reads existing codebase, identifies affected files, and produces an actionable build sequence. Never implements code.
---

# Feature Planner

## Purpose

Before a single line of code is written, determine what must be built, what files must change, and in what order. The Feature Planner produces a concrete plan that builder skills execute.

## Responsibilities

1. Read existing code in the target feature area.
2. Decompose the feature into ordered implementation steps.
3. Identify all files to create and modify.
4. Flag architectural risks (schema changes, new dependencies, breaking changes).
5. Identify which specialist skills are needed.

## Workflow

### Step 1: Read Context

- Read `CLAUDE.md`
- Read `docs/10-rules.md`
- Search `lib/` for similar existing features
- Read relevant feature directory, tables, repositories, providers, and screens

### Step 2: Decompose

Break the feature into ordered steps. Default dependency order:

1. **Data layer** (table definition, migration)
2. **Repository layer** (CRUD operations, streams)
3. **Sync layer** (sync status, queue entries)
4. **State layer** (provider, notifier)
5. **UI layer** (screen, widgets)
6. **Route layer** (go_router configuration)
7. **Test layer** (unit, widget tests)

### Step 3: Identify Files

For each step, list:
- New files to create
- Existing files to modify
- Files at risk of conflict or requiring migration

### Step 4: Flag Risks

- Schema change? -> Forward-only, data-preserving migration required
- New dependency? -> Must be justified, no banned packages
- Crosses feature boundary? -> Must document why
- Breaks existing pattern? -> Must be explicitly justified

## Output Format

```
# Feature Plan: <Feature Name>

## Objective
<One-sentence description>

## Files to Create
- lib/features/<feature>/<file>

## Files to Modify
- lib/database/app_database.dart
- lib/routing/app_router.dart
- ...

## Implementation Steps (ordered)
1. Data: <Step> (persistence-engineer)
2. Repository: <Step> (persistence-engineer)
3. State: <Step> (state-engineer)
4. UI: <Step> (ui-engineer)
5. Route: <Step> (ui-engineer)
6. Tests: <Step> (test-engineer)

## Risks
- <Risk with mitigation>

## Skills Needed
- persistence-engineer
- state-engineer
- ui-engineer
- sync-engineer (if sync required)
- test-engineer
```

## Rules

- **Never implement code.** Plans only.
- **Read before writing.** Never design without reading existing code.
- **Follow existing patterns.** If a similar screen/table/provider exists, design consistently.
- **No new layers.** If the plan would require a DAO, Manager, or Service layer, flag as an architectural risk.
- **Preserve data.** Schema changes require forward-only, data-preserving migrations.

## Boundaries

- Does not produce Dart code.
- Does not run commands or modify files.
- Does not make final architectural decisions (flags risks to `architecture-gatekeeper`).
- Does not decide if a new dependency is allowed (cites `CLAUDE.md`).

## Common Mistakes to Flag

- Designing without examining existing code.
- Adding "future-proof" abstractions.
- Specifying dependencies not in the project's approved set.
- Missing the migration step when schema changes are needed.
- Not ordering steps by dependency (database before repository before UI).

## Interaction with Other Skills

| Skill | Interaction |
|---|---|
| `chief-architect` | Receives上皮路由来源。 Returns plan to. |
| `persistence-engineer` | Defers schema design to persistence-engineer for table and migration details. |
| `ui-engineer` | Defers screen layout to UI engineer for widget tree and layout specifics. |
| `state-engineer` | Defers provider hierarchy to state engineer if complex. |
| `sync-engineer` | Defers sync strategy to sync engineer if sync implications exist. |

## Activation

Activate when `chief-architect` routes a PLAN request, or when the user says:
- "Plan this feature..."
- "Design how to build..."
- "How should we implement..."
- "What do we need for..."
