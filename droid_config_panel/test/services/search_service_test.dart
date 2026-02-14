import 'package:flutter_test/flutter_test.dart';

import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/services/search_service.dart';

void main() {
  group('SearchService', () {
    final service = SearchService();
    final now = DateTime(2026, 2, 1);

    final sample = [
      Configuration(
        id: '1',
        name: 'build-bot',
        type: ConfigurationType.droid,
        description: 'CI helper',
        location: ConfigurationLocation.project,
        filePath: '/tmp/build-bot.md',
        content: '',
        status: ValidationStatus.valid,
        createdAt: now,
        modifiedAt: now,
      ),
      Configuration(
        id: '2',
        name: 'filesystem',
        type: ConfigurationType.mcpServer,
        description: 'Local file access',
        location: ConfigurationLocation.personal,
        filePath: '/tmp/filesystem.json',
        content: '',
        status: ValidationStatus.invalid,
        createdAt: now,
        modifiedAt: now,
      ),
    ];

    test('search matches name, description, type, and location', () {
      expect(
        service.search(configurations: sample, query: 'build').length,
        equals(1),
      );
      expect(
        service.search(configurations: sample, query: 'file').length,
        equals(1),
      );
      expect(
        service.search(configurations: sample, query: 'mcp').length,
        equals(1),
      );
      expect(
        service.search(configurations: sample, query: 'personal').length,
        equals(1),
      );
    });

    test('searchAndFilter applies all filters consistently', () {
      final result = service.searchAndFilter(
        configurations: sample,
        query: 'file',
        type: ConfigurationType.mcpServer,
        location: ConfigurationLocation.personal,
        status: ValidationStatus.invalid,
      );

      expect(result.length, equals(1));
      expect(result.first.name, equals('filesystem'));
    });
  });
}
