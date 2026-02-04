# Quickstart Guide: Droid Configuration Management Panel

**Date**: 2026-02-04
**Feature**: 001-droid-config-panel

## Prerequisites

- macOS 10.14 (Mojave) or later
- Flutter SDK 3.x installed
- Xcode with command line tools (for macOS build)

## Setup

### 1. Clone and Install Dependencies

```bash
cd droid_config_panel
flutter pub get
```

### 2. Run in Development Mode

```bash
flutter run -d macos
```

### 3. Build Release

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/DroidConfigPanel.app`

---

## Integration Scenarios

### Scenario 1: View All Configurations

**Steps**:
1. Launch the application
2. Application scans both `.factory/` and `~/.factory/` directories
3. Configurations are displayed grouped by type

**Expected Result**:
- All 5 configuration types shown in sidebar/tabs
- Each configuration shows name, description, location badge
- Empty state shown if no configurations exist

**Test Data Setup**:
```bash
# Create test directories
mkdir -p ~/.factory/droids
mkdir -p .factory/droids

# Create sample droid
cat > ~/.factory/droids/test-droid.md << 'EOF'
---
name: test-droid
description: A test droid for development
model: sonnet
---

You are a helpful test assistant.
EOF
```

---

### Scenario 2: Create New Configuration

**Steps**:
1. Click "Create New" button
2. Select configuration type (e.g., "Droid")
3. Select location (Project or Personal)
4. Fill in form fields (name, description)
5. Edit advanced settings in code editor
6. Click "Validate" to check syntax
7. Click "Save" to create

**Expected Result**:
- Form validates required fields
- Code editor shows YAML/Markdown syntax highlighting
- Validation shows success or error messages
- New configuration appears in list after save

**Test Case**:
```dart
// Unit test for ConfigService.createConfiguration
test('creates droid configuration', () async {
  final config = await configService.createConfiguration(
    name: 'new-droid',
    type: ConfigurationType.droid,
    location: ConfigurationLocation.personal,
    content: '''
---
name: new-droid
description: Test droid
---
System prompt here
''',
  );
  
  expect(config.name, equals('new-droid'));
  expect(config.status, equals(ValidationStatus.valid));
  expect(File(config.filePath).existsSync(), isTrue);
});
```

---

### Scenario 3: Edit Configuration

**Steps**:
1. Select a configuration from the list
2. Click "Edit" button
3. Modify form fields or code editor content
4. Click "Validate" to check changes
5. Click "Save" to persist

**Expected Result**:
- Form pre-filled with current values
- Code editor shows current content
- Changes validated before save
- Invalid changes blocked with error messages

**Test Case**:
```dart
test('updates configuration content', () async {
  final updated = await configService.updateConfiguration(
    id: existingConfig.id,
    content: newContent,
  );
  
  expect(updated.content, equals(newContent));
  expect(updated.modifiedAt.isAfter(existingConfig.modifiedAt), isTrue);
});
```

---

### Scenario 4: Delete Configuration

**Steps**:
1. Select a configuration from the list
2. Click "Delete" button
3. Confirm deletion in dialog

**Expected Result**:
- Confirmation dialog shows configuration name
- File removed from disk after confirmation
- Configuration removed from list
- Cancel returns to list without changes

**Test Case**:
```dart
test('deletes configuration', () async {
  final filePath = existingConfig.filePath;
  
  await configService.deleteConfiguration(existingConfig.id);
  
  expect(File(filePath).existsSync(), isFalse);
  expect(await configService.getConfiguration(existingConfig.id), isNull);
});
```

---

### Scenario 5: Search and Filter

**Steps**:
1. Enter search term in search bar
2. Select type filter (e.g., "Skills only")
3. Select location filter (e.g., "Personal only")

**Expected Result**:
- List updates in real-time as filters change
- Search matches name and description
- Filters can be combined
- Clear filters shows all configurations

**Test Case**:
```dart
test('filters by type and location', () {
  final filtered = searchService.filter(
    configurations: allConfigs,
    type: ConfigurationType.skill,
    location: ConfigurationLocation.personal,
  );
  
  expect(filtered.every((c) => c.type == ConfigurationType.skill), isTrue);
  expect(filtered.every((c) => c.location == ConfigurationLocation.personal), isTrue);
});
```

---

### Scenario 6: Syntax Validation

**Steps**:
1. Edit a configuration
2. Introduce a syntax error (e.g., invalid YAML)
3. Click "Validate" button
4. Attempt to save

**Expected Result**:
- Validation shows specific error message
- Error includes line number if applicable
- Save button disabled while invalid
- Fixing error enables save

**Test Case**:
```dart
test('validates YAML syntax', () async {
  final result = await validationService.validate(
    content: 'invalid: yaml: content:',
    type: ConfigurationType.hook,
  );
  
  expect(result.isValid, isFalse);
  expect(result.errors, isNotEmpty);
  expect(result.errors.first.line, isNotNull);
});
```

---

## Example Requests/Responses

### FileService Examples

**List Configurations**:
```dart
// Request
final files = await fileService.listConfigurations(
  location: ConfigurationLocation.personal,
  type: ConfigurationType.droid,
);

// Response
[
  FileInfo(
    path: '/Users/user/.factory/droids/my-droid.md',
    name: 'my-droid.md',
    size: 256,
    created: DateTime(2026, 2, 1),
    modified: DateTime(2026, 2, 4),
  ),
  // ...
]
```

### ValidationService Examples

**Valid Configuration**:
```dart
// Request
final result = await validationService.validate(
  content: '''
---
name: valid-droid
description: A valid droid
---
System prompt
''',
  type: ConfigurationType.droid,
);

// Response
ValidationResult(
  status: ValidationStatus.valid,
  errors: [],
  warnings: [],
)
```

**Invalid Configuration**:
```dart
// Request
final result = await validationService.validate(
  content: '''
---
name: 
description: Missing name
---
''',
  type: ConfigurationType.droid,
);

// Response
ValidationResult(
  status: ValidationStatus.invalid,
  errors: [
    ValidationError(
      message: 'Required field "name" is empty',
      line: 2,
      column: 7,
      severity: ValidationSeverity.error,
    ),
  ],
  warnings: [],
)
```

---

## Troubleshooting

### Common Issues

1. **"Directory not found" error**
   - Ensure `.factory/` exists in project root
   - Ensure `~/.factory/` exists in home directory
   - App will create directories if they don't exist

2. **"Permission denied" error**
   - Check file permissions on configuration directories
   - macOS may require granting disk access to the app

3. **Configurations not appearing**
   - Verify file extensions match expected types
   - Check that files are valid UTF-8 encoded

4. **Validation always fails**
   - Ensure YAML frontmatter is properly formatted
   - Check for invisible characters or encoding issues
