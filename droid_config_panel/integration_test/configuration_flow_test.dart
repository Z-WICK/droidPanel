import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/screens/home_screen.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';
import 'package:droid_config_panel/theme/app_theme.dart';
import 'package:droid_config_panel/widgets/config_list_item.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Configuration E2E flow', () {
    late Directory projectDir;
    late Directory homeDir;

    setUp(() async {
      projectDir = await Directory.systemTemp.createTemp('droid_e2e_project_');
      homeDir = await Directory.systemTemp.createTemp('droid_e2e_home_');
    });

    tearDown(() async {
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      if (await homeDir.exists()) {
        await homeDir.delete(recursive: true);
      }
    });

    testWidgets('create, search, edit, and delete a droid', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await _pumpApp(
        tester,
        projectPath: projectDir.path,
        homePath: homeDir.path,
      );

      expect(find.text('No configurations found'), findsOneWidget);

      await tester.tap(_newButtonFinder());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'e2e-droid');
      await tester.enterText(textFields.at(1), 'created by integration test');

      await tester.tap(find.text('Save').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
        find.descendant(
          of: find.byType(ConfigListItem),
          matching: find.text('e2e-droid'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ConfigListItem),
          matching: find.textContaining('created by integration test'),
        ),
        findsOneWidget,
      );

      final searchField = _searchFieldFinder();
      await tester.enterText(searchField, 'unmatched-query');
      await tester.pumpAndSettle();
      expect(find.text('No matching results'), findsOneWidget);

      await tester.enterText(searchField, 'e2e-droid');
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(ConfigListItem),
          matching: find.text('e2e-droid'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit').last);
      await tester.pumpAndSettle();

      final editFields = find.byType(TextFormField);
      await tester.enterText(editFields.at(1), 'updated by integration test');
      await tester.tap(find.text('Save').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
        find.descendant(
          of: find.byType(ConfigListItem),
          matching: find.textContaining('updated by integration test'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('More actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ConfigListItem), findsNothing);
      expect(
        await File(
          p.join(projectDir.path, '.factory', 'droids', 'e2e-droid.md'),
        ).exists(),
        isFalse,
      );
    });
  });
}

Finder _newButtonFinder() {
  return find.widgetWithText(FilledButton, 'New');
}

Finder _searchFieldFinder() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is TextField &&
        widget.decoration?.hintText == 'Search configurations',
    description: 'Search configurations text field',
  );
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
