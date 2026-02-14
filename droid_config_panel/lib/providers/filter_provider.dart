import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/providers/states.dart';

final filterStateProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTypeFilter(ConfigurationType? type) {
    if (type == null) {
      state = state.copyWith(clearTypeFilter: true);
      return;
    }

    if (type == state.typeFilter) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(typeFilter: type);
    }
  }

  void setLocationFilter(ConfigurationLocation? location) {
    if (location == null) {
      state = state.copyWith(clearLocationFilter: true);
      return;
    }

    if (location == state.locationFilter) {
      state = state.copyWith(clearLocationFilter: true);
    } else {
      state = state.copyWith(locationFilter: location);
    }
  }

  void setStatusFilter(ValidationStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
      return;
    }

    if (status == state.statusFilter) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  void clearAll() {
    state = state.clearAll();
  }
}
