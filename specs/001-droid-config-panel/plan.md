# Implementation Plan: Droid Configuration Management Panel

**Branch**: `001-droid-config-panel` | **Date**: 2026-02-04 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-droid-config-panel/spec.md`

## Summary

Build a native macOS desktop application using Flutter that provides a unified management interface for all Factory configuration types (Droids, Skills, Agents, Hooks, MCP Servers). The application supports CRUD operations with syntax validation, hybrid editing (form + code editor), and manages both project-level and personal-level configurations.

## Technical Context

**Language/Version**: Dart 3.x (Flutter 3.x stable)
**Primary Dependencies**: 
- Flutter Desktop (macOS)
- `yaml` package for YAML parsing
- `file_picker` or native file system access
- `flutter_code_editor` or `code_text_field` for code editing
- `provider` or `riverpod` for state management

**Storage**: File-based (YAML/Markdown files in `.factory/` and `~/.factory/` directories)
**Testing**: Flutter test framework (`flutter test`), integration tests with `integration_test` package
**Target Platform**: macOS 10.14+ (Mojave or later), with potential for Windows/Linux
**Project Type**: Desktop application (single project)
**Performance Goals**: 
- App launch < 2 seconds
- Configuration list load < 500ms
- Syntax validation < 200ms

**Constraints**: 
- Must have file system access to both project and home directories
- Must handle YAML and Markdown file formats
- Must validate against Factory configuration schemas

**Scale/Scope**: 
- Support 100+ configurations per location
- 5 configuration types
- 2 storage locations (project/personal)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| Library-First | ✅ PASS | Core logic (file operations, validation, parsing) will be in separate service classes |
| CLI Interface | ⚠️ N/A | Desktop GUI application - CLI not primary interface |
| Test-First | ✅ PASS | Unit tests for services, widget tests for UI, integration tests for workflows |
| Integration Testing | ✅ PASS | File system operations and validation logic require integration tests |
| Simplicity | ✅ PASS | Single Flutter project, standard patterns, no over-engineering |

**Gate Status**: ✅ PASSED - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/001-droid-config-panel/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (internal service contracts)
└── tasks.md             # Phase 2 output (/tasks command)
```

### Source Code (repository root)

```text
droid_config_panel/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   │   ├── configuration.dart       # Base configuration model
│   │   ├── droid_config.dart        # Droid-specific model
│   │   ├── skill_config.dart        # Skill-specific model
│   │   ├── agent_config.dart        # Agent-specific model
│   │   ├── hook_config.dart         # Hook-specific model
│   │   └── mcp_server_config.dart   # MCP Server-specific model
│   ├── services/                    # Business logic
│   │   ├── file_service.dart        # File system operations
│   │   ├── config_service.dart      # Configuration CRUD operations
│   │   ├── validation_service.dart  # Syntax validation
│   │   └── search_service.dart      # Search and filter logic
│   ├── providers/                   # State management
│   │   ├── config_provider.dart     # Configuration state
│   │   └── filter_provider.dart     # Filter/search state
│   ├── screens/                     # Full-page views
│   │   ├── home_screen.dart         # Main configuration list
│   │   ├── create_screen.dart       # Create new configuration
│   │   └── edit_screen.dart         # Edit configuration
│   ├── widgets/                     # Reusable UI components
│   │   ├── config_list_item.dart    # List item widget
│   │   ├── config_form.dart         # Form fields widget
│   │   ├── code_editor.dart         # Code editor widget
│   │   ├── validation_result.dart   # Validation display widget
│   │   ├── search_bar.dart          # Search input widget
│   │   └── filter_chips.dart        # Filter selection widget
│   └── utils/                       # Utilities
│       ├── constants.dart           # App constants, paths
│       └── yaml_utils.dart          # YAML parsing helpers
├── test/
│   ├── unit/                        # Unit tests
│   │   ├── services/
│   │   └── models/
│   ├── widget/                      # Widget tests
│   │   ├── screens/
│   │   └── widgets/
│   └── integration/                 # Integration tests
│       └── config_workflow_test.dart
├── macos/                           # macOS platform files
├── pubspec.yaml                     # Dependencies
└── README.md                        # Project documentation
```

**Structure Decision**: Single Flutter Desktop project with clean separation between models, services, providers, screens, and widgets. Services handle all business logic and file operations, making them independently testable.

## Complexity Tracking

No constitution violations requiring justification.
