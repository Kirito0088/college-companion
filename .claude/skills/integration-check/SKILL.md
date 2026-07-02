---
description: Runs the validation pipeline including formatting, code generation, static analysis, and tests. Reports failures clearly. Does not fix code.
---

# Integration Check

## Purpose

Runs the project's validation pipeline and reports results. The final quality gate before code is considered tested.

## Workflow

### Step 1: Format Check
```bash
dart format --set-exit-if-changed .
```

### Step 2: Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Static Analysis
```bash
flutter analyze
```

### Step 4: Tests
```bash
flutter test
```

### Step 5: Report
- For each step: **Pass**, **Fail**, or **Warning**
- For failures: show full error output
- For warnings: show message and suggest investigation

## Rules

- **Run all steps.** Even if one fails, report on all to give a complete picture.
- **Never fix code.** Report failures; let builder skills fix them.
- **Do not dismiss warnings.** All warnings deserve investigation.
- **Order matters.** `build_runner` before `flutter analyze`, since generated files affect analysis.

## Example Output

```
## Integration Check Report

### Step 1: dart format
Status: Pass
Details: All files formatted.

### Step 2: build_runner
Status: Fail
Details: Error in lib/database/tables/new_table.dart:14 - Column 'subjectId' referenced in foreign key constraint does not exist. Did you mean 'id'?
Action: Fix the foreign key reference in the table definition and re-run.

### Step 3: flutter analyze
Status: Fail
Details: Errors from build_runner failures propagated.

### Step 4: flutter test
Status: Skipped (build_runner failed, Gild generated code missing)

### Final Verdict: Fail
Fix build_runner issues before continuing.
```

## Boundaries

- Does not edit code.
- Does not run git operations.
- Does not deploy or release.

## Common Mistakes

- Running `flutter analyze` before `build_runner` (generated code may cause false errors).
- Failing to run `build_runner` at all.
- Dismissing warnings as "false positives" without investigating.
- Not checking if the test suite even exists (empty `test/` directory).

## Interaction

| Skill | Interaction |
|---|---|
| `chief-architect` | Receives work from. |
| `debug-engineer` | When failures are complex, routes to debug engineer for diagnosis. |
| Builder skills | Reports failures to the relevant builder for fixes. |
| `test-engineer` | Reports test failures. |

## Activation

When `chief-architect` routes a validation request, or when the user directly:
- Asks to "run the pipeline", "validate", or "check if it builds."
- A milestone is complete.
- Pre-commit or pre-release.
