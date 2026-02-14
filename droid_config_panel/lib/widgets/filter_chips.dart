import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';

class FilterChips extends StatelessWidget {
  final ConfigurationType? selectedType;
  final ConfigurationLocation? selectedLocation;
  final ValidationStatus? selectedStatus;
  final ValueChanged<ConfigurationType?>? onTypeChanged;
  final ValueChanged<ConfigurationLocation?>? onLocationChanged;
  final ValueChanged<ValidationStatus?>? onStatusChanged;
  final VoidCallback? onClearAll;

  const FilterChips({
    super.key,
    this.selectedType,
    this.selectedLocation,
    this.selectedStatus,
    this.onTypeChanged,
    this.onLocationChanged,
    this.onStatusChanged,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        selectedType != null ||
        selectedLocation != null ||
        selectedStatus != null;
    final theme = Theme.of(context);

    return GlassSurface(
      borderRadius: 22,
      blur: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (hasFilters)
                ActionChip(
                  avatar: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  onPressed: onClearAll,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _GroupLabel(text: 'Type'),
              for (final type in ConfigurationType.values)
                _CompactFilterChip(
                  text: type.displayName,
                  selected: selectedType == type,
                  onSelected: () =>
                      onTypeChanged?.call(selectedType == type ? null : type),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _GroupLabel(text: 'Location'),
              for (final location in ConfigurationLocation.values)
                _CompactFilterChip(
                  text: location.displayName,
                  selected: selectedLocation == location,
                  onSelected: () => onLocationChanged?.call(
                    selectedLocation == location ? null : location,
                  ),
                ),
              const SizedBox(width: 8),
              _GroupLabel(text: 'Status'),
              for (final status in ValidationStatus.values)
                _CompactFilterChip(
                  text: status.displayName,
                  selected: selectedStatus == status,
                  onSelected: () => onStatusChanged?.call(
                    selectedStatus == status ? null : status,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CompactFilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onSelected;

  const _CompactFilterChip({
    required this.text,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => onSelected(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
