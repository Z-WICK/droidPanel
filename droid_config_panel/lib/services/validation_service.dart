import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/utils/yaml_utils.dart';
import 'package:droid_config_panel/services/file_service.dart';

class ValidationService {
  final FileService _fileService;

  ValidationService({FileService? fileService})
      : _fileService = fileService ?? FileService();

  Future<ValidationResult> validate({
    required String content,
    required ConfigurationType type,
  }) async {
    final errors = <ValidationError>[];
    final warnings = <ValidationError>[];

    if (content.trim().isEmpty) {
      errors.add(const ValidationError(
        message: 'Configuration content cannot be empty',
        severity: ValidationSeverity.error,
      ));
      return ValidationResult.invalid(errors);
    }

    switch (type) {
      case ConfigurationType.droid:
      case ConfigurationType.skill:
        _validateMarkdownWithFrontmatter(content, type, errors, warnings);
        break;
      case ConfigurationType.agent:
        if (content.trim().startsWith('---')) {
          _validateMarkdownWithFrontmatter(content, type, errors, warnings);
        } else {
          _validateYaml(content, type, errors, warnings);
        }
        break;
      case ConfigurationType.hook:
      case ConfigurationType.mcpServer:
        _validateYaml(content, type, errors, warnings);
        break;
    }

    if (errors.isEmpty) {
      return ValidationResult.valid();
    }
    return ValidationResult.invalid(errors, warnings);
  }

  Future<ValidationResult> validateFile(String filePath) async {
    try {
      final content = await _fileService.readConfiguration(filePath);
      final type = _detectTypeFromPath(filePath);
      return validate(content: content, type: type);
    } catch (e) {
      return ValidationResult.invalid([
        ValidationError(
          message: 'Failed to read file: $e',
          severity: ValidationSeverity.error,
        ),
      ]);
    }
  }

  void _validateMarkdownWithFrontmatter(
    String content,
    ConfigurationType type,
    List<ValidationError> errors,
    List<ValidationError> warnings,
  ) {
    final parsed = YamlUtils.parseMarkdownWithFrontmatter(content);

    if (parsed.frontmatter == null) {
      errors.add(const ValidationError(
        message: 'Missing YAML frontmatter (must start with ---)',
        line: 1,
        severity: ValidationSeverity.error,
      ));
      return;
    }

    final frontmatter = parsed.frontmatter!;

    if (!frontmatter.containsKey('name') || 
        frontmatter['name'] == null || 
        frontmatter['name'].toString().trim().isEmpty) {
      errors.add(const ValidationError(
        message: 'Required field "name" is missing or empty in frontmatter',
        severity: ValidationSeverity.error,
      ));
    }

    if (!frontmatter.containsKey('description') || 
        frontmatter['description'] == null || 
        frontmatter['description'].toString().trim().isEmpty) {
      warnings.add(const ValidationError(
        message: 'Field "description" is recommended but missing',
        severity: ValidationSeverity.warning,
      ));
    }

    if (type == ConfigurationType.agent) {
      if (!frontmatter.containsKey('subagent_type')) {
        errors.add(const ValidationError(
          message: 'Required field "subagent_type" is missing for Agent configuration',
          severity: ValidationSeverity.error,
        ));
      }
    }
  }

  void _validateYaml(
    String content,
    ConfigurationType type,
    List<ValidationError> errors,
    List<ValidationError> warnings,
  ) {
    final parsed = YamlUtils.parseYaml(content);

    if (parsed == null) {
      errors.add(const ValidationError(
        message: 'Invalid YAML syntax',
        severity: ValidationSeverity.error,
      ));
      return;
    }

    if (!parsed.containsKey('name') || 
        parsed['name'] == null || 
        parsed['name'].toString().trim().isEmpty) {
      errors.add(const ValidationError(
        message: 'Required field "name" is missing or empty',
        severity: ValidationSeverity.error,
      ));
    }

    switch (type) {
      case ConfigurationType.hook:
        if (!parsed.containsKey('event')) {
          errors.add(const ValidationError(
            message: 'Required field "event" is missing for Hook configuration',
            severity: ValidationSeverity.error,
          ));
        }
        if (!parsed.containsKey('action')) {
          errors.add(const ValidationError(
            message: 'Required field "action" is missing for Hook configuration',
            severity: ValidationSeverity.error,
          ));
        }
        break;
      case ConfigurationType.mcpServer:
        if (!parsed.containsKey('command') && !parsed.containsKey('url')) {
          errors.add(const ValidationError(
            message: 'Either "command" or "url" is required for MCP Server configuration',
            severity: ValidationSeverity.error,
          ));
        }
        break;
      case ConfigurationType.agent:
        if (!parsed.containsKey('subagent_type')) {
          errors.add(const ValidationError(
            message: 'Required field "subagent_type" is missing for Agent configuration',
            severity: ValidationSeverity.error,
          ));
        }
        if (!parsed.containsKey('prompt')) {
          errors.add(const ValidationError(
            message: 'Required field "prompt" is missing for Agent configuration',
            severity: ValidationSeverity.error,
          ));
        }
        break;
      default:
        break;
    }
  }

  ConfigurationType _detectTypeFromPath(String filePath) {
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.contains('/droids/')) return ConfigurationType.droid;
    if (lowerPath.contains('/skills/')) return ConfigurationType.skill;
    if (lowerPath.contains('/agents/')) return ConfigurationType.agent;
    if (lowerPath.contains('/hooks/')) return ConfigurationType.hook;
    if (lowerPath.contains('/mcp/')) return ConfigurationType.mcpServer;
    return ConfigurationType.droid;
  }
}
