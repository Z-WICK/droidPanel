import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/enums.dart';

class TypeSelector extends StatelessWidget {
  final ConfigurationType? selectedType;
  final ValueChanged<ConfigurationType?> onChanged;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration Type',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in ConfigurationType.values)
              _TypeChip(
                icon: _getIconForType(type),
                label: type.displayName,
                selected: selectedType == type,
                onTap: () => onChanged(selectedType == type ? null : type),
              ),
          ],
        ),
      ],
    );
  }

  IconData _getIconForType(ConfigurationType type) {
    return switch (type) {
      ConfigurationType.droid => Icons.smart_toy_outlined,
      ConfigurationType.skill => Icons.psychology_alt_outlined,
      ConfigurationType.hook => Icons.bolt_outlined,
      ConfigurationType.mcpServer => Icons.hub_outlined,
    };
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainer.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.76)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.64),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
