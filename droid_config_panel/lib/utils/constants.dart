import 'dart:io';

class AppConstants {
  static const String appName = 'Droid Config Panel';
  static const String appVersion = '1.0.0';

  static String get homeDirectory => Platform.environment['HOME'] ?? '';

  static String get personalFactoryPath => '$homeDirectory/.factory';

  static const String projectFactoryPath = '.factory';

  static const Map<String, String> configDirectories = {
    'droids': 'droids',
    'skills': 'skills',
    'agents': 'agents',
    'hooks': 'hooks',
    'mcpServers': 'mcp',
  };

  static const Map<String, List<String>> configExtensions = {
    'droids': ['.md'],
    'skills': ['.md'],
    'agents': ['.md', '.yaml'],
    'hooks': ['.yaml'],
    'mcpServers': ['.yaml'],
  };
}
