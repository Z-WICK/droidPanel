import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class ConfigurationState {
  final List<Configuration> configurations;
  final bool isLoading;
  final String? error;
  final Configuration? selectedConfiguration;

  const ConfigurationState({
    this.configurations = const [],
    this.isLoading = false,
    this.error,
    this.selectedConfiguration,
  });

  ConfigurationState copyWith({
    List<Configuration>? configurations,
    bool? isLoading,
    String? error,
    Configuration? selectedConfiguration,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return ConfigurationState(
      configurations: configurations ?? this.configurations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedConfiguration: clearSelection
          ? null
          : (selectedConfiguration ?? this.selectedConfiguration),
    );
  }

  factory ConfigurationState.initial() {
    return const ConfigurationState();
  }

  factory ConfigurationState.loading() {
    return const ConfigurationState(isLoading: true);
  }

  factory ConfigurationState.error(String message) {
    return ConfigurationState(error: message);
  }
}

class FilterState {
  final String searchQuery;
  final ConfigurationType? typeFilter;
  final ConfigurationLocation? locationFilter;
  final ValidationStatus? statusFilter;

  const FilterState({
    this.searchQuery = '',
    this.typeFilter,
    this.locationFilter,
    this.statusFilter,
  });

  FilterState copyWith({
    String? searchQuery,
    ConfigurationType? typeFilter,
    ConfigurationLocation? locationFilter,
    ValidationStatus? statusFilter,
    bool clearTypeFilter = false,
    bool clearLocationFilter = false,
    bool clearStatusFilter = false,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      locationFilter: clearLocationFilter
          ? null
          : (locationFilter ?? this.locationFilter),
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      typeFilter != null ||
      locationFilter != null ||
      statusFilter != null;

  FilterState clearAll() {
    return const FilterState();
  }
}
