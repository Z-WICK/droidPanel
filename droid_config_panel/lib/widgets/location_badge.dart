import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/enums.dart';

class LocationBadge extends StatelessWidget {
  final ConfigurationLocation location;

  const LocationBadge({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProject = location == ConfigurationLocation.project;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isProject
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        location.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isProject
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
