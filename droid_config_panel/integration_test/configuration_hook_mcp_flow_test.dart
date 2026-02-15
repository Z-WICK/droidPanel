import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/screens/home_screen.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';
import 'package:droid_config_panel/theme/app_theme.dart';
import 'package:droid_config_panel/widgets/config_list_item.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Hook and MCP E2E flow', () {
    late Directory projectDir;
    late Directory homeDir;

    setUp(() async {
      projectDir = await Directory.systemTemp.createTemp(
        'droid_hook_mcp_proj_',
      );
      homeDir = await Directory.systemTemp.createTemp('droid_hook_mcp_home_');
    });

    tearDown(() async {
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      if (await homeDir.exists()) {
        await homeDir.delete(recursive: true);
      }
    });

    testWidgets('create, edit, and delete Hook/MCP configurations', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await _pumpApp(
        tester,
        projectPath: projectDir.path,
        homePath: homeDir.path,
      );

      await _createConfiguration(
        tester,
        type: ConfigurationType.hook,
        name: 'audit-hook',
        description: 'hook created in e2e',
      );
      await _createConfiguration(
        tester,
        type: ConfigurationType.mcpServer,
        name: 'filesystem-mcp',
        description: 'mcp created in e2e',
      );

      expect(_itemTextFinder('audit-hook'), findsOneWidget);
      expect(_itemTextFinder('filesystem-mcp'), findsOneWidget);

      final hooksFile = File(
        p.join(projectDir.path, '.factory', 'hooks', 'hooks.json'),
      );
      expect(await hooksFile.exists(), isTrue);
      var hooksJson =
          jsonDecode(await hooksFile.readAsString()) as Map<String, dynamic>;
      expect(hooksJson['hooks'], isA<Map<String, dynamic>>());
      expect(
        ((hooksJson['hooks'] as Map<String, dynamic>)['PreToolUse']
                as List<dynamic>)
            .where(
              (entry) =>
                  (entry as Map<String, dynamic>)['name'] == 'audit-hook',
            )
            .isNotEmpty,
        isTrue,
      );

      final mcpFile = File(p.join(projectDir.path, '.factory', 'mcp.json'));
      expect(await mcpFile.exists(), isTrue);
      var mcpJson =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      expect(
        (mcpJson['mcpServers'] as Map<String, dynamic>).containsKey(
          'filesystem-mcp',
        ),
        isTrue,
      );

      await _editConfigurationDescription(
        tester,
        itemName: 'filesystem-mcp',
        newDescription: 'mcp description updated in e2e',
      );

      mcpJson =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      expect(
        ((mcpJson['mcpServers'] as Map<String, dynamic>)['filesystem-mcp']
            as Map<String, dynamic>)['description'],
        equals('mcp description updated in e2e'),
      );

      await _deleteConfiguration(tester, itemName: 'audit-hook');
      await _deleteConfiguration(tester, itemName: 'filesystem-mcp');

      expect(_itemTextFinder('audit-hook'), findsNothing);
      expect(_itemTextFinder('filesystem-mcp'), findsNothing);

      hooksJson =
          jsonDecode(await hooksFile.readAsString()) as Map<String, dynamic>;
      expect((hooksJson['hooks'] as Map<String, dynamic>).isEmpty, isTrue);
      mcpJson =
          jsonDecode(await mcpFile.readAsString()) as Map<String, dynamic>;
      expect((mcpJson['mcpServers'] as Map<String, dynamic>).isEmpty, isTrue);
    });
  });
}

Finder _itemTextFinder(String value) {
  return find.descendant(
    of: find.byType(ConfigListItem),
    matching: find.text(value),
  );
}

Future<void> _createConfiguration(
  WidgetTester tester, {
  required ConfigurationType type,
  required String name,
  required String description,
}) async {
  await tester.tap(_newButtonFinder());
  await tester.pumpAndSettle();

  await tester.tap(
    find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField<ConfigurationType>,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(type.displayName).last);
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), description);
  await tester.tap(find.text('Reset Template'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Save').first);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _editConfigurationDescription(
  WidgetTester tester, {
  required String itemName,
  required String newDescription,
}) async {
  final item = find.ancestor(
    of: find.text(itemName),
    matching: find.byType(ConfigListItem),
  );

  await tester.tap(
    find.descendant(of: item, matching: find.byTooltip('More actions')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Edit').last);
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(1), newDescription);
  await tester.tap(find.text('Save').first);
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _deleteConfiguration(
  WidgetTester tester, {
  required String itemName,
}) async {
  final item = find.ancestor(
    of: find.text(itemName),
    matching: find.byType(ConfigListItem),
  );

  await tester.tap(
    find.descendant(of: item, matching: find.byTooltip('More actions')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete').last);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Finder _newButtonFinder() {
  return find.widgetWithText(FilledButton, 'New');
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required String projectPath,
  required String homePath,
}) async {
  final fileService = FileService(
    projectBasePath: projectPath,
    personalBasePath: homePath,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        fileServiceProvider.overrideWithValue(fileService),
        validationServiceProvider.overrideWithValue(
          ValidationService(fileService: fileService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
}
