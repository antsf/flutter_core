# Contributing to flutter_core

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Run tests: `flutter test`
4. Run analysis: `flutter analyze`
5. Submit a pull request

## Branch Naming

| Prefix | Use case |
|---|---|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `refactor/` | Code cleanup without behavior change |
| `docs/` | Documentation only |
| `test/` | Test additions or fixes |

## Code Guidelines

- No commented-out code in production files — delete or use a separate branch
- No development notes in source (`// TODO added for feature X`, emoji markers)
- Extensions go in `lib/src/extensions/` with corresponding test in `test/extensions/`
- New public API must be exported from `lib/flutter_core.dart`
- Follow existing naming: snake_case files, PascalCase classes, camelCase methods

## Adding a New Extension

1. Create `lib/src/extensions/your_ext.dart`
2. Add the export to `lib/src/extensions/extensions.dart`
3. Write tests in `test/extensions/your_ext_test.dart`

## LocalStorage Supported Types

When adding new type support to `LocalStorage._fromString<T>()`, also update `_toString<T>()` symmetrically and add a test case in `test/storage/local_storage_test.dart`.

Currently supported: `String`, `int`, `double`, `bool`, `Map<String, dynamic>`.

## Dependency Policy

Before adding a new dependency, ask:
1. Is it used in more than one file?
2. Is the functionality hard to implement natively?
3. Does it significantly increase package size for consumer apps?

Avoid adding dependencies for single-use utilities — implement them directly.

## Commit Messages

Use conventional commits:

```
feat: add isValidEmail getter to StringExt
fix: LocalStorage Map deserialization
refactor: remove unused remoteCallWrapper comments
docs: update README with retry examples
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a specific file
flutter test test/storage/local_storage_test.dart
```

Tests should cover:
- Happy path
- Edge cases (empty string, null, boundary values)
- Error cases (unsupported type, network failure)

## Before Submitting a PR

- [ ] `flutter analyze` shows no issues
- [ ] `flutter test` passes
- [ ] CHANGELOG.md updated under the appropriate version
- [ ] README.md updated if public API changed
- [ ] No commented-out code added
