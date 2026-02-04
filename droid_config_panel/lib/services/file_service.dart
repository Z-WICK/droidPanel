import 'dart:io';
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
  final Map<String, dynamic> config;
  final String sourcePath;

  HookInfo({
    required this.name,
    required this.eventType,
    required this.config,
    required this.sourcePath,
  });
}

class FileService {
  String _getBasePath(ConfigurationLocation location) {
    switch (location) {
      case ConfigurationLocation.project:
        return Directory.current.path;
      case ConfigurationLocation.personal:
        return AppConstants.homeDirectory;
    }
  }

  String _getConfigPath(ConfigurationLocation location, ConfigurationType type) {
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
    final dir = Directory(dirPath);

    if (!await dir.exists()) {
      return [];
    }

    final files = <FileInfo>[];
    final extensions = type.fileExtensions;

    try {
      await for (final entity in dir.list()) {
        // Handle direct files (e.g., droids/*.md)
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (extensions.contains(ext)) {
            final stat = await entity.stat();
            files.add(FileInfo(
              path: entity.path,
              name: p.basenameWithoutExtension(entity.path),
              size: stat.size,
              created: stat.changed,
              modified: stat.modified,
            ));
          }
        }
        // Handle directory-based configs (e.g., skills/skill-name/SKILL.md)
        else if (entity is Directory) {
          // Look for config files in subdirectory
          final possibleFiles = ['SKILL.md', 'skill.md', 'index.md', 'README.md'];
          for (final fileName in possibleFiles) {
            final configFile = File(p.join(entity.path, fileName));
            if (await configFile.exists()) {
              final stat = await configFile.stat();
              files.add(FileInfo(
                path: configFile.path,
                name: p.basename(entity.path),
                size: stat.size,
                created: stat.changed,
                modified: stat.modified,
              ));
              break; // Found one, stop looking
            }
          }
        }
      }
    } on FileSystemException {
      throw PermissionDeniedException(path: dirPath, operation: 'list');
    }

    return files;
  }

  Future<List<McpServerInfo>> listMcpServers({
    required ConfigurationLocation location,
  }) async {
    final mcpJsonPath = _getMcpJsonPath(location);
    final file = File(mcpJsonPath);

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final servers = json['mcpServers'] as Map<String, dynamic>?;

      if (servers == null) {
        return [];
      }

      return servers.entries.map((entry) {
        return McpServerInfo(
          name: entry.key,
          config: entry.value as Map<String, dynamic>,
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
    final file = File(hooksJsonPath);

    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final hooks = json['hooks'] as Map<String, dynamic>?;

      if (hooks == null) {
        return [];
      }

      final result = <HookInfo>[];
      hooks.forEach((eventType, matchers) {
        if (matchers is List) {
          for (var i = 0; i < matchers.length; i++) {
            final matcher = matchers[i] as Map<String, dynamic>;
            result.add(HookInfo(
              name: '$eventType-${matcher['matcher'] ?? i}',
              eventType: eventType,
              config: matcher,
              sourcePath: hooksJsonPath,
            ));
          }
        }
      });

      return result;
    } catch (e) {
      return [];
    }
  }

  Future<String> readConfiguration(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }

    try {
      return await file.readAsString();
    } on FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'read');
    } on FormatException {
      throw InvalidEncodingException(path: filePath);
    }
  }

  Future<void> writeConfiguration(String filePath, String content) async {
    final file = File(filePath);
    final dir = file.parent;

    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } on FileSystemException {
        throw DirectoryNotFoundException(path: dir.path);
      }
    }

    try {
      await file.writeAsString(content);
    } on FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'write');
    }
  }

  Future<void> deleteConfiguration(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw FileNotFoundException(path: filePath);
    }

    try {
      await file.delete();
    } on FileSystemException {
      throw PermissionDeniedException(path: filePath, operation: 'delete');
    }
  }

  Future<FileInfo> getFileInfo(String filePath) async {
    final file = File(filePath);

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
    final extension = type.fileExtensions.first;
    return p.join(dirPath, '$name$extension');
  }

  Future<bool> configurationExists({
    required ConfigurationLocation location,
    required ConfigurationType type,
    required String name,
  }) async {
    for (final ext in type.fileExtensions) {
      final dirPath = _getConfigPath(location, type);
      final filePath = p.join(dirPath, '$name$ext');
      if (await File(filePath).exists()) {
        return true;
      }
    }
    return false;
  }
}
