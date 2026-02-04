# Research: Droid Configuration Management Panel

**Date**: 2026-02-04
**Feature**: 001-droid-config-panel

## Research Areas

### 1. Flutter Desktop macOS Development

**Decision**: Use Flutter 3.x stable with macOS desktop support

**Rationale**: 
- Flutter Desktop is production-ready for macOS since Flutter 3.0
- Single codebase can target macOS, Windows, and Linux
- Rich widget library and excellent developer experience
- Native performance with Dart AOT compilation

**Alternatives Considered**:
- Electron + Vue 3: Rejected due to large bundle size (~150MB+) and higher memory usage
- Tauri + Vue 3: Good option but requires Rust knowledge for native features
- Swift/SwiftUI: Best native performance but macOS-only, steeper learning curve

**Key Packages**:
- `window_manager`: Window control and customization
- `macos_ui`: Native macOS-style widgets (optional, for native look)

---

### 2. File System Access on macOS

**Decision**: Use `dart:io` with path_provider for cross-platform paths

**Rationale**:
- Flutter Desktop has full file system access via `dart:io`
- `path_provider` provides platform-specific paths (home directory, app support)
- No sandboxing issues for local development tools

**Implementation Notes**:
- Project path: Current working directory or user-selected
- Personal path: `Platform.environment['HOME']/.factory/`
- Use `Directory.watch()` for file change detection (optional)

**Key Packages**:
- `path_provider`: Platform-specific directory paths
- `path`: Cross-platform path manipulation

---

### 3. YAML Parsing and Manipulation

**Decision**: Use `yaml` package for parsing, `yaml_writer` or manual string building for writing

**Rationale**:
- `yaml` package is the standard Dart YAML parser
- Preserves structure for round-trip editing
- Handles all YAML features needed for Factory configs

**Implementation Notes**:
- Parse YAML to Map/List structures
- Validate against expected schema
- Preserve comments where possible (may require custom handling)

**Key Packages**:
- `yaml`: YAML parsing
- `yaml_edit`: YAML editing with comment preservation (if available)

---

### 4. Code Editor Widget

**Decision**: Use `flutter_code_editor` or `code_text_field` package

**Rationale**:
- Provides syntax highlighting for YAML/Markdown
- Line numbers support
- Customizable themes

**Alternatives Considered**:
- `re_editor`: Full-featured but may be overkill
- Custom TextField: Too much work for proper code editing features

**Key Features Needed**:
- YAML syntax highlighting
- Markdown syntax highlighting
- Line numbers
- Error highlighting (for validation errors)

**Key Packages**:
- `flutter_code_editor`: Code editing with syntax highlighting
- `highlight`: Syntax highlighting definitions

---

### 5. State Management

**Decision**: Use Riverpod for state management

**Rationale**:
- Type-safe and compile-time checked
- Better testability than Provider
- Supports async state out of the box
- Good for medium-complexity apps

**Alternatives Considered**:
- Provider: Simpler but less type-safe
- Bloc: More boilerplate, better for larger apps
- GetX: Less conventional, harder to test

**Key Packages**:
- `flutter_riverpod`: State management
- `riverpod_annotation`: Code generation for providers (optional)

---

### 6. Configuration Validation Schema

**Decision**: Implement custom validators based on Factory configuration structure

**Rationale**:
- Factory configurations have specific structures per type
- Need to validate required fields, types, and relationships
- Custom validators allow detailed error messages

**Validation Rules by Type**:

| Type | Required Fields | Format |
|------|-----------------|--------|
| Droid | name, description | Markdown with YAML frontmatter |
| Skill | name, description | Markdown with YAML frontmatter |
| Agent | subagent_type, description, prompt | YAML or Markdown |
| Hook | event, action | YAML |
| MCP Server | name, command or url | YAML |

**Implementation Notes**:
- Create abstract `ConfigValidator` class
- Implement type-specific validators
- Return structured error objects with line numbers

---

### 7. Factory Configuration File Locations

**Decision**: Scan standard Factory directory structure

**Rationale**:
- Factory uses consistent directory structure
- Both project and personal locations follow same pattern

**Directory Structure**:
```
.factory/                    # Project level
├── droids/                  # *.md files
├── skills/                  # *.md files  
├── agents/                  # *.md or *.yaml files
├── hooks/                   # *.yaml files
└── mcp/                     # *.yaml files

~/.factory/                  # Personal level
├── droids/
├── skills/
├── agents/
├── hooks/
└── mcp/
```

**File Extensions**:
- Droids: `.md` (Markdown with YAML frontmatter)
- Skills: `.md` (Markdown with YAML frontmatter)
- Agents: `.md` or `.yaml`
- Hooks: `.yaml`
- MCP Servers: `.yaml`

---

### 8. macOS App Packaging

**Decision**: Use `flutter build macos` with standard Flutter tooling

**Rationale**:
- Flutter provides built-in macOS build support
- Generates standard `.app` bundle
- Can be notarized for distribution

**Build Commands**:
```bash
flutter build macos --release
```

**Output**: `build/macos/Build/Products/Release/DroidConfigPanel.app`

**Distribution Options**:
- Direct `.app` distribution (for internal use)
- DMG packaging with `create-dmg` tool
- Mac App Store (requires Apple Developer account)

---

## Summary of Key Decisions

| Area | Decision | Package/Tool |
|------|----------|--------------|
| Framework | Flutter Desktop | flutter 3.x |
| Language | Dart 3.x | - |
| State Management | Riverpod | flutter_riverpod |
| YAML Parsing | yaml package | yaml |
| Code Editor | flutter_code_editor | flutter_code_editor |
| File Access | dart:io + path_provider | path_provider, path |
| Validation | Custom validators | - |
| Packaging | Flutter build | flutter build macos |

## Open Questions Resolved

All technical unknowns have been resolved. Ready for Phase 1 design.
