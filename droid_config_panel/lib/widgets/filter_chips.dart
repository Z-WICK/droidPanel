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
      borderRadius: 16,
      blur: 20,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _FilterMenuButton<ConfigurationType>(
            label: 'Type',
            selectedText: selectedType?.displayName ?? 'All',
            values: ConfigurationType.values,
            valueLabel: (value) => value.displayName,
            onSelected: onTypeChanged,
          ),
          _FilterMenuButton<ConfigurationLocation>(
            label: 'Location',
            selectedText: selectedLocation?.displayName ?? 'All',
            values: ConfigurationLocation.values,
            valueLabel: (value) => value.displayName,
            onSelected: onLocationChanged,
          ),
          _FilterMenuButton<ValidationStatus>(
            label: 'Status',
            selectedText: selectedStatus?.displayName ?? 'All',
            values: ValidationStatus.values,
            valueLabel: (value) => value.displayName,
            onSelected: onStatusChanged,
          ),
          if (hasFilters)
            TextButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            )
          else
            Text(
              'No active filters',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterMenuButton<T> extends StatelessWidget {
  final String label;
  final String selectedText;
  final List<T> values;
  final String Function(T value) valueLabel;
  final ValueChanged<T?>? onSelected;

  const _FilterMenuButton({
    required this.label,
    required this.selectedText,
    required this.values,
    required this.valueLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<T?>(
      tooltip: '$label filter',
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          PopupMenuItem<T?>(value: null, child: Text('$label: All')),
          for (final value in values)
            PopupMenuItem<T?>(
              value: value,
              child: Text('$label: ${valueLabel(value)}'),
            ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.66),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selectedText',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
