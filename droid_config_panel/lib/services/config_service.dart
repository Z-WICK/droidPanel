import 'dart:convert';

import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/exceptions.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';
import 'package:droid_config_panel/utils/yaml_utils.dart';

class ConfigService {
  final FileService _fileService;
  final ValidationService _validationService;

  ConfigService({
    FileService? fileService,
    ValidationService? validationService,
  }) : _fileService = fileService ?? FileService(),
       _validationService = validationService ?? ValidationService();

  static const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  Future<List<Configuration>> getAllConfigurations() async {
    final configurations = <Configuration>[];

    for (final location in ConfigurationLocation.values) {
      for (final type in ConfigurationType.values) {
        final configs = await _getConfigurationsForTypeAndLocation(
          type,
          location,
        );
        configurations.addAll(configs);
      }
    }

    return _deduplicateOverlappingLocations(configurations);
  }

  Future<List<Configuration>> getConfigurationsByType(
    ConfigurationType type,
  ) async {
    final configurations = <Configuration>[];

    for (final location in ConfigurationLocation.values) {
      final configs = await _getConfigurationsForTypeAndLocation(
        type,
        location,
      );
      configurations.addAll(configs);
    }

    return _deduplicateOverlappingLocations(configurations);
  }

  Future<List<Configuration>> getConfigurationsByLocation(
    ConfigurationLocation location,
  ) async {
    final configurations = <Configuration>[];

    for (final type in ConfigurationType.values) {
      final configs = await _getConfigurationsForTypeAndLocation(
        type,
        location,
      );
      configurations.addAll(configs);
    }

    _sortConfigurations(configurations);
    return configurations;
  }

  Future<Configuration?> getConfiguration(String id) async {
    final allConfigs = await getAllConfigurations();
    for (final config in allConfigs) {
      if (config.id == id) {
        return config;
      }
    }
    return null;
  }

  Future<Configuration> createConfiguration({
    required String name,
    required ConfigurationType type,
    required ConfigurationLocation location,
    required String content,
    String? description,
  }) async {
    final trimmedName = name.trim();
    final normalizedDescription = description?.trim();

    switch (type) {
      case ConfigurationType.mcpServer:
        return _createMcpServerConfiguration(
          name: trimmedName,
          location: location,
          content: content,
          description: normalizedDescription,
        );
      case ConfigurationType.hook:
        return _createHookConfiguration(
          name: trimmedName,
          location: location,
          content: content,
          description: normalizedDescription,
        );
      case ConfigurationType.droid:
      case ConfigurationType.skill:
        return _createFileConfiguration(
          name: trimmedName,
          type: type,
          location: location,
          content: content,
          description: normalizedDescription,
        );
    }
  }

  Future<Configuration> updateConfiguration({
    required String id,
    required String content,
    String? name,
    String? description,
    DateTime? expectedModifiedAt,
  }) async {
    final config = await getConfiguration(id);
    if (config == null) {
      throw NotFoundException(resourceType: 'Configuration', identifier: id);
    }

    switch (config.type) {
      case ConfigurationType.mcpServer:
        return _updateMcpServerConfiguration(
          config: config,
          content: content,
          name: name?.trim(),
          description: description?.trim(),
          expectedModifiedAt: expectedModifiedAt,
        );
      case ConfigurationType.hook:
        return _updateHookConfiguration(
          config: config,
          content: content,
          name: name?.trim(),
          description: description?.trim(),
          expectedModifiedAt: expectedModifiedAt,
        );
      case ConfigurationType.droid:
      case ConfigurationType.skill:
        return _updateFileConfiguration(
          config: config,
          content: content,
          name: name?.trim(),
          description: description?.trim(),
          expectedModifiedAt: expectedModifiedAt,
        );
    }
  }

  Future<void> deleteConfiguration(String id) async {
    final config = await getConfiguration(id);
    if (config == null) {
      throw NotFoundException(resourceType: 'Configuration', identifier: id);
    }

    switch (config.type) {
      case ConfigurationType.mcpServer:
        final deleted = await _fileService.deleteMcpServer(
          location: config.location,
          name: config.name,
        );
        if (!deleted) {
          throw NotFoundException(
            resourceType: 'MCP Server',
            identifier: config.name,
          );
        }
        return;
      case ConfigurationType.hook:
        final hookRef = _decodeHookId(config.id);
        if (hookRef == null) {
          throw NotFoundException(resourceType: 'Hook', identifier: config.id);
        }
        final deleted = await _fileService.deleteHook(
          location: config.location,
          eventType: hookRef.eventType,
          index: hookRef.index,
        );
        if (!deleted) {
          throw NotFoundException(resourceType: 'Hook', identifier: config.id);
        }
        return;
      case ConfigurationType.droid:
      case ConfigurationType.skill:
        await _fileService.deleteConfiguration(config.filePath);
        return;
    }
  }

  Future<Configuration> _createFileConfiguration({
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

    final mergedContent = _applyMetadataToContent(
      type: type,
      content: content,
      name: name,
      description: description,
    );

    await _ensureValid(mergedContent, type);

    final filePath = _fileService.buildFilePath(
      location: location,
      type: type,
      name: name,
    );

    await _fileService.writeConfiguration(filePath, mergedContent);
    final fileInfo = await _fileService.getFileInfo(filePath);

    return Configuration(
      id: Configuration.generateId(filePath),
      name: name,
      type: type,
      description: description ?? '',
      location: location,
      filePath: filePath,
      content: mergedContent,
      status: ValidationStatus.valid,
      createdAt: fileInfo.created,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<Configuration> _updateFileConfiguration({
    required Configuration config,
    required String content,
    String? name,
    String? description,
    DateTime? expectedModifiedAt,
  }) async {
    await _assertNotModifiedSince(
      config: config,
      expectedModifiedAt: expectedModifiedAt,
    );

    final targetName = (name == null || name.isEmpty) ? config.name : name;

    if (targetName != config.name) {
      final exists = await _fileService.configurationExists(
        location: config.location,
        type: config.type,
        name: targetName,
      );

      if (exists) {
        throw DuplicateNameException(
          name: targetName,
          type: config.type,
          location: config.location,
        );
      }
    }

    final mergedContent = _applyMetadataToContent(
      type: config.type,
      content: content,
      name: targetName,
      description: description,
    );

    await _ensureValid(mergedContent, config.type);

    final newFilePath = targetName == config.name
        ? config.filePath
        : _fileService.buildFilePath(
            location: config.location,
            type: config.type,
            name: targetName,
          );

    await _fileService.writeConfiguration(newFilePath, mergedContent);
    if (newFilePath != config.filePath) {
      await _fileService.deleteConfiguration(config.filePath);
    }

    final fileInfo = await _fileService.getFileInfo(newFilePath);

    return Configuration(
      id: Configuration.generateId(newFilePath),
      name: targetName,
      type: config.type,
      description: description ?? config.description,
      location: config.location,
      filePath: newFilePath,
      content: mergedContent,
      status: ValidationStatus.valid,
      createdAt: config.createdAt,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<Configuration> _createMcpServerConfiguration({
    required String name,
    required ConfigurationLocation location,
    required String content,
    String? description,
  }) async {
    final parsed = _parseStructuredMap(content);
    final serverName = (parsed['name']?.toString().trim().isNotEmpty ?? false)
        ? parsed['name'].toString().trim()
        : name;
    if (serverName.isEmpty) {
      throw ValidationException(
        errors: const [ValidationError(message: 'MCP Server name is required')],
      );
    }

    final exists = await _fileService.mcpServerExists(
      location: location,
      name: serverName,
    );
    if (exists) {
      throw DuplicateNameException(
        name: serverName,
        type: ConfigurationType.mcpServer,
        location: location,
      );
    }

    parsed.remove('name');
    if (description != null && description.isNotEmpty) {
      parsed['description'] = description;
    }

    final validationContent = _jsonEncoder.convert({
      'name': serverName,
      ...parsed,
    });
    await _ensureValid(validationContent, ConfigurationType.mcpServer);

    final server = await _fileService.upsertMcpServer(
      location: location,
      name: serverName,
      config: parsed,
    );
    final fileInfo = await _fileService.getFileInfo(server.sourcePath);
    final resultContent = _jsonEncoder.convert({'name': serverName, ...parsed});

    return Configuration(
      id: _buildMcpId(location, serverName),
      name: serverName,
      type: ConfigurationType.mcpServer,
      description: _buildMcpDescription(parsed),
      location: location,
      filePath: server.sourcePath,
      content: resultContent,
      status: ValidationStatus.valid,
      createdAt: fileInfo.created,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<Configuration> _updateMcpServerConfiguration({
    required Configuration config,
    required String content,
    String? name,
    String? description,
    DateTime? expectedModifiedAt,
  }) async {
    await _assertNotModifiedSince(
      config: config,
      expectedModifiedAt: expectedModifiedAt,
    );

    final parsed = _parseStructuredMap(content);
    final targetName = (name?.isNotEmpty ?? false)
        ? name!
        : (parsed['name']?.toString().trim().isNotEmpty ?? false)
        ? parsed['name'].toString().trim()
        : config.name;

    if (targetName != config.name) {
      final exists = await _fileService.mcpServerExists(
        location: config.location,
        name: targetName,
      );
      if (exists) {
        throw DuplicateNameException(
          name: targetName,
          type: ConfigurationType.mcpServer,
          location: config.location,
        );
      }
    }

    parsed.remove('name');
    if (description != null && description.isNotEmpty) {
      parsed['description'] = description;
    }

    final validationContent = _jsonEncoder.convert({
      'name': targetName,
      ...parsed,
    });
    await _ensureValid(validationContent, ConfigurationType.mcpServer);

    await _fileService.upsertMcpServer(
      location: config.location,
      name: targetName,
      config: parsed,
      previousName: config.name,
    );

    final fileInfo = await _fileService.getFileInfo(config.filePath);
    final resultContent = _jsonEncoder.convert({'name': targetName, ...parsed});

    return Configuration(
      id: _buildMcpId(config.location, targetName),
      name: targetName,
      type: ConfigurationType.mcpServer,
      description: _buildMcpDescription(parsed),
      location: config.location,
      filePath: config.filePath,
      content: resultContent,
      status: ValidationStatus.valid,
      createdAt: config.createdAt,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<Configuration> _createHookConfiguration({
    required String name,
    required ConfigurationLocation location,
    required String content,
    String? description,
  }) async {
    final parsed = _parseStructuredMap(content);
    final eventType = parsed.remove('event')?.toString().trim();
    if (eventType == null || eventType.isEmpty) {
      throw ValidationException(
        errors: const [
          ValidationError(message: 'Hook field "event" is required'),
        ],
      );
    }

    final hookName = (name.isNotEmpty)
        ? name
        : parsed['name']?.toString().trim().isNotEmpty == true
        ? parsed['name'].toString().trim()
        : parsed['matcher']?.toString().trim() ?? '';

    if (hookName.isEmpty) {
      throw ValidationException(
        errors: const [ValidationError(message: 'Hook name is required')],
      );
    }

    if (await _fileService.hookExists(
      location: location,
      eventType: eventType,
      matcherOrName: hookName,
    )) {
      throw DuplicateNameException(
        name: hookName,
        type: ConfigurationType.hook,
        location: location,
      );
    }

    parsed['name'] = hookName;
    parsed.putIfAbsent('matcher', () => hookName);
    if (description != null && description.isNotEmpty) {
      parsed['description'] = description;
    }

    final validationContent = _jsonEncoder.convert({
      'event': eventType,
      ...parsed,
    });
    await _ensureValid(validationContent, ConfigurationType.hook);

    final hook = await _fileService.addHook(
      location: location,
      eventType: eventType,
      hookConfig: parsed,
    );
    final fileInfo = await _fileService.getFileInfo(hook.sourcePath);
    final resultContent = _jsonEncoder.convert({
      'event': hook.eventType,
      ...hook.config,
    });

    return Configuration(
      id: _buildHookId(location, hook.eventType, hook.index),
      name: hookName,
      type: ConfigurationType.hook,
      description: _buildHookDescription(hook.eventType, hook.config),
      location: location,
      filePath: hook.sourcePath,
      content: resultContent,
      status: ValidationStatus.valid,
      createdAt: fileInfo.created,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<Configuration> _updateHookConfiguration({
    required Configuration config,
    required String content,
    String? name,
    String? description,
    DateTime? expectedModifiedAt,
  }) async {
    await _assertNotModifiedSince(
      config: config,
      expectedModifiedAt: expectedModifiedAt,
    );

    final ref = _decodeHookId(config.id);
    if (ref == null) {
      throw NotFoundException(resourceType: 'Hook', identifier: config.id);
    }

    final parsed = _parseStructuredMap(content);
    final targetEvent = parsed.remove('event')?.toString().trim();
    final eventType = (targetEvent == null || targetEvent.isEmpty)
        ? ref.eventType
        : targetEvent;

    final hookName = (name?.isNotEmpty ?? false)
        ? name!
        : parsed['name']?.toString().trim().isNotEmpty == true
        ? parsed['name'].toString().trim()
        : config.name;

    parsed['name'] = hookName;
    parsed.putIfAbsent('matcher', () => hookName);
    if (description != null && description.isNotEmpty) {
      parsed['description'] = description;
    }

    final validationContent = _jsonEncoder.convert({
      'event': eventType,
      ...parsed,
    });
    await _ensureValid(validationContent, ConfigurationType.hook);

    final hook = await _fileService.updateHook(
      location: config.location,
      sourceEventType: ref.eventType,
      sourceIndex: ref.index,
      targetEventType: eventType,
      hookConfig: parsed,
    );

    final fileInfo = await _fileService.getFileInfo(hook.sourcePath);
    final resultContent = _jsonEncoder.convert({
      'event': hook.eventType,
      ...hook.config,
    });

    return Configuration(
      id: _buildHookId(config.location, hook.eventType, hook.index),
      name: hookName,
      type: ConfigurationType.hook,
      description: _buildHookDescription(hook.eventType, hook.config),
      location: config.location,
      filePath: hook.sourcePath,
      content: resultContent,
      status: ValidationStatus.valid,
      createdAt: config.createdAt,
      modifiedAt: fileInfo.modified,
    );
  }

  Future<List<Configuration>> _getConfigurationsForTypeAndLocation(
    ConfigurationType type,
    ConfigurationLocation location,
  ) async {
    if (type == ConfigurationType.mcpServer) {
      return _getMcpServerConfigurations(location);
    }
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
          final validation = await _validationService.validate(
            content: content,
            type: type,
          );
          final config = _parseConfiguration(
            filePath: file.path,
            content: content,
            type: type,
            location: location,
            fileInfo: file,
          ).copyWith(status: validation.status);
          configurations.add(config);
        } catch (_) {
          configurations.add(
            Configuration(
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
            ),
          );
        }
      }
    } catch (_) {
      // Missing directory is treated as empty dataset.
    }

    _sortConfigurations(configurations);
    return configurations;
  }

  Future<List<Configuration>> _getMcpServerConfigurations(
    ConfigurationLocation location,
  ) async {
    final configurations = <Configuration>[];

    try {
      final servers = await _fileService.listMcpServers(location: location);
      FileInfo? sourceFile;
      if (servers.isNotEmpty) {
        sourceFile = await _safeGetFileInfo(servers.first.sourcePath);
      }

      for (final server in servers) {
        final merged = <String, dynamic>{'name': server.name, ...server.config};
        final content = _jsonEncoder.convert(merged);
        final validation = await _validationService.validate(
          content: content,
          type: ConfigurationType.mcpServer,
        );

        configurations.add(
          Configuration(
            id: _buildMcpId(location, server.name),
            name: server.name,
            type: ConfigurationType.mcpServer,
            description: _buildMcpDescription(server.config),
            location: location,
            filePath: server.sourcePath,
            content: content,
            status: validation.status,
            createdAt: sourceFile?.created ?? DateTime.now(),
            modifiedAt: sourceFile?.modified ?? DateTime.now(),
          ),
        );
      }
    } catch (_) {
      // Missing or malformed mcp.json is treated as empty.
    }

    _sortConfigurations(configurations);
    return configurations;
  }

  Future<List<Configuration>> _getHookConfigurations(
    ConfigurationLocation location,
  ) async {
    final configurations = <Configuration>[];

    try {
      final hooks = await _fileService.listHooks(location: location);
      FileInfo? sourceFile;
      if (hooks.isNotEmpty) {
        sourceFile = await _safeGetFileInfo(hooks.first.sourcePath);
      }

      for (final hook in hooks) {
        final merged = <String, dynamic>{
          'event': hook.eventType,
          ...hook.config,
        };
        final content = _jsonEncoder.convert(merged);
        final validation = await _validationService.validate(
          content: content,
          type: ConfigurationType.hook,
        );

        configurations.add(
          Configuration(
            id: _buildHookId(location, hook.eventType, hook.index),
            name: hook.name,
            type: ConfigurationType.hook,
            description: _buildHookDescription(hook.eventType, hook.config),
            location: location,
            filePath: hook.sourcePath,
            content: content,
            status: validation.status,
            createdAt: sourceFile?.created ?? DateTime.now(),
            modifiedAt: sourceFile?.modified ?? DateTime.now(),
          ),
        );
      }
    } catch (_) {
      // Missing or malformed hooks.json is treated as empty.
    }

    _sortConfigurations(configurations);
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

    if (type == ConfigurationType.droid || type == ConfigurationType.skill) {
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

  Future<void> _ensureValid(String content, ConfigurationType type) async {
    final validationResult = await _validationService.validate(
      content: content,
      type: type,
    );

    if (!validationResult.isValid) {
      throw ValidationException(errors: validationResult.errors);
    }
  }

  Map<String, dynamic> _parseStructuredMap(String content) {
    final yaml = YamlUtils.parseYaml(content);
    if (yaml != null) {
      return Map<String, dynamic>.from(yaml);
    }

    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // Fallback below.
    }

    throw ValidationException(
      errors: const [
        ValidationError(message: 'Content must be a valid YAML/JSON object'),
      ],
    );
  }

  String _applyMetadataToContent({
    required ConfigurationType type,
    required String content,
    required String name,
    String? description,
  }) {
    if (type != ConfigurationType.droid && type != ConfigurationType.skill) {
      return content;
    }

    final parsed = YamlUtils.parseMarkdownWithFrontmatter(content);
    final frontmatter = parsed.frontmatter;
    if (frontmatter == null) {
      return content;
    }

    final updatedFrontmatter = Map<String, dynamic>.from(frontmatter);
    updatedFrontmatter['name'] = name;
    if (description != null && description.isNotEmpty) {
      updatedFrontmatter['description'] = description;
    }

    return YamlUtils.generateMarkdownWithFrontmatter(
      updatedFrontmatter,
      parsed.body,
    );
  }

  String _buildMcpId(ConfigurationLocation location, String name) {
    return 'mcp:${location.name}:${Uri.encodeComponent(name)}';
  }

  String _buildHookId(
    ConfigurationLocation location,
    String eventType,
    int index,
  ) {
    return 'hook:${location.name}:${Uri.encodeComponent(eventType)}:$index';
  }

  ({String eventType, int index})? _decodeHookId(String id) {
    final parts = id.split(':');
    if (parts.length != 4 || parts.first != 'hook') {
      return null;
    }

    final eventType = Uri.decodeComponent(parts[2]);
    final index = int.tryParse(parts[3]);
    if (index == null) {
      return null;
    }

    return (eventType: eventType, index: index);
  }

  String _buildMcpDescription(Map<String, dynamic> config) {
    final disabled = config['disabled'] == true;
    if (disabled) {
      return '(Disabled)';
    }
    return config['type']?.toString() ??
        config['description']?.toString() ??
        'stdio';
  }

  String _buildHookDescription(String eventType, Map<String, dynamic> config) {
    final matcher = config['matcher']?.toString() ?? '*';
    return 'Event: $eventType, Matcher: $matcher';
  }

  Future<FileInfo?> _safeGetFileInfo(String path) async {
    try {
      return await _fileService.getFileInfo(path);
    } catch (_) {
      return null;
    }
  }

  Future<void> _assertNotModifiedSince({
    required Configuration config,
    DateTime? expectedModifiedAt,
  }) async {
    if (expectedModifiedAt == null) {
      return;
    }

    final fileInfo = await _safeGetFileInfo(config.filePath);
    if (fileInfo == null) {
      throw ConcurrentModificationException(
        resourceType: config.type.displayName,
        identifier: config.name,
      );
    }

    final expected = expectedModifiedAt.toUtc();
    final actual = fileInfo.modified.toUtc();

    if (actual.isAfter(expected.add(const Duration(milliseconds: 1)))) {
      throw ConcurrentModificationException(
        resourceType: config.type.displayName,
        identifier: config.name,
      );
    }
  }

  void _sortConfigurations(List<Configuration> configurations) {
    configurations.sort((a, b) {
      final modifiedCompare = b.modifiedAt.compareTo(a.modifiedAt);
      if (modifiedCompare != 0) {
        return modifiedCompare;
      }

      final typeCompare = a.type.index.compareTo(b.type.index);
      if (typeCompare != 0) {
        return typeCompare;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  List<Configuration> _deduplicateOverlappingLocations(
    List<Configuration> configurations,
  ) {
    final deduplicated = <String, Configuration>{};

    for (final config in configurations) {
      final key = _buildLocationAgnosticKey(config);
      final existing = deduplicated[key];

      if (existing == null) {
        deduplicated[key] = config;
        continue;
      }

      // When project/personal accidentally point to the same .factory path,
      // keep a single entry and prefer project scope.
      if (existing.location == ConfigurationLocation.personal &&
          config.location == ConfigurationLocation.project) {
        deduplicated[key] = config;
      }
    }

    final result = deduplicated.values.toList();
    _sortConfigurations(result);
    return result;
  }

  String _buildLocationAgnosticKey(Configuration config) {
    final normalizedPath = config.filePath.replaceAll('\\', '/').toLowerCase();
    return [
      config.type.name,
      normalizedPath,
      config.name,
      config.content,
    ].join('|');
  }
}
