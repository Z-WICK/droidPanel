# Feature Specification: Droid Configuration Management Panel

**Feature Branch**: `001-droid-config-panel`  
**Created**: 2026-02-04  
**Status**: Draft  
**Input**: User description: "管理droid配置的面板，用vue3脚手架实现。包括skill、agent等等所有配置都要能增删改查。并且删除修改配置需要检测是否符合droid的配置语法避免修改配置后不可用"

## Clarifications

### Session 2026-02-04

- Q: 具体需要支持哪些配置类型？ → A: Droids + Skills + Agents + Hooks + MCP Servers（完整配置生态）
- Q: 语法验证应该在什么时候执行？ → A: 保存时验证 + 提供"验证"按钮手动触发
- Q: 面板应该管理哪个范围的配置？ → A: 两者都支持（项目级 .factory/ + 个人级 ~/.factory/），界面中清晰区分
- Q: 验证失败时是否允许保存？ → A: 阻止保存，必须修复错误后才能保存
- Q: 用户如何编辑配置内容？ → A: 混合模式（常用字段用表单 + 高级配置用代码编辑器）
- Q: 使用哪种技术架构来构建 macOS 应用？ → A: Flutter Desktop（跨平台，Dart 语言，可打包为 macOS 原生应用）

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View All Configurations (Priority: P1)

As a user, I want to see a list of all my configurations (Droids, Skills, Agents, Hooks, MCP Servers) so that I can quickly understand what is available and their current status.

**Why this priority**: This is the foundational feature - users need to see existing configurations before they can manage them. Without this, no other management actions are possible.

**Independent Test**: Can be fully tested by loading the panel and verifying all configuration types are displayed in a categorized list format with key information visible.

**Acceptance Scenarios**:

1. **Given** the user opens the panel, **When** the page loads, **Then** all configurations are displayed categorized by type (Droids, Skills, Agents, Hooks, MCP Servers)
2. **Given** there are multiple configurations, **When** viewing the list, **Then** each configuration shows its name, type, description, location (project/personal), and status
3. **Given** there are no configurations, **When** viewing the list, **Then** an empty state message is displayed with guidance to create a new configuration
4. **Given** configurations exist in both project and personal directories, **When** viewing the list, **Then** the source location is clearly indicated for each configuration

---

### User Story 2 - Create New Configuration (Priority: P1)

As a user, I want to create a new configuration (of any supported type) so that I can add custom droids, skills, agents, hooks, or MCP servers to my system.

**Why this priority**: Creating new configurations is essential for users to customize their setup. This is a core CRUD operation.

**Independent Test**: Can be fully tested by selecting a configuration type, filling in details via form and/or code editor, saving, and verifying the new configuration appears in the list.

**Acceptance Scenarios**:

1. **Given** the user is on the configuration list, **When** they click "Create New", **Then** they can select the configuration type and target location (project/personal)
2. **Given** the user selects a configuration type, **When** the form loads, **Then** common fields are displayed as form inputs and advanced options are available in a code editor
3. **Given** the user fills in valid configuration details, **When** they submit the form, **Then** syntax validation runs and the configuration is saved if valid
4. **Given** the user submits invalid syntax, **When** validation runs, **Then** clear error messages indicate what needs to be corrected and saving is blocked

---

### User Story 3 - Edit Existing Configuration (Priority: P2)

As a user, I want to edit an existing configuration so that I can update settings as my needs change.

**Why this priority**: Editing is important but secondary to viewing and creating. Users need to modify configurations over time.

**Independent Test**: Can be fully tested by selecting a configuration, modifying its values via form or code editor, validating, saving, and verifying changes persist.

**Acceptance Scenarios**:

1. **Given** the user selects a configuration from the list, **When** they click "Edit", **Then** a form is displayed pre-filled with current values (common fields as form, advanced as code editor)
2. **Given** the user modifies configuration values, **When** they click "Validate", **Then** syntax validation runs and displays results
3. **Given** the user saves valid changes, **When** validation passes, **Then** the updated configuration is persisted and reflected in the list
4. **Given** the user tries to save invalid changes, **When** validation fails, **Then** saving is blocked and error messages are displayed

---

### User Story 4 - Delete Configuration (Priority: P2)

As a user, I want to delete a configuration so that I can remove configurations I no longer need.

**Why this priority**: Deletion is necessary for maintenance but less frequent than viewing/creating/editing.

**Independent Test**: Can be fully tested by selecting a configuration, confirming deletion, and verifying it no longer appears in the list.

**Acceptance Scenarios**:

1. **Given** the user selects a configuration, **When** they click "Delete", **Then** a confirmation dialog is displayed showing the configuration name and type
2. **Given** the user confirms deletion, **When** the action completes, **Then** the configuration file is removed and the list is updated
3. **Given** the user cancels deletion, **When** the dialog closes, **Then** the configuration remains unchanged

---

### User Story 5 - Search and Filter Configurations (Priority: P3)

As a user, I want to search and filter configurations so that I can quickly find specific configurations in a large list.

**Why this priority**: Useful for users with many configurations, but not essential for basic functionality.

**Independent Test**: Can be fully tested by entering search terms and applying filters, verifying the list shows only matching configurations.

**Acceptance Scenarios**:

1. **Given** the user enters a search term, **When** the search executes, **Then** only configurations matching the term (in name or description) are displayed
2. **Given** the user selects a type filter, **When** the filter applies, **Then** only configurations of that type are displayed
3. **Given** the user selects a location filter (project/personal), **When** the filter applies, **Then** only configurations from that location are displayed
4. **Given** no configurations match the search/filter, **When** viewing results, **Then** a "no results" message is displayed

---

### User Story 6 - Validate Configuration Syntax (Priority: P2)

As a user, I want to manually validate my configuration before saving so that I can catch errors early.

**Why this priority**: Syntax validation is critical to prevent broken configurations, and manual validation gives users control.

**Independent Test**: Can be fully tested by clicking "Validate" button and verifying validation results are displayed correctly.

**Acceptance Scenarios**:

1. **Given** the user is editing a configuration, **When** they click "Validate", **Then** the system checks the configuration against the appropriate schema
2. **Given** the configuration is valid, **When** validation completes, **Then** a success message is displayed
3. **Given** the configuration has errors, **When** validation completes, **Then** specific error messages with line numbers (if applicable) are displayed

---

### Edge Cases

- What happens when the configuration file is corrupted or unreadable?
- How does the system handle concurrent edits to the same configuration?
- What happens when the user tries to create a configuration with a duplicate name?
- How does the system handle very long configuration names or descriptions?
- What happens when the target directory (.factory/ or ~/.factory/) doesn't exist?
- How does the system handle configurations with syntax errors that already exist on disk?
- What happens when a configuration references another configuration that doesn't exist?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display all configurations (Droids, Skills, Agents, Hooks, MCP Servers) in a categorized list/table format
- **FR-002**: System MUST allow users to create new configurations of any supported type with name, description, and type-specific settings
- **FR-003**: System MUST allow users to edit existing configurations using a hybrid interface (form for common fields, code editor for advanced settings)
- **FR-004**: System MUST allow users to delete configurations with confirmation
- **FR-005**: System MUST validate configuration syntax before saving and block saving if validation fails
- **FR-006**: System MUST provide a "Validate" button for manual syntax validation
- **FR-007**: System MUST provide search functionality to filter configurations by name or description
- **FR-008**: System MUST provide filters by configuration type and location (project/personal)
- **FR-009**: System MUST display appropriate feedback messages for all user actions (success, error, loading states)
- **FR-010**: System MUST persist configuration changes to the appropriate storage location (project .factory/ or personal ~/.factory/)
- **FR-011**: System MUST handle and display errors gracefully when operations fail
- **FR-012**: System MUST prevent creation of configurations with duplicate names within the same type and location
- **FR-013**: System MUST clearly distinguish between project-level and personal-level configurations in the UI
- **FR-014**: System MUST display syntax validation errors with specific details (error message, line number if applicable)

### Key Entities

- **Configuration**: Base entity for all configuration types
  - Name (unique identifier within type and location)
  - Type (Droid | Skill | Agent | Hook | MCP Server)
  - Description (human-readable explanation of purpose)
  - Location (project | personal)
  - Content (the actual configuration data)
  - Status (valid | invalid | unknown)
  - File path (absolute path to the configuration file)
  - Created/Modified timestamps

- **Droid Configuration**: Custom AI agent configuration
  - Model settings, system prompts, capabilities

- **Skill Configuration**: Reusable skill/capability definition
  - Trigger conditions, execution logic

- **Agent Configuration**: Sub-agent task definitions
  - Task type, prompt templates

- **Hook Configuration**: Lifecycle hook definitions
  - Event triggers, actions

- **MCP Server Configuration**: Model Context Protocol server settings
  - Server endpoints, authentication

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view all their droid configurations within 2 seconds of opening the panel
- **SC-002**: Users can create a new configuration in under 1 minute
- **SC-003**: Users can find a specific configuration using search in under 5 seconds
- **SC-004**: 95% of user actions (create, edit, delete) complete successfully on first attempt
- **SC-005**: All form validation errors are displayed within 500ms of user input
- **SC-006**: Users can complete any CRUD operation without requiring documentation or help

## Assumptions

- Configurations are stored in standard Factory locations:
  - Project level: `.factory/droids/`, `.factory/skills/`, `.factory/agents/`, `.factory/hooks/`, `.factory/mcp/`
  - Personal level: `~/.factory/droids/`, `~/.factory/skills/`, `~/.factory/agents/`, `~/.factory/hooks/`, `~/.factory/mcp/`
- Configuration files use YAML or Markdown format (depending on type)
- The application will be built with Flutter Desktop (Dart language), packaged as a native macOS application
- The application can also be compiled for Windows and Linux if needed in the future
- Users have basic familiarity with droid/skill/agent configuration concepts
- No authentication is required (local tool usage)
- Syntax validation schemas are available for each configuration type
- The application runs locally and has file system access to both project and personal directories
- macOS minimum version: macOS 10.14 (Mojave) or later
