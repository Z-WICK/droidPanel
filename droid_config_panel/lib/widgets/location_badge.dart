import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/enums.dart';

class LocationBadge extends StatelessWidget {
  final ConfigurationLocation location;

  const LocationBadge({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProject = location == ConfigurationLocation.project;
    final color = isProject
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProject ? Icons.folder_outlined : Icons.person_outline,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            location.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
