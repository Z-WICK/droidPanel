import 'dart:io' as io;
import 'dart:convert';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/exceptions.dart';
import 'package:droid_config_panel/utils/constants.dart';
import 'package:path/path.dart' as p;

class FileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime created;
  final DateTime modified;

  FileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.created,
    required this.modified,
  });
}

class McpServerInfo {
  final String name;
  final Map<String, dynamic> config;
  final String sourcePath;

  McpServerInfo({
    required this.name,
    required this.config,
    required this.sourcePath,
  });
}

class HookInfo {
  final String name;
  final String eventType;
  final int index;
  final Map<String, dynamic> config;
  final String sourcePath;

  HookInfo({
    required this.name,
    required this.eventType,
    required this.index,
    required this.config,
    required this.sourcePath,
  });
}

class FileService {
  final String? projectBasePath;
  final String? personalBasePath;

  FileService({this.projectBasePath, this.personalBasePath});

  static const JsonEncoder _jsonEncoder = JsonEncoder.withIndent('  ');

  String _getBasePath(ConfigurationLocation location) {
    switch (location) {
      case ConfigurationLocation.project:
        return projectBasePath ?? io.Directory.current.path;
      case ConfigurationLocation.personal:
        return personalBasePath ?? AppConstants.homeDirectory;
    }
  }

  String _getConfigPath(
    ConfigurationLocation location,
    ConfigurationType type,
  ) {
    final basePath = _getBasePath(location);
    final factoryPath = location == ConfigurationLocation.project
        ? AppConstants.projectFactoryPath
        : '.factory';
    return p.join(basePath, factoryPath, type.directoryName);
  }

  String _getMcpJsonPath(ConfigurationLocation location) {
    final basePath = _getBasePath(location);
    final factoryPath = location == ConfigurationLocation.project
        ? AppConstants.projectFactoryPath
        : '.factory';
    return p.join(basePath, factoryPath, 'mcp.json');
  }

  Future<List<FileInfo>> listConfigurations({
    required ConfigurationLocation location,
    required ConfigurationType type,
  }) async {
    final dirPath = _getConfigPath(location, type);
    final dir = io.Directory(dirPath);

    if (!await dir.exists()) {
      return [];
    }

    final files = <FileInfo>[];
    final extensions = type.fileExtensions;

    try {
      await for (final entity in dir.list()) {
        // Handle direct files (e.g., droids/*.md)
        if (entity is io.File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (extensions.contains(ext)) {
            final stat = await entity.stat();
            files.add(
              FileInfo(
                path: entity.path,
                name: p.basenameWithoutExtension(entity.path),
                size: stat.size,
                created: stat.changed,
                modified: stat.modified,
              ),
            );
          }
        }
        // Handle directory-based configs (e.g., skills/skill-name/SKILL.md)
        else if (entity is io.Directory) {
          // Look for config files in subdirectory
          final possibleFiles = [
            'SKILL.md',
            'skill.md',
            'index.md',
            'README.md',
          ];
          for (final fileName in possibleFiles) {
            final configFile = io.File(p.join(entity.path, fileName));
            if (await configFile.exists()) {
              final stat = await configFile.stat();
              files.add(
                FileInfo(
                  path: configFile.path,
                  name: p.basename(entity.path),
                  size: stat.size,
                  created: stat.changed,
                  modified: stat.modified,
                ),
              );
              break; // Found one, stop looking
            }
          }
        }
      }
    } on io.FileSystemException {
      throw PermissionDeniedException(path: dirPath, operation: 'list');
    }

    return files;
  }

  Future<List<McpServerInfo>> listMcpServers({
    required ConfigurationLocation location,
  }) async {
    final mcpJsonPath = _getMcpJsonPath(location);
    final file = io.File(mcpJsonPath);

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final servers = _asStringDynamicMap(json['mcpServers']);

      return servers.entries.map((entry) {
        return McpServerInfo(
          name: entry.key,
          config: _asStringDynamicMap(entry.value),
          sourcePath: mcpJsonPath,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _getHooksJsonPath(ConfigurationLocation location) {
    final basePath = _getBasePath(location);
    final factoryPath = location == ConfigurationLocation.project
        ? AppConstants.projectFactoryPath
        : '.factory';
    return p.join(basePath, factoryPath, 'hooks', 'hooks.json');
  }

  Future<List<HookInfo>> listHooks({
    required ConfigurationLocation location,
  }) async {
    final hooksJsonPath = _getHooksJsonPath(location);
    final file = io.File(hooksJsonPath);

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final hooks = _asStringDynamicMap(json['hooks']);

      final result = <HookInfo>[];
      hooks.forEach((eventType, matchers) {
        final matcherList = _asListOfMaps(matchers);
        for (var i = 0; i < matcherList.length; i++) {
          final matcher = matcherList[i];
          result.add(
            HookInfo(
              name: _buildHookDisplayName(eventType, i, matcher),
              eventType: eventType,
              index: i,
              config: matcher,
              sourcePath: hooksJsonPath,
            ),
          );
        }
      });

      return result;
    } catch (e) {
      return [];
    }
  }

  Future<String> readConfiguration(String filePath) async {
    final file = io.File(filePath);

    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }

    try {
      return await file.readAsString();
    } on io.FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'read');
    } on FormatException {
      throw InvalidEncodingException(path: filePath);
    }
  }

  Future<void> writeConfiguration(String filePath, String content) async {
    final file = io.File(filePath);
    final dir = file.parent;

    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } on io.FileSystemException {
        throw DirectoryNotFoundException(path: dir.path);
      }
    }

    try {
      await file.writeAsString(content);
    } on io.FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'write');
    }
  }

  Future<void> deleteConfiguration(String filePath) async {
    final file = io.File(filePath);

    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }

    try {
      await file.delete();
    } on io.FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'delete');
    }
  }

  Future<FileInfo> getFileInfo(String filePath) async {
    final file = io.File(filePath);

    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }

    final stat = await file.stat();
    return FileInfo(
      path: filePath,
      name: p.basenameWithoutExtension(filePath),
      size: stat.size,
      created: stat.changed,
      modified: stat.modified,
    );
  }

  String buildFilePath({
    required ConfigurationLocation location,
    required ConfigurationType type,
    required String name,
  }) {
    final dirPath = _getConfigPath(location, type);
    if (type == ConfigurationType.skill) {
      return p.join(dirPath, name, 'SKILL.md');
    }
    final extension = type.fileExtensions.first;
    return p.join(dirPath, '$name$extension');
  }

  Future<bool> configurationExists({
    required ConfigurationLocation location,
    required ConfigurationType type,
    required String name,
  }) async {
    if (type == ConfigurationType.skill) {
      final dirPath = _getConfigPath(location, type);
      final candidates = [
        p.join(dirPath, name, 'SKILL.md'),
        p.join(dirPath, '$name.md'),
      ];
      for (final candidate in candidates) {
        if (await io.File(candidate).exists()) {
          return true;
        }
      }
      return false;
    }

    for (final ext in type.fileExtensions) {
      final dirPath = _getConfigPath(location, type);
      final filePath = p.join(dirPath, '$name$ext');
      if (await io.File(filePath).exists()) {
        return true;
      }
    }
    return false;
  }

  Future<McpServerInfo> upsertMcpServer({
    required ConfigurationLocation location,
    required String name,
    required Map<String, dynamic> config,
    String? previousName,
  }) async {
    final path = _getMcpJsonPath(location);
    final root = await _readJsonFile(
      path,
      defaultValue: {'mcpServers': <String, dynamic>{}},
    );
    final servers = _asStringDynamicMap(root['mcpServers']);

    if (previousName != null && previousName != name) {
      servers.remove(previousName);
    }
    servers[name] = config;
    root['mcpServers'] = servers;

    await _writeJsonFile(path, root);

    return McpServerInfo(name: name, config: config, sourcePath: path);
  }

  Future<bool> deleteMcpServer({
    required ConfigurationLocation location,
    required String name,
  }) async {
    final path = _getMcpJsonPath(location);
    final root = await _readJsonFile(
      path,
      defaultValue: {'mcpServers': <String, dynamic>{}},
    );
    final servers = _asStringDynamicMap(root['mcpServers']);
    final existed = servers.remove(name) != null;
    if (!existed) {
      return false;
    }
    root['mcpServers'] = servers;
    await _writeJsonFile(path, root);
    return true;
  }

  Future<bool> mcpServerExists({
    required ConfigurationLocation location,
    required String name,
  }) async {
    final servers = await listMcpServers(location: location);
    return servers.any((server) => server.name == name);
  }

  Future<HookInfo> addHook({
    required ConfigurationLocation location,
    required String eventType,
    required Map<String, dynamic> hookConfig,
  }) async {
    final path = _getHooksJsonPath(location);
    final root = await _readJsonFile(
      path,
      defaultValue: {'hooks': <String, dynamic>{}},
    );
    final hooks = _asStringDynamicMap(root['hooks']);
    final eventHooks = _asListOfMaps(hooks[eventType]);

    final normalized = Map<String, dynamic>.from(hookConfig);
    eventHooks.add(normalized);
    hooks[eventType] = eventHooks;
    root['hooks'] = hooks;

    await _writeJsonFile(path, root);

    final index = eventHooks.length - 1;
    return HookInfo(
      name: _buildHookDisplayName(eventType, index, normalized),
      eventType: eventType,
      index: index,
      config: normalized,
      sourcePath: path,
    );
  }

  Future<HookInfo> updateHook({
    required ConfigurationLocation location,
    required String sourceEventType,
    required int sourceIndex,
    required String targetEventType,
    required Map<String, dynamic> hookConfig,
  }) async {
    final path = _getHooksJsonPath(location);
    final root = await _readJsonFile(
      path,
      defaultValue: {'hooks': <String, dynamic>{}},
    );
    final hooks = _asStringDynamicMap(root['hooks']);
    final sourceHooks = _asListOfMaps(hooks[sourceEventType]);

    if (sourceIndex < 0 || sourceIndex >= sourceHooks.length) {
      throw RangeError(
        'Hook index $sourceIndex is out of range for event "$sourceEventType"',
      );
    }

    final normalized = Map<String, dynamic>.from(hookConfig);
    var targetIndex = sourceIndex;

    if (sourceEventType == targetEventType) {
      sourceHooks[sourceIndex] = normalized;
      hooks[sourceEventType] = sourceHooks;
    } else {
      sourceHooks.removeAt(sourceIndex);
      if (sourceHooks.isEmpty) {
        hooks.remove(sourceEventType);
      } else {
        hooks[sourceEventType] = sourceHooks;
      }

      final targetHooks = _asListOfMaps(hooks[targetEventType]);
      targetHooks.add(normalized);
      targetIndex = targetHooks.length - 1;
      hooks[targetEventType] = targetHooks;
    }

    root['hooks'] = hooks;
    await _writeJsonFile(path, root);

    return HookInfo(
      name: _buildHookDisplayName(targetEventType, targetIndex, normalized),
      eventType: targetEventType,
      index: targetIndex,
      config: normalized,
      sourcePath: path,
    );
  }

  Future<bool> deleteHook({
    required ConfigurationLocation location,
    required String eventType,
    required int index,
  }) async {
    final path = _getHooksJsonPath(location);
    final root = await _readJsonFile(
      path,
      defaultValue: {'hooks': <String, dynamic>{}},
    );
    final hooks = _asStringDynamicMap(root['hooks']);
    final eventHooks = _asListOfMaps(hooks[eventType]);

    if (index < 0 || index >= eventHooks.length) {
      return false;
    }

    eventHooks.removeAt(index);
    if (eventHooks.isEmpty) {
      hooks.remove(eventType);
    } else {
      hooks[eventType] = eventHooks;
    }

    root['hooks'] = hooks;
    await _writeJsonFile(path, root);
    return true;
  }

  Future<bool> hookExists({
    required ConfigurationLocation location,
    required String eventType,
    required String matcherOrName,
  }) async {
    final hooks = await listHooks(location: location);
    for (final hook in hooks) {
      if (hook.eventType != eventType) {
        continue;
      }
      final matcher = hook.config['matcher']?.toString();
      final name = hook.config['name']?.toString();
      if (matcher == matcherOrName || name == matcherOrName) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>> _readJsonFile(
    String filePath, {
    required Map<String, dynamic> defaultValue,
  }) async {
    final file = io.File(filePath);
    if (!await file.exists()) {
      return Map<String, dynamic>.from(defaultValue);
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        return Map<String, dynamic>.from(defaultValue);
      }
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      throw FileSystemException(
        path: filePath,
        operation: 'parse',
        details: 'JSON root must be an object',
      );
    } on FormatException catch (error) {
      throw FileSystemException(
        path: filePath,
        operation: 'parse',
        details: 'Invalid JSON: ${error.message}',
      );
    } on io.FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'read');
    }
  }

  Future<void> _writeJsonFile(
    String filePath,
    Map<String, dynamic> data,
  ) async {
    final dir = io.File(filePath).parent;
    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } on io.FileSystemException {
        throw DirectoryNotFoundException(path: dir.path);
      }
    }

    try {
      final content = _jsonEncoder.convert(data);
      await io.File(filePath).writeAsString('$content\n');
    } on io.FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'write');
    }
  }

  Map<String, dynamic> _asStringDynamicMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asListOfMaps(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    final result = <Map<String, dynamic>>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        result.add(Map<String, dynamic>.from(item));
      } else if (item is Map) {
        result.add(item.map((key, val) => MapEntry(key.toString(), val)));
      }
    }
    return result;
  }

  String _buildHookDisplayName(
    String eventType,
    int index,
    Map<String, dynamic> hookConfig,
  ) {
    final explicitName = hookConfig['name']?.toString().trim();
    if (explicitName != null && explicitName.isNotEmpty) {
      return explicitName;
    }

    final matcher = hookConfig['matcher']?.toString().trim();
    if (matcher != null && matcher.isNotEmpty) {
      return '$eventType:$matcher';
    }

    return '$eventType #${index + 1}';
  }
}
