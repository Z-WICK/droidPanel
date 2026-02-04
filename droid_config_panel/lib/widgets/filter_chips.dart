import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/enums.dart';

class FilterChips extends StatelessWidget {
  final ConfigurationType? selectedType;
  final ConfigurationLocation? selectedLocation;
  final ValueChanged<ConfigurationType?>? onTypeChanged;
  final ValueChanged<ConfigurationLocation?>? onLocationChanged;
  final VoidCallback? onClearAll;

  const FilterChips({
    super.key,
    this.selectedType,
    this.selectedLocation,
    this.onTypeChanged,
    this.onLocationChanged,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedType != null || selectedLocation != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (hasFilters) ...[
            ActionChip(
              avatar: const Icon(Icons.clear, size: 18),
              label: const Text('Clear'),
              onPressed: onClearAll,
            ),
            const SizedBox(width: 8),
          ],
          const Text('Type: '),
          const SizedBox(width: 4),
          ...ConfigurationType.values.map((type) {
            final isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) => onTypeChanged?.call(type),
              ),
            );
          }),
          const SizedBox(width: 16),
          const Text('Location: '),
          const SizedBox(width: 4),
          ...ConfigurationLocation.values.map((location) {
            final isSelected = selectedLocation == location;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilterChip(
                label: Text(location.displayName),
                selected: isSelected,
                onSelected: (_) => onLocationChanged?.call(location),
              ),
            );
          }),
        ],
      ),
    );
  }
}
