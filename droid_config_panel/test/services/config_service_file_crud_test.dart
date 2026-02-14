import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/services/config_service.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';

void main() {
  group('ConfigService file-based CRUD', () {
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

    test('creates skill using directory-based SKILL.md structure', () async {
      final created = await service.createConfiguration(
        name: 'quality-gate',
        type: ConfigurationType.skill,
        location: ConfigurationLocation.project,
        content: '''---
name: quality-gate
description: quality checks
---

Run quality checks before merge.
''',
      );

      final expectedPath = p.join(
        projectDir.path,
        '.factory',
        'skills',
        'quality-gate',
        'SKILL.md',
      );

      expect(created.filePath, equals(expectedPath));
      expect(await File(expectedPath).exists(), isTrue);
    });

    test('renames droid file and keeps metadata synchronized', () async {
      final created = await service.createConfiguration(
        name: 'assistant-alpha',
        type: ConfigurationType.droid,
        location: ConfigurationLocation.personal,
        content: '''---
name: assistant-alpha
description: alpha droid
model: sonnet
---

You are alpha.
''',
      );

      final updated = await service.updateConfiguration(
        id: created.id,
        name: 'assistant-beta',
        content: created.content,
        description: 'beta droid',
      );

      expect(await File(created.filePath).exists(), isFalse);
      expect(await File(updated.filePath).exists(), isTrue);

      final updatedContent = await File(updated.filePath).readAsString();
      expect(updatedContent.contains('name: assistant-beta'), isTrue);
      expect(updatedContent.contains('description: beta droid'), isTrue);
    });
  });
}
