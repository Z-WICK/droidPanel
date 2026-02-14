# Repository Guidelines

## Project Structure & Module Organization
- Root contains the Flutter desktop project at `droid_config_panel/` and a macOS app shortcut.
- Main source code is in `droid_config_panel/lib/`:
  - `models/` for domain objects and enums
  - `services/` for file I/O, validation, and search logic
  - `providers/` for Riverpod state management
  - `screens/` for page-level UI
  - `widgets/` for reusable UI components
  - `utils/` for shared constants/helpers
- Native macOS host code is in `droid_config_panel/macos/`.
- Product and implementation docs live in `droid_config_panel/specs/`.

## Build, Test, and Development Commands
Run commands from repo root with `cd droid_config_panel` first.
- `flutter pub get`: install/update dependencies.
- `flutter run -d macos`: run the app locally in development mode.
- `flutter analyze`: run static checks using `flutter_lints`.
- `flutter test`: run automated Dart/Flutter tests.
- `flutter build macos --release`: build release app at `build/macos/Build/Products/Release/`.

## Coding Style & Naming Conventions
- Follow standard Dart style: 2-space indentation, no tabs, keep multiline widget trees trailing-comma friendly.
- Use `snake_case.dart` for files (example: `config_service.dart`).
- Use `PascalCase` for classes/types, `camelCase` for variables/methods.
- Keep business/file logic in `services/`; keep UI composition in `screens/` and `widgets/`.
- Format before committing: `dart format lib test` (or `dart format lib` if `test/` is not present).

## Testing Guidelines
- Testing framework: `flutter_test`.
- Place tests under `droid_config_panel/test/` and name files `*_test.dart` (example: `validation_service_test.dart`).
- Prioritize unit tests for `services/` and provider state transitions; add widget tests for key user flows.
- Use scenarios in `droid_config_panel/specs/quickstart.md` as manual regression checks when automated coverage is missing.

## Commit & Pull Request Guidelines
- Match existing Conventional Commit style: `feat:`, `fix:`, `chore:`, `docs:`, `revert:`.
- Keep commits scoped to one logical change.
- PRs should include:
  - concise problem/solution summary
  - linked issue or spec/task
  - validation notes (`flutter analyze`, `flutter test`, and/or manual steps)
  - screenshots or short recordings for UI changes

## Security & Configuration Tips
- The app operates on `.factory/` (project) and `~/.factory/` (personal). Do not commit personal config files.
- Treat `hooks.json` and `mcp.json` as sensitive; redact paths, tokens, and private host details in examples/screenshots.
