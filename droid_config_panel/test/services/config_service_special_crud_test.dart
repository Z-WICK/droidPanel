import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/exceptions.dart' as app_ex;
import 'package:droid_config_panel/services/config_service.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';

void main() {
  group('ConfigService special configuration CRUD', () {
    late Directory projectDir;
    late Directory homeDir;
    late ConfigService service;

    setUp(() async {
      projectDir = await Directory.systemTemp.createTemp('droid_project_');
      homeDir = await Directory.systemTemp.createTemp('droid_home_');

      final fileService = FileService(
        projectBasePath: projectDir.path,
        personalBasePath: homeDir.path,
      );
      service = ConfigService(
        fileService: fileService,
        validationService: ValidationService(fileService: fileService),
      );
    });

    tearDown(() async {
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      if (await homeDir.exists()) {
        await homeDir.delete(recursive: true);
      }
    });

    test('creates, updates, and deletes hook entries in hooks.json', () async {
      final created = await service.createConfiguration(
        name: 'audit-hook',
        type: ConfigurationType.hook,
        location: ConfigurationLocation.project,
        content: '''{
  "event": "PreToolUse",
  "name": "audit-hook",
  "matcher": "audit-hook",
  "action": "echo created"
}''',
      );

      final hooksPath = p.join(
        projectDir.path,
        '.factory',
        'hooks',
        'hooks.json',
      );
      final hooksFile = File(hooksPath);
      expect(await hooksFile.exists(), isTrue);

      var decoded =
          jsonDecode(await hooksFile.readAsString()) as Map<String, dynamic>;
      final createdHooks =
          ((decoded['hooks'] as Map<String, dynamic>)['PreToolUse']
              as List<dynamic>);
      expect(createdHooks.length, equals(1));
      expect(createdHooks.first['action'], equals('echo created'));

      final updated = await service.updateConfiguration(
        id: created.id,
        content: '''{
  "event": "PostToolUse",
  "name": "audit-hook",
  "matcher": "audit-hook",
  "action": "echo updated"
}''',
      );

      decoded =
          jsonDecode(await hooksFile.readAsString()) as Map<String, dynamic>;
      final hooksMap = decoded['hooks'] as Map<String, dynamic>;
      expect(hooksMap.containsKey('PreToolUse'), isFalse);
      expect((hooksMap['PostToolUse'] as List<dynamic>).length, equals(1));
      expect(
        (hooksMap['PostToolUse'] as List<dynamic>).first['action'],
        equals('echo updated'),
      );

      await service.deleteConfiguration(updated.id);

      decoded =
          jsonDecode(await hooksFile.readAsString()) as Map<String, dynamic>;
      final remaining = decoded['hooks'] as Map<String, dynamic>;
      expect(remaining.containsKey('PostToolUse'), isFalse);
    });

    test('creates, renames, and deletes mcp servers inside mcp.json', () async {
      final created = await service.createConfiguration(
        name: 'filesystem',
        type: ConfigurationType.mcpServer,
        location: ConfigurationLocation.personal,
        content: '''{
  "name": "filesystem",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem"]
}''',
      );

      final mcpPath = p.join(homeDir.path, '.factory', 'mcp.json');
      final mcpFile = File(mcpPath);
      expect(await mcpFile.exists(), isTrue);

      var decoded =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      var servers = decoded['mcpServers'] as Map<String, dynamic>;
      expect(servers.containsKey('filesystem'), isTrue);

      final updated = await service.updateConfiguration(
        id: created.id,
        name: 'filesystem-v2',
        content: '''{
  "name": "filesystem-v2",
  "command": "uvx",
  "args": ["mcp-server-filesystem"]
}''',
      );

      decoded =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      servers = decoded['mcpServers'] as Map<String, dynamic>;
      expect(servers.containsKey('filesystem'), isFalse);
      expect(servers.containsKey('filesystem-v2'), isTrue);
      expect(
        (servers['filesystem-v2'] as Map<String, dynamic>)['command'],
        equals('uvx'),
      );

      await service.deleteConfiguration(updated.id);

      decoded =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      servers = decoded['mcpServers'] as Map<String, dynamic>;
      expect(servers, isEmpty);
    });

    test('fails safely when existing mcp.json is malformed', () async {
      final mcpFile = File(p.join(homeDir.path, '.factory', 'mcp.json'));
      await mcpFile.parent.create(recursive: true);
      await mcpFile.writeAsString('{ malformed');

      await expectLater(
        () => service.createConfiguration(
          name: 'unsafe-write',
          type: ConfigurationType.mcpServer,
          location: ConfigurationLocation.personal,
          content: '''{
  "name": "unsafe-write",
  "command": "npx"
}''',
        ),
        throwsA(isA<app_ex.FileSystemException>()),
      );

      expect(await mcpFile.readAsString(), equals('{ malformed'));
    });
  });
}
