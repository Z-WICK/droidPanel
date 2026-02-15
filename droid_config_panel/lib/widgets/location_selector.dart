import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:droid_config_panel/models/enums.dart';

class LocationSelector extends StatelessWidget {
  final ConfigurationLocation? selectedLocation;
  final String? activeProjectPath;
  final ValueChanged<ConfigurationLocation?> onChanged;

  const LocationSelector({
    super.key,
    required this.selectedLocation,
    this.activeProjectPath,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Location',
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
            for (final location in ConfigurationLocation.values)
              _LocationOption(
                icon: location == ConfigurationLocation.project
                    ? Icons.folder_outlined
                    : Icons.person_outline_rounded,
                label: location.displayName,
                pathHint: location == ConfigurationLocation.project
                    ? _buildProjectPathHint(activeProjectPath)
                    : '~/.factory/',
                selected: selectedLocation == location,
                onTap: () =>
                    onChanged(selectedLocation == location ? null : location),
              ),
          ],
        ),
      ],
    );
  }

  String _buildProjectPathHint(String? projectPath) {
    if (projectPath == null || projectPath.trim().isEmpty) {
      return '.factory/';
    }

    final normalized = p.normalize(projectPath);
    final projectName = p.basename(normalized);
    if (projectName.isEmpty ||
        projectName == '.' ||
        projectName == p.separator) {
      return '.factory/';
    }

    return '$projectName/.factory/';
  }
}

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String pathHint;
  final bool selected;
  final VoidCallback onTap;

  const _LocationOption({
    required this.icon,
    required this.label,
    required this.pathHint,
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
        constraints: const BoxConstraints(minWidth: 170),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : theme.colorScheme.surfaceContainer.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.76)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.64),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              pathHint,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.85,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
