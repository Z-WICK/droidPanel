import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/services/config_service.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';

void main() {
  group('ConfigService multi-project isolation', () {
    late Directory projectA;
    late Directory projectB;
    late Directory homeDir;
    late ConfigService serviceA;
    late ConfigService serviceB;

    const droidContent = '''---
name: shared-droid
description: project isolated config
model: sonnet
---

You are an isolated project droid.
''';

    setUp(() async {
      projectA = await Directory.systemTemp.createTemp('droid_project_a_');
      projectB = await Directory.systemTemp.createTemp('droid_project_b_');
      homeDir = await Directory.systemTemp.createTemp('droid_home_');

      final fileServiceA = FileService(
        projectBasePath: projectA.path,
        personalBasePath: homeDir.path,
      );
      final fileServiceB = FileService(
        projectBasePath: projectB.path,
        personalBasePath: homeDir.path,
      );

      serviceA = ConfigService(
        fileService: fileServiceA,
        validationService: ValidationService(fileService: fileServiceA),
      );
      serviceB = ConfigService(
        fileService: fileServiceB,
        validationService: ValidationService(fileService: fileServiceB),
      );
    });

    tearDown(() async {
      if (await projectA.exists()) {
        await projectA.delete(recursive: true);
      }
      if (await projectB.exists()) {
        await projectB.delete(recursive: true);
      }
      if (await homeDir.exists()) {
        await homeDir.delete(recursive: true);
      }
    });

    test('same name can exist in two projects without conflicts', () async {
      final createdA = await serviceA.createConfiguration(
        name: 'shared-droid',
        type: ConfigurationType.droid,
        location: ConfigurationLocation.project,
        content: droidContent,
      );
      final createdB = await serviceB.createConfiguration(
        name: 'shared-droid',
        type: ConfigurationType.droid,
        location: ConfigurationLocation.project,
        content: droidContent,
      );

      expect(createdA.filePath, isNot(equals(createdB.filePath)));
      expect(createdA.filePath, startsWith(projectA.path));
      expect(createdB.filePath, startsWith(projectB.path));

      final listA = await serviceA.getConfigurationsByLocation(
        ConfigurationLocation.project,
      );
      final listB = await serviceB.getConfigurationsByLocation(
        ConfigurationLocation.project,
      );

      expect(listA.length, equals(1));
      expect(listB.length, equals(1));
      expect(listA.first.name, equals('shared-droid'));
      expect(listB.first.name, equals('shared-droid'));
      expect(listA.first.filePath, startsWith(projectA.path));
      expect(listB.first.filePath, startsWith(projectB.path));
    });

    test(
      'deduplicates results when project and personal share same base path',
      () async {
        final sharedService = ConfigService(
          fileService: FileService(
            projectBasePath: homeDir.path,
            personalBasePath: homeDir.path,
          ),
          validationService: ValidationService(
            fileService: FileService(
              projectBasePath: homeDir.path,
              personalBasePath: homeDir.path,
            ),
          ),
        );

        await sharedService.createConfiguration(
          name: 'shared-source',
          type: ConfigurationType.droid,
          location: ConfigurationLocation.project,
          content: '''---
name: shared-source
description: same source file
model: sonnet
---

Source body.
''',
        );

        final all = await sharedService.getAllConfigurations();
        expect(all.where((c) => c.name == 'shared-source').length, equals(1));
        expect(
          all.singleWhere((c) => c.name == 'shared-source').location,
          equals(ConfigurationLocation.project),
        );
      },
    );
  });
}
