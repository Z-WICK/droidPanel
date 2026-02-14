# Tasks: Droid Configuration Management Panel

**Input**: Design documents from `/specs/001-droid-config-panel/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not explicitly requested - test tasks omitted.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

All paths relative to `droid_config_panel/` Flutter project root.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Flutter project with `flutter create --platforms=macos droid_config_panel`
- [x] T002 Configure pubspec.yaml with dependencies (yaml, flutter_riverpod, path_provider, flutter_code_editor)
- [x] T003 [P] Create directory structure: lib/models/, lib/services/, lib/providers/, lib/screens/, lib/widgets/, lib/utils/
- [x] T004 [P] Configure macOS entitlements for file system access in macos/Runner/DebugProfile.entitlements
- [x] T005 [P] Create app constants and paths in lib/utils/constants.dart
- [x] T006 [P] Create YAML parsing utilities in lib/utils/yaml_utils.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T007 Create enumerations (ConfigurationType, ConfigurationLocation, ValidationStatus, ValidationSeverity) in lib/models/enums.dart
- [x] T008 Create base Configuration model class in lib/models/configuration.dart
- [x] T009 [P] Create DroidConfig model extending Configuration in lib/models/droid_config.dart
- [x] T010 [P] Create SkillConfig model extending Configuration in lib/models/skill_config.dart
- [x] T011 [P] Create AgentConfig model extending Configuration in lib/models/agent_config.dart
- [x] T012 [P] Create HookConfig model extending Configuration in lib/models/hook_config.dart
- [x] T013 [P] Create MCPServerConfig model extending Configuration in lib/models/mcp_server_config.dart
- [x] T014 [P] Create ValidationError and ValidationResult models in lib/models/validation_result.dart
- [x] T015 [P] Create AppException hierarchy (NotFoundException, DuplicateNameException, ValidationException, FileSystemException) in lib/models/exceptions.dart
- [x] T016 Implement FileService with listConfigurations, readConfiguration, writeConfiguration, deleteConfiguration, getFileInfo in lib/services/file_service.dart
- [x] T017 Implement ValidationService with validate and validateFile methods in lib/services/validation_service.dart
- [x] T018 Create ConfigurationState and FilterState classes in lib/providers/states.dart
- [x] T019 Setup Riverpod providers structure in lib/providers/providers.dart
- [x] T020 Create main.dart with ProviderScope and MaterialApp setup in lib/main.dart

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - View All Configurations (Priority: P1) 🎯 MVP

**Goal**: Display all configurations from both project and personal directories, categorized by type

**Independent Test**: Launch app, verify configurations from ~/.factory/ and .factory/ are displayed with name, type, description, location badge

### Implementation for User Story 1

- [x] T021 [US1] Implement ConfigService.getAllConfigurations in lib/services/config_service.dart
- [x] T022 [US1] Implement ConfigService.getConfigurationsByType in lib/services/config_service.dart
- [x] T023 [US1] Implement ConfigService.getConfigurationsByLocation in lib/services/config_service.dart
- [x] T024 [US1] Create configProvider with getAllConfigurations in lib/providers/config_provider.dart
- [x] T025 [P] [US1] Create ConfigListItem widget showing name, type, description, location badge in lib/widgets/config_list_item.dart
- [x] T026 [P] [US1] Create EmptyState widget with guidance message in lib/widgets/empty_state.dart
- [x] T027 [P] [US1] Create LoadingIndicator widget in lib/widgets/loading_indicator.dart
- [x] T028 [P] [US1] Create ErrorDisplay widget in lib/widgets/error_display.dart
- [x] T029 [US1] Create HomeScreen with categorized configuration list (tabs/sidebar for types) in lib/screens/home_screen.dart
- [x] T030 [US1] Add location badges (Project/Personal) to distinguish configuration sources in lib/widgets/location_badge.dart
- [x] T031 [US1] Wire HomeScreen to main.dart as initial route

**Checkpoint**: User Story 1 complete - app displays all configurations categorized by type with location indicators

---

## Phase 4: User Story 2 - Create New Configuration (Priority: P1)

**Goal**: Allow users to create new configurations of any type with form + code editor

**Independent Test**: Click "Create New", select type and location, fill form, save, verify new file created and appears in list

### Implementation for User Story 2

- [x] T032 [US2] Implement ConfigService.createConfiguration with duplicate name check in lib/services/config_service.dart
- [x] T033 [P] [US2] Create TypeSelector widget for choosing configuration type in lib/widgets/type_selector.dart
- [x] T034 [P] [US2] Create LocationSelector widget for choosing project/personal in lib/widgets/location_selector.dart
- [x] T035 [US2] Create ConfigForm widget with common fields (name, description) in lib/widgets/config_form.dart
- [x] T036 [US2] Create CodeEditor widget with YAML/Markdown syntax highlighting in lib/widgets/code_editor.dart
- [x] T037 [US2] Create ValidationResultDisplay widget showing errors/success in lib/widgets/validation_result_display.dart
- [x] T038 [US2] Create CreateScreen with type selector, location selector, form, and code editor in lib/screens/create_screen.dart
- [x] T039 [US2] Add validation on save (block if invalid) in CreateScreen
- [x] T040 [US2] Add navigation from HomeScreen to CreateScreen via "Create New" button
- [x] T041 [US2] Add success feedback and return to HomeScreen after successful creation

**Checkpoint**: User Story 2 complete - users can create new configurations with validation

---

## Phase 5: User Story 3 - Edit Existing Configuration (Priority: P2)

**Goal**: Allow users to edit existing configurations with pre-filled form and code editor

**Independent Test**: Select configuration, click Edit, modify values, validate, save, verify changes persisted

### Implementation for User Story 3

- [x] T042 [US3] Implement ConfigService.getConfiguration by ID in lib/services/config_service.dart
- [x] T043 [US3] Implement ConfigService.updateConfiguration in lib/services/config_service.dart
- [x] T044 [US3] Create EditScreen with pre-filled form and code editor in lib/screens/edit_screen.dart
- [x] T045 [US3] Add "Validate" button to EditScreen triggering ValidationService
- [x] T046 [US3] Add validation on save (block if invalid) in EditScreen
- [x] T047 [US3] Add navigation from ConfigListItem to EditScreen via "Edit" action
- [x] T048 [US3] Add success feedback and return to HomeScreen after successful update

**Checkpoint**: User Story 3 complete - users can edit configurations with validation

---

## Phase 6: User Story 4 - Delete Configuration (Priority: P2)

**Goal**: Allow users to delete configurations with confirmation dialog

**Independent Test**: Select configuration, click Delete, confirm in dialog, verify file removed and list updated

### Implementation for User Story 4

- [x] T049 [US4] Implement ConfigService.deleteConfiguration in lib/services/config_service.dart
- [x] T050 [US4] Create DeleteConfirmationDialog widget showing config name and type in lib/widgets/delete_confirmation_dialog.dart
- [x] T051 [US4] Add "Delete" action to ConfigListItem triggering confirmation dialog
- [x] T052 [US4] Handle deletion confirmation and refresh list in HomeScreen
- [x] T053 [US4] Add success/error feedback after deletion attempt

**Checkpoint**: User Story 4 complete - users can delete configurations with confirmation

---

## Phase 7: User Story 5 - Search and Filter Configurations (Priority: P3)

**Goal**: Allow users to search by name/description and filter by type/location

**Independent Test**: Enter search term, apply filters, verify list shows only matching configurations

### Implementation for User Story 5

- [x] T054 [US5] Implement SearchService.search method in lib/services/search_service.dart
- [x] T055 [US5] Implement SearchService.filter method in lib/services/search_service.dart
- [x] T056 [US5] Create filterProvider with search query and filter state in lib/providers/filter_provider.dart
- [x] T057 [P] [US5] Create SearchBar widget with text input in lib/widgets/search_bar.dart
- [x] T058 [P] [US5] Create FilterChips widget for type and location filters in lib/widgets/filter_chips.dart
- [x] T059 [US5] Integrate SearchBar and FilterChips into HomeScreen
- [x] T060 [US5] Connect filter state to configuration list display
- [x] T061 [US5] Add "No results" empty state when search/filter returns nothing

**Checkpoint**: User Story 5 complete - users can search and filter configurations

---

## Phase 8: User Story 6 - Validate Configuration Syntax (Priority: P2)

**Goal**: Provide manual validation button with detailed error display

**Independent Test**: Edit configuration, click Validate, verify validation results displayed with line numbers

### Implementation for User Story 6

- [x] T062 [US6] Enhance ValidationService with type-specific validation rules in lib/services/validation_service.dart
- [x] T063 [US6] Add YAML schema validation for Hook and MCP Server configs
- [x] T064 [US6] Add Markdown frontmatter validation for Droid, Skill, Agent configs
- [x] T065 [US6] Enhance ValidationResultDisplay to show line numbers and error details
- [x] T066 [US6] Add "Validate" button to CreateScreen (reuse from EditScreen pattern)
- [x] T067 [US6] Highlight error lines in CodeEditor widget when validation fails

**Checkpoint**: User Story 6 complete - users can manually validate with detailed feedback

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T068 [P] Add app icon and window title configuration in macos/Runner/
- [x] T069 [P] Add keyboard shortcuts (Cmd+N for new, Cmd+S for save, Cmd+Delete for delete)
- [x] T070 [P] Add loading states for all async operations
- [x] T071 [P] Add error handling for file system permission issues
- [x] T072 Handle edge case: create directories if .factory/ or ~/.factory/ don't exist
- [x] T073 Handle edge case: display corrupted/unreadable files with error indicator
- [x] T074 Add refresh button to reload configurations from disk
- [x] T075 Run quickstart.md validation scenarios manually
- [x] T076 Build release with `flutter build macos --release`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

| Story | Priority | Dependencies | Can Parallel With |
|-------|----------|--------------|-------------------|
| US1 - View | P1 | Foundational only | - |
| US2 - Create | P1 | US1 (needs list to verify) | US3, US4 |
| US3 - Edit | P2 | US1 (needs list to select) | US2, US4, US6 |
| US4 - Delete | P2 | US1 (needs list to select) | US2, US3 |
| US5 - Search | P3 | US1 (needs list to filter) | US6 |
| US6 - Validate | P2 | US2 or US3 (needs editor) | US3, US4, US5 |

### Within Each User Story

- Services before UI components
- Widgets before screens
- Core implementation before integration

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All model tasks (T009-T015) can run in parallel
- All widget tasks within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel after Foundational phase

---

## Parallel Example: Phase 2 Models

```bash
# Launch all model tasks together:
Task: "Create DroidConfig model in lib/models/droid_config.dart"
Task: "Create SkillConfig model in lib/models/skill_config.dart"
Task: "Create AgentConfig model in lib/models/agent_config.dart"
Task: "Create HookConfig model in lib/models/hook_config.dart"
Task: "Create MCPServerConfig model in lib/models/mcp_server_config.dart"
Task: "Create ValidationError model in lib/models/validation_result.dart"
Task: "Create AppException hierarchy in lib/models/exceptions.dart"
```

## Parallel Example: User Story 1 Widgets

```bash
# Launch all US1 widget tasks together:
Task: "Create ConfigListItem widget in lib/widgets/config_list_item.dart"
Task: "Create EmptyState widget in lib/widgets/empty_state.dart"
Task: "Create LoadingIndicator widget in lib/widgets/loading_indicator.dart"
Task: "Create ErrorDisplay widget in lib/widgets/error_display.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (View)
4. Complete Phase 4: User Story 2 (Create)
5. **STOP and VALIDATE**: Test viewing and creating configurations
6. Deploy/demo if ready - users can view and create configs

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (View) → Can see all configurations (MVP v0.1)
3. Add US2 (Create) → Can create new configurations (MVP v0.2)
4. Add US3 (Edit) + US4 (Delete) → Full CRUD (v0.3)
5. Add US5 (Search) + US6 (Validate) → Complete feature set (v1.0)

### Parallel Team Strategy

With multiple developers after Foundational phase:
- Developer A: US1 → US2
- Developer B: US3 → US4
- Developer C: US5 → US6

---

## Summary

| Metric | Count |
|--------|-------|
| Total Tasks | 76 |
| Setup Tasks | 6 |
| Foundational Tasks | 14 |
| US1 Tasks | 11 |
| US2 Tasks | 10 |
| US3 Tasks | 7 |
| US4 Tasks | 5 |
| US5 Tasks | 8 |
| US6 Tasks | 6 |
| Polish Tasks | 9 |
| Parallel Opportunities | 28 tasks marked [P] |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
