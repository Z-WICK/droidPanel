import 'dart:io';
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
      }
    } on FileSystemException {
      throw PermissionDeniedException(path: dirPath, operation: 'list');
    }

    return files;
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
