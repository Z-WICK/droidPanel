import 'dart:convert';
import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/exceptions.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';
import 'package:droid_config_panel/utils/yaml_utils.dart';

class ConfigService {
  final FileService _fileService;
  final ValidationService _validationService;

  ConfigService({
    FileService? fileService,
    ValidationService? validationService,
  })  : _fileService = fileService ?? FileService(),
        _validationService = validationService ?? ValidationService();

  Future<List<Configuration>> getAllConfigurations() async {
    final configurations = <Configuration>[];

    for (final location in ConfigurationLocation.values) {
      for (final type in ConfigurationType.values) {
        final configs = await _getConfigurationsForTypeAndLocation(type, location);
        configurations.addAll(configs);
      }
    }

    return configurations;
  }

  Future<List<Configuration>> getConfigurationsByType(ConfigurationType type) async {
    final configurations = <Configuration>[];

    for (final location in ConfigurationLocation.values) {
      final configs = await _getConfigurationsForTypeAndLocation(type, location);
      configurations.addAll(configs);
    }

    return configurations;
  }

  Future<List<Configuration>> getConfigurationsByLocation(ConfigurationLocation location) async {
    final configurations = <Configuration>[];

    for (final type in ConfigurationType.values) {
      final configs = await _getConfigurationsForTypeAndLocation(type, location);
      configurations.addAll(configs);
    }

    return configurations;
  }

  Future<Configuration?> getConfiguration(String id) async {
    final allConfigs = await getAllConfigurations();
    try {
      return allConfigs.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Configuration> createConfiguration({
    required String name,
    required ConfigurationType type,
    required ConfigurationLocation location,
    required String content,
    String? description,
  }) async {
    final exists = await _fileService.configurationExists(
      location: location,
      type: type,
      name: name,
    );

    if (exists) {
      throw DuplicateNameException(name: name, type: type, location: location);
    }

    final validationResult = await _validationService.validate(
      content: content,
      type: type,
    );

    if (!validationResult.isValid) {
      throw ValidationException(errors: validationResult.errors);
    }

    final filePath = _fileService.buildFilePath(
      location: location,
      type: type,
      name: name,
    );

    await _fileService.writeConfiguration(filePath, content);

    final fileInfo = await _fileService.getFileInfo(filePath);

    return Configuration(
      id: Configuration.generateId(filePath),
      name: name,
      type: type,
      description: description ?? '',
      location: location,
      filePath: filePath,
      content: content,
      status: ValidationStatus.valid,
      createdAt: fileInfo.created,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<Configuration> updateConfiguration({
    required String id,
    required String content,
    String? name,
    String? description,
  }) async {
    final config = await getConfiguration(id);
    if (config == null) {
      throw NotFoundException(resourceType: 'Configuration', identifier: id);
    }

    final validationResult = await _validationService.validate(
      content: content,
      type: config.type,
    );

    if (!validationResult.isValid) {
      throw ValidationException(errors: validationResult.errors);
    }

    String filePath = config.filePath;

    if (name != null && name != config.name) {
      final exists = await _fileService.configurationExists(
        location: config.location,
        type: config.type,
        name: name,
      );

      if (exists) {
        throw DuplicateNameException(
          name: name,
          type: config.type,
          location: config.location,
        );
      }

      await _fileService.deleteConfiguration(config.filePath);
      filePath = _fileService.buildFilePath(
        location: config.location,
        type: config.type,
        name: name,
      );
    }

    await _fileService.writeConfiguration(filePath, content);

    final fileInfo = await _fileService.getFileInfo(filePath);

    return Configuration(
      id: Configuration.generateId(filePath),
      name: name ?? config.name,
      type: config.type,
      description: description ?? config.description,
      location: config.location,
      filePath: filePath,
      content: content,
      status: ValidationStatus.valid,
      createdAt: config.createdAt,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<void> deleteConfiguration(String id) async {
    final config = await getConfiguration(id);
    if (config == null) {
      throw NotFoundException(resourceType: 'Configuration', identifier: id);
    }

    await _fileService.deleteConfiguration(config.filePath);
  }

  Future<List<Configuration>> _getConfigurationsForTypeAndLocation(
    ConfigurationType type,
    ConfigurationLocation location,
  ) async {
    // Special handling for MCP servers (stored in mcp.json)
    if (type == ConfigurationType.mcpServer) {
      return _getMcpServerConfigurations(location);
    }

    // Special handling for Hooks (stored in hooks/hooks.json)
    if (type == ConfigurationType.hook) {
      return _getHookConfigurations(location);
    }

    final configurations = <Configuration>[];

    try {
      final files = await _fileService.listConfigurations(
        location: location,
        type: type,
      );

      for (final file in files) {
        try {
          final content = await _fileService.readConfiguration(file.path);
          final config = _parseConfiguration(
            filePath: file.path,
            content: content,
            type: type,
            location: location,
            fileInfo: file,
          );
          configurations.add(config);
        } catch (_) {
          configurations.add(Configuration(
            id: Configuration.generateId(file.path),
            name: file.name,
            type: type,
            description: 'Error reading configuration',
            location: location,
            filePath: file.path,
            content: '',
            status: ValidationStatus.invalid,
            createdAt: file.created,
            modifiedAt: file.modified,
          ));
        }
      }
    } catch (_) {
      // Directory doesn't exist or can't be read
    }

    return configurations;
  }

  Future<List<Configuration>> _getMcpServerConfigurations(
    ConfigurationLocation location,
  ) async {
    final configurations = <Configuration>[];

    try {
      final servers = await _fileService.listMcpServers(location: location);

      for (final server in servers) {
        final content = const JsonEncoder.withIndent('  ').convert(server.config);
        final disabled = server.config['disabled'] == true;
        final description = disabled ? '(Disabled)' : (server.config['type']?.toString() ?? 'stdio');

        configurations.add(Configuration(
          id: Configuration.generateId('${server.sourcePath}#${server.name}'),
          name: server.name,
          type: ConfigurationType.mcpServer,
          description: description,
          location: location,
          filePath: server.sourcePath,
          content: content,
          status: disabled ? ValidationStatus.invalid : ValidationStatus.valid,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ));
      }
    } catch (_) {
      // mcp.json doesn't exist or can't be read
    }

    return configurations;
  }

  Future<List<Configuration>> _getHookConfigurations(
    ConfigurationLocation location,
  ) async {
    final configurations = <Configuration>[];

    try {
      final hooks = await _fileService.listHooks(location: location);

      for (final hook in hooks) {
        final content = const JsonEncoder.withIndent('  ').convert(hook.config);
        final matcher = hook.config['matcher']?.toString() ?? '*';

        configurations.add(Configuration(
          id: Configuration.generateId('${hook.sourcePath}#${hook.name}'),
          name: hook.name,
          type: ConfigurationType.hook,
          description: 'Event: ${hook.eventType}, Matcher: $matcher',
          location: location,
          filePath: hook.sourcePath,
          content: content,
          status: ValidationStatus.valid,
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ));
      }
    } catch (_) {
      // hooks.json doesn't exist or can't be read
    }

    return configurations;
  }

  Configuration _parseConfiguration({
    required String filePath,
    required String content,
    required ConfigurationType type,
    required ConfigurationLocation location,
    required FileInfo fileInfo,
  }) {
    String name = fileInfo.name;
    String description = '';

    if (type == ConfigurationType.droid ||
        type == ConfigurationType.skill) {
      final parsed = YamlUtils.parseMarkdownWithFrontmatter(content);
      if (parsed.frontmatter != null) {
        name = parsed.frontmatter!['name']?.toString() ?? fileInfo.name;
        description = parsed.frontmatter!['description']?.toString() ?? '';
      }
    } else {
      final parsed = YamlUtils.parseYaml(content);
      if (parsed != null) {
        name = parsed['name']?.toString() ?? fileInfo.name;
        description = parsed['description']?.toString() ?? '';
      }
    }

    return Configuration(
      id: Configuration.generateId(filePath),
      name: name,
      type: type,
      description: description,
      location: location,
      filePath: filePath,
      content: content,
      status: ValidationStatus.unknown,
      createdAt: fileInfo.created,
      modifiedAt: fileInfo.modified,
    );
  }
}
