import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class SearchService {
  List<Configuration> search({
    required List<Configuration> configurations,
    required String query,
  }) {
    if (query.trim().isEmpty) {
      return configurations;
    }

    final lowerQuery = query.toLowerCase();
    return configurations.where((config) {
      return config.name.toLowerCase().contains(lowerQuery) ||
          config.description.toLowerCase().contains(lowerQuery) ||
          config.type.displayName.toLowerCase().contains(lowerQuery) ||
          config.location.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Configuration> filter({
    required List<Configuration> configurations,
    ConfigurationType? type,
    ConfigurationLocation? location,
    ValidationStatus? status,
  }) {
    return configurations.where((config) {
      if (type != null && config.type != type) return false;
      if (location != null && config.location != location) return false;
      if (status != null && config.status != status) return false;
      return true;
    }).toList();
  }

  List<Configuration> searchAndFilter({
    required List<Configuration> configurations,
    String query = '',
    ConfigurationType? type,
    ConfigurationLocation? location,
    ValidationStatus? status,
  }) {
    var result = configurations;

    if (query.isNotEmpty) {
      result = search(configurations: result, query: query);
    }

    result = filter(
      configurations: result,
      type: type,
      location: location,
      status: status,
    );

    return result;
  }
}
