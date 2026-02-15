import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/search_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';
import 'package:droid_config_panel/providers/project_scope_provider.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  final projectBasePath = ref.watch(activeProjectPathProvider);
  return FileService(projectBasePath: projectBasePath);
});

final validationServiceProvider = Provider<ValidationService>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return ValidationService(fileService: fileService);
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});
