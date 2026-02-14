import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Configuration configuration;

  const DeleteConfirmationDialog({super.key, required this.configuration});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('Delete Configuration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this configuration?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          GlassSurface(
            borderRadius: 14,
            blur: 14,
            padding: const EdgeInsets.all(12),
            tintColor: theme.colorScheme.error.withValues(
              alpha: isDark ? 0.16 : 0.08,
            ),
            borderColor: theme.colorScheme.error.withValues(
              alpha: isDark ? 0.6 : 0.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      configuration.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Type: ${configuration.type.displayName}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Location: ${configuration.location.displayName}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
