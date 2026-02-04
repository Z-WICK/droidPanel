import 'package:droid_config_panel/models/enums.dart';

class ValidationError {
  final String message;
  final int? line;
  final int? column;
  final ValidationSeverity severity;

  const ValidationError({
    required this.message,
    this.line,
    this.column,
    this.severity = ValidationSeverity.error,
  });

  @override
  String toString() {
    final location = line != null ? ' (line $line${column != null ? ', col $column' : ''})' : '';
    return '${severity.displayName}: $message$location';
  }
}

class ValidationResult {
  final ValidationStatus status;
  final List<ValidationError> errors;
  final List<ValidationError> warnings;

  const ValidationResult({
    required this.status,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get isValid => status == ValidationStatus.valid;

  factory ValidationResult.valid() {
    return const ValidationResult(status: ValidationStatus.valid);
  }

  factory ValidationResult.invalid(List<ValidationError> errors, [List<ValidationError> warnings = const []]) {
    return ValidationResult(
      status: ValidationStatus.invalid,
      errors: errors,
      warnings: warnings,
    );
  }

  factory ValidationResult.unknown() {
    return const ValidationResult(status: ValidationStatus.unknown);
  }
}
