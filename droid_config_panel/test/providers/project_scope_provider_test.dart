import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/project_scope_provider.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/utils/constants.dart';

void main() {
  group('activeProjectPathProvider', () {
    test('defaults to current working directory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currentPath = p.normalize(Directory.current.absolute.path);
      final homePath = AppConstants.homeDirectory.trim();
      final expected = () {
        if (currentPath != p.separator) {
          return currentPath;
        }
        if (homePath.isEmpty) {
          return currentPath;
        }
        final documentsPath = p.normalize(p.join(homePath, 'Documents'));
        if (Directory(documentsPath).existsSync()) {
          return documentsPath;
        }
        return p.normalize(homePath);
      }();
      expect(container.read(activeProjectPathProvider), equals(expected));
    });

    test('switching active project path rebuilds file service scope', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final projectA = await Directory.systemTemp.createTemp('scope_a_');
      final projectB = await Directory.systemTemp.createTemp('scope_b_');

      addTearDown(() async {
        if (await projectA.exists()) {
          await projectA.delete(recursive: true);
        }
        if (await projectB.exists()) {
          await projectB.delete(recursive: true);
        }
      });

      container.read(activeProjectPathProvider.notifier).state = projectA.path;
      final fileServiceA = container.read(fileServiceProvider);
      final pathA = fileServiceA.buildFilePath(
        location: ConfigurationLocation.project,
        type: ConfigurationType.droid,
        name: 'alpha',
      );

      container.read(activeProjectPathProvider.notifier).state = projectB.path;
      final fileServiceB = container.read(fileServiceProvider);
      final pathB = fileServiceB.buildFilePath(
        location: ConfigurationLocation.project,
        type: ConfigurationType.droid,
        name: 'alpha',
      );

      expect(pathA, startsWith(p.join(projectA.path, '.factory')));
      expect(pathB, startsWith(p.join(projectB.path, '.factory')));
      expect(pathA, isNot(equals(pathB)));
    });
  });
}
