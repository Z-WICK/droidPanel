import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/states.dart';
import 'package:droid_config_panel/services/config_service.dart';
import 'package:droid_config_panel/providers/providers.dart';

final configServiceProvider = Provider<ConfigService>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  final validationService = ref.watch(validationServiceProvider);
  return ConfigService(
    fileService: fileService,
    validationService: validationService,
  );
});

final configurationStateProvider =
    StateNotifierProvider<ConfigurationNotifier, ConfigurationState>((ref) {
      final configService = ref.watch(configServiceProvider);
      return ConfigurationNotifier(configService);
    });

class ConfigurationNotifier extends StateNotifier<ConfigurationState> {
  final ConfigService _configService;

  ConfigurationNotifier(this._configService)
    : super(ConfigurationState.initial());

  Future<void> loadConfigurations() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final configurations = await _configService.getAllConfigurations();
      state = state.copyWith(configurations: configurations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadConfigurationsByType(ConfigurationType type) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final configurations = await _configService.getConfigurationsByType(type);
      state = state.copyWith(configurations: configurations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadConfigurationsByLocation(
    ConfigurationLocation location,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final configurations = await _configService.getConfigurationsByLocation(
        location,
      );
      state = state.copyWith(configurations: configurations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectConfiguration(Configuration? config) {
    state = state.copyWith(
      selectedConfiguration: config,
      clearSelection: config == null,
    );
  }

  Future<void> createConfiguration({
    required String name,
    required ConfigurationType type,
    required ConfigurationLocation location,
    required String content,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _configService.createConfiguration(
        name: name,
        type: type,
        location: location,
        content: content,
        description: description,
      );
      await loadConfigurations();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateConfiguration({
    required String id,
    required String content,
    String? name,
    String? description,
    DateTime? expectedModifiedAt,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _configService.updateConfiguration(
        id: id,
        content: content,
        name: name,
        description: description,
        expectedModifiedAt: expectedModifiedAt,
      );
      await loadConfigurations();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteConfiguration(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _configService.deleteConfiguration(id);
      state = state.copyWith(clearSelection: true);
      await loadConfigurations();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
