# Service Contracts: Droid Configuration Management Panel

**Date**: 2026-02-04
**Feature**: 001-droid-config-panel

## Overview

This document defines the internal service contracts for the Flutter application. Since this is a desktop application without a backend API, these contracts define the interfaces between application layers.

---

## FileService Contract

Handles all file system operations.

### Methods

#### `listConfigurations`
```dart
Future<List<FileInfo>> listConfigurations({
  required ConfigurationLocation location,
  required ConfigurationType type,
});
```

**Input**:
- `location`: Project or personal
- `type`: Configuration type to list

**Output**: List of file information objects

**Errors**:
- `DirectoryNotFoundException`: Directory doesn't exist
- `PermissionDeniedException`: No read access

---

#### `readConfiguration`
```dart
Future<String> readConfiguration(String filePath);
```

**Input**: Absolute file path

**Output**: File content as string

**Errors**:
- `FileNotFoundException`: File doesn't exist
- `PermissionDeniedException`: No read access
- `InvalidEncodingException`: File is not valid UTF-8

---

#### `writeConfiguration`
```dart
Future<void> writeConfiguration(String filePath, String content);
```

**Input**:
- `filePath`: Absolute file path
- `content`: Content to write

**Output**: None (void)

**Errors**:
- `PermissionDeniedException`: No write access
- `DirectoryNotFoundException`: Parent directory doesn't exist

---

#### `deleteConfiguration`
```dart
Future<void> deleteConfiguration(String filePath);
```

**Input**: Absolute file path

**Output**: None (void)

**Errors**:
- `FileNotFoundException`: File doesn't exist
- `PermissionDeniedException`: No delete access

---

#### `getFileInfo`
```dart
Future<FileInfo> getFileInfo(String filePath);
```

**Input**: Absolute file path

**Output**: File metadata (created, modified, size)

---

## ConfigService Contract

Handles configuration CRUD operations.

### Methods

#### `getAllConfigurations`
```dart
Future<List<Configuration>> getAllConfigurations();
```

**Output**: All configurations from both locations

---

#### `getConfigurationsByType`
```dart
Future<List<Configuration>> getConfigurationsByType(ConfigurationType type);
```

**Input**: Configuration type

**Output**: Configurations of specified type

---

#### `getConfigurationsByLocation`
```dart
Future<List<Configuration>> getConfigurationsByLocation(ConfigurationLocation location);
```

**Input**: Location (project/personal)

**Output**: Configurations from specified location

---

#### `getConfiguration`
```dart
Future<Configuration?> getConfiguration(String id);
```

**Input**: Configuration ID

**Output**: Configuration or null if not found

---

#### `createConfiguration`
```dart
Future<Configuration> createConfiguration({
  required String name,
  required ConfigurationType type,
  required ConfigurationLocation location,
  required String content,
  String? description,
});
```

**Input**:
- `name`: Configuration name
- `type`: Configuration type
- `location`: Target location
- `content`: Configuration content
- `description`: Optional description

**Output**: Created configuration

**Errors**:
- `DuplicateNameException`: Name already exists for type+location
- `ValidationException`: Content validation failed

---

#### `updateConfiguration`
```dart
Future<Configuration> updateConfiguration({
  required String id,
  required String content,
  String? name,
  String? description,
});
```

**Input**:
- `id`: Configuration ID
- `content`: New content
- `name`: Optional new name
- `description`: Optional new description

**Output**: Updated configuration

**Errors**:
- `NotFoundException`: Configuration not found
- `ValidationException`: Content validation failed
- `DuplicateNameException`: New name conflicts

---

#### `deleteConfiguration`
```dart
Future<void> deleteConfiguration(String id);
```

**Input**: Configuration ID

**Output**: None (void)

**Errors**:
- `NotFoundException`: Configuration not found

---

## ValidationService Contract

Handles configuration syntax validation.

### Methods

#### `validate`
```dart
Future<ValidationResult> validate({
  required String content,
  required ConfigurationType type,
});
```

**Input**:
- `content`: Configuration content
- `type`: Configuration type (determines validation rules)

**Output**: Validation result with status and errors

---

#### `validateFile`
```dart
Future<ValidationResult> validateFile(String filePath);
```

**Input**: File path

**Output**: Validation result

---

### ValidationResult Structure

```dart
class ValidationResult {
  final ValidationStatus status;
  final List<ValidationError> errors;
  final List<ValidationError> warnings;
  
  bool get isValid => status == ValidationStatus.valid;
}
```

---

## SearchService Contract

Handles search and filtering.

### Methods

#### `search`
```dart
List<Configuration> search({
  required List<Configuration> configurations,
  required String query,
});
```

**Input**:
- `configurations`: List to search
- `query`: Search term

**Output**: Matching configurations (name or description contains query)

---

#### `filter`
```dart
List<Configuration> filter({
  required List<Configuration> configurations,
  ConfigurationType? type,
  ConfigurationLocation? location,
  ValidationStatus? status,
});
```

**Input**:
- `configurations`: List to filter
- `type`: Optional type filter
- `location`: Optional location filter
- `status`: Optional status filter

**Output**: Filtered configurations

---

## Error Types

```dart
abstract class AppException implements Exception {
  String get message;
}

class NotFoundException extends AppException {
  final String resourceType;
  final String identifier;
}

class DuplicateNameException extends AppException {
  final String name;
  final ConfigurationType type;
  final ConfigurationLocation location;
}

class ValidationException extends AppException {
  final List<ValidationError> errors;
}

class FileSystemException extends AppException {
  final String path;
  final String operation;
}

class DirectoryNotFoundException extends FileSystemException {}
class FileNotFoundException extends FileSystemException {}
class PermissionDeniedException extends FileSystemException {}
class InvalidEncodingException extends FileSystemException {}
```

---

## State Management Contracts

### ConfigurationState

```dart
class ConfigurationState {
  final List<Configuration> configurations;
  final bool isLoading;
  final String? error;
  final Configuration? selectedConfiguration;
}
```

### FilterState

```dart
class FilterState {
  final String searchQuery;
  final ConfigurationType? typeFilter;
  final ConfigurationLocation? locationFilter;
  final ValidationStatus? statusFilter;
}
```
