import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/validation_result.dart';

abstract class AppException implements Exception {
  String get message;

  @override
  String toString() => message;
}

class NotFoundException extends AppException {
  final String resourceType;
  final String identifier;

  NotFoundException({required this.resourceType, required this.identifier});

  @override
  String get message => '$resourceType not found: $identifier';
}

class DuplicateNameException extends AppException {
  final String name;
  final ConfigurationType type;
  final ConfigurationLocation location;

  DuplicateNameException({
    required this.name,
    required this.type,
    required this.location,
  });

  @override
  String get message =>
      'A ${type.displayName} named "$name" already exists in ${location.displayName} location';
}

class ConcurrentModificationException extends AppException {
  final String resourceType;
  final String identifier;

  ConcurrentModificationException({
    required this.resourceType,
    required this.identifier,
  });

  @override
  String get message =>
      '$resourceType "$identifier" was modified externally. Reload before saving.';
}

class ValidationException extends AppException {
  final List<ValidationError> errors;

  ValidationException({required this.errors});

  @override
  String get message =>
      'Validation failed: ${errors.map((e) => e.message).join(', ')}';
}

class FileSystemException extends AppException {
  final String path;
  final String operation;
  final String? details;

  FileSystemException({
    required this.path,
    required this.operation,
    this.details,
  });

  @override
  String get message =>
      'File system error during $operation on $path${details != null ? ': $details' : ''}';
}

class DirectoryNotFoundException extends FileSystemException {
  DirectoryNotFoundException({required super.path})
    : super(operation: 'access', details: 'Directory not found');
}

class FileNotFoundException extends FileSystemException {
  FileNotFoundException({required super.path})
    : super(operation: 'read', details: 'File not found');
}

class PermissionDeniedException extends FileSystemException {
  PermissionDeniedException({required super.path, required super.operation})
    : super(details: 'Permission denied');
}

class InvalidEncodingException extends FileSystemException {
  InvalidEncodingException({required super.path})
    : super(operation: 'read', details: 'Invalid UTF-8 encoding');
}
