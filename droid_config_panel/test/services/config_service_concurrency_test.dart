import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/exceptions.dart';
import 'package:droid_config_panel/services/config_service.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';

void main() {
  group('ConfigService concurrency safety', () {
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

    test('rejects save when the file has been externally modified', () async {
      final created = await service.createConfiguration(
        name: 'safe-droid',
        type: ConfigurationType.droid,
        location: ConfigurationLocation.project,
        content: '''---
name: safe-droid
description: original
model: sonnet
---

Original body.
''',
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final sourceFile = File(
        p.join(projectDir.path, '.factory', 'droids', 'safe-droid.md'),
      );
      await sourceFile.writeAsString('''---
name: safe-droid
description: modified outside app
model: sonnet
---

External mutation.
''');

      await expectLater(
        () => service.updateConfiguration(
          id: created.id,
          content: created.content,
          description: 'attempted in app',
          expectedModifiedAt: created.modifiedAt,
        ),
        throwsA(isA<ConcurrentModificationException>()),
      );
    });

    test('fails update when source file was removed externally', () async {
      final created = await service.createConfiguration(
        name: 'missing-droid',
        type: ConfigurationType.droid,
        location: ConfigurationLocation.project,
        content: '''---
name: missing-droid
description: original
model: sonnet
---

Original body.
''',
      );

      final sourceFile = File(
        p.join(projectDir.path, '.factory', 'droids', 'missing-droid.md'),
      );
      await sourceFile.delete();

      await expectLater(
        () => service.updateConfiguration(
          id: created.id,
          content: created.content,
          description: 'attempted after deletion',
          expectedModifiedAt: created.modifiedAt,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
