# Data Model: Droid Configuration Management Panel

**Date**: 2026-02-04
**Feature**: 001-droid-config-panel

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Configuration                           │
│  (Abstract Base)                                            │
├─────────────────────────────────────────────────────────────┤
│  - id: String (generated from path)                         │
│  - name: String (unique within type+location)               │
│  - type: ConfigurationType                                  │
│  - description: String                                      │
│  - location: ConfigurationLocation                          │
│  - filePath: String (absolute path)                         │
│  - content: String (raw file content)                       │
│  - status: ValidationStatus                                 │
│  - createdAt: DateTime                                      │
│  - modifiedAt: DateTime                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ extends
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ DroidConfig   │   │ SkillConfig   │   │ AgentConfig   │
├───────────────┤   ├───────────────┤   ├───────────────┤
│ - model       │   │ - triggers    │   │ - subagentType│
│ - systemPrompt│   │ - when        │   │ - prompt      │
│ - capabilities│   │               │   │               │
└───────────────┘   └───────────────┘   └───────────────┘
        
        ┌─────────────────────┬─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ HookConfig    │   │ MCPServerConfig│  │ValidationError│
├───────────────┤   ├───────────────┤   ├───────────────┤
│ - event       │   │ - command     │   │ - message     │
│ - action      │   │ - url         │   │ - line        │
│ - conditions  │   │ - args        │   │ - column      │
└───────────────┘   └───────────────┘   │ - severity    │
                                        └───────────────┘
```

## Enumerations

### ConfigurationType

```dart
enum ConfigurationType {
  droid,      // Custom AI agent configuration
  skill,      // Reusable skill/capability
  agent,      // Sub-agent task definition
  hook,       // Lifecycle hook
  mcpServer,  // MCP server configuration
}
```

### ConfigurationLocation

```dart
enum ConfigurationLocation {
  project,    // .factory/ in current project
  personal,   // ~/.factory/ in home directory
}
```

### ValidationStatus

```dart
enum ValidationStatus {
  valid,      // Passed all validation checks
  invalid,    // Has validation errors
  unknown,    // Not yet validated
}
```

### ValidationSeverity

```dart
enum ValidationSeverity {
  error,      // Blocks saving
  warning,    // Allows saving with caution
  info,       // Informational only
}
```

## Entity Definitions

### Configuration (Base Class)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique identifier (hash of filePath) |
| name | String | Yes | Configuration name (from filename or frontmatter) |
| type | ConfigurationType | Yes | Type of configuration |
| description | String | No | Human-readable description |
| location | ConfigurationLocation | Yes | Project or personal |
| filePath | String | Yes | Absolute path to file |
| content | String | Yes | Raw file content |
| status | ValidationStatus | Yes | Current validation status |
| createdAt | DateTime | Yes | File creation time |
| modifiedAt | DateTime | Yes | File modification time |

**Validation Rules**:
- `name` must be non-empty and unique within same type and location
- `filePath` must exist and be readable
- `content` must be valid UTF-8

**State Transitions**:
```
unknown → valid (after successful validation)
unknown → invalid (after failed validation)
valid → invalid (after edit introduces errors)
invalid → valid (after edit fixes errors)
```

### DroidConfig (extends Configuration)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| model | String | No | AI model to use (e.g., "sonnet", "opus") |
| systemPrompt | String | No | System prompt for the droid |
| capabilities | List<String> | No | List of capabilities |

**File Format**: Markdown with YAML frontmatter
```markdown
---
name: my-droid
description: A custom droid
model: sonnet
---

System prompt content here...
```

### SkillConfig (extends Configuration)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| triggers | List<String> | No | Trigger patterns |
| when | String | No | Condition for activation |

**File Format**: Markdown with YAML frontmatter

### AgentConfig (extends Configuration)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| subagentType | String | Yes | Type of sub-agent |
| prompt | String | Yes | Task prompt template |

**File Format**: Markdown or YAML

### HookConfig (extends Configuration)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | String | Yes | Event to hook (e.g., "pre-commit") |
| action | String | Yes | Action to execute |
| conditions | Map<String, dynamic> | No | Conditions for execution |

**File Format**: YAML

### MCPServerConfig (extends Configuration)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| command | String | No* | Command to run server |
| url | String | No* | URL of remote server |
| args | List<String> | No | Command arguments |
| env | Map<String, String> | No | Environment variables |

*Either `command` or `url` is required

**File Format**: YAML

### ValidationError

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| message | String | Yes | Error description |
| line | int | No | Line number (1-based) |
| column | int | No | Column number (1-based) |
| severity | ValidationSeverity | Yes | Error severity |

## Directory Mapping

| Type | Project Path | Personal Path | Extension |
|------|--------------|---------------|-----------|
| Droid | `.factory/droids/` | `~/.factory/droids/` | `.md` |
| Skill | `.factory/skills/` | `~/.factory/skills/` | `.md` |
| Agent | `.factory/agents/` | `~/.factory/agents/` | `.md`, `.yaml` |
| Hook | `.factory/hooks/` | `~/.factory/hooks/` | `.yaml` |
| MCP Server | `.factory/mcp/` | `~/.factory/mcp/` | `.yaml` |

## Indexes and Uniqueness

| Constraint | Fields | Scope |
|------------|--------|-------|
| Primary Key | id | Global |
| Unique | (name, type, location) | Per combination |
| Unique | filePath | Global |

## Data Volume Estimates

| Metric | Expected Range |
|--------|----------------|
| Configurations per location | 10-100 |
| Total configurations | 20-200 |
| File size per config | 100 bytes - 10 KB |
| Total storage | < 2 MB |
