import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/theme/app_theme.dart';

class LocationBadge extends StatelessWidget {
  final ConfigurationLocation location;

  const LocationBadge({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProject = location == ConfigurationLocation.project;
    final color = isProject ? AppTheme.info : theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProject ? Icons.folder_outlined : Icons.person_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
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
