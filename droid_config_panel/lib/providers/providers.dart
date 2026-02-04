import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/services/file_service.dart';
import 'package:droid_config_panel/services/validation_service.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

final validationServiceProvider = Provider<ValidationService>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  return ValidationService(fileService: fileService);
});
