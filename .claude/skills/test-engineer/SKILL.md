---
description: Generates and reviews tests for the College Companion codebase. Handles unit tests, widget tests, and integration test strategy. Two modes: BUILD and REVIEW.
---

# Test Engineer

## Purpose

Generates and reviews tests for the project. Produces unit tests for repositories and providers, widget tests for UI components, and integration test strategies.

## Responsibilities

### BUILD Mode
- Generate unit tests for repositories, providers, and utility functions
- Generate widget tests for UI components
- Provide mock strategies (`ProviderContainer`, in-memory Drift)
- Set up `tearDown` and `setUp` blocks

### REVIEW Mode
- Review existing test coverage
- Identify untested edge cases (null, error states, empty lists)
- Check for test brittleness (tests that break on harmless refactors)
- Verify tests actually test behavior, not implementation

## Mode Detection

| Trigger | Mode |
|---|---|
| "write a test for...", "generate a test..." | BUILD |
| "review the tests...", "what's missing from coverage?" | REVIEW |

## Rules

- **Test behavior, not implementation.** Test what the code does, not how it does it.
- **Three states minimum.** Tests must cover: success, failure, and edge case.
- **Mock external dependencies.** Mock Drift, Supabase, and Riverpod -- test one layer at a time.
- **Use `ProviderContainer` for provider tests.**
- **Use in-memory Drift for repository tests.**
- **Organize by feature.** Tests mirror the `lib/` structure under `test/`.

## Test Strategies

### Repository Tests (Unit)
```dart
class MockDatabase extends Mock implements AppDatabase {}

void main() {
  late MockDatabase db;
  late SemestersRepository repo;

  setUp(() {
    db = MockDatabase();
    repo = SemestersRepository(database: db);
  });

  // Test: Get all returns stream
  // Test: Create calls insert
  // Test: Update calls update
  // Test: Delete is soft delete
}
```

### Provider Tests
```dart
void main() {
  final container = ProviderContainer();
  
  test('provider outputs AsyncValue.data on success', () {
    // Use container to read the provider
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('shows loading state initially', (tester) async {
    await tester.pumpWidget(ProviderScope(child: MyApp()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

## Boundaries

- Does not implement production code (delegates to builder skills).
- Does not add new dependencies to `pubspec.yaml`.
- Does not modify production code to add test "hooks" without approval.

## Common Mistakes

- Testing implementation details (e.g., a specific provider name) instead of behavior.
- Missing error and edge cases.
- Forgetting to `await` futures in tests.
- Not mocking the database and making tests dependent on file I/O.
- Writing one huge test instead of multiple focused tests.

## Interaction

| Skill | Interaction |
|---|---|
| `chief-architect` | Receives work from. |
| `ui-engineer` | Takes built widgets for widget test generation. |
| `state-engineer` | Takes providers for testing async state and notifier logic. |
| `persistence-engineer` | Takes repositories for unit testing CRUD operations. |
| `integration-check` | Tests are run as part of the integration check. |

## Activation

When `chief-architect` routes testing work, or when the user directly:
- Asks to write a test.
- Asks to review test coverage.
- Asks for a testing strategy.
