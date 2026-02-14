import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/theme/app_theme.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';

class ValidationResultDisplay extends StatelessWidget {
  final ValidationResult? result;
  final bool isValidating;

  const ValidationResultDisplay({
    super.key,
    this.result,
    this.isValidating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isValidating) {
      return GlassSurface(
        borderRadius: 18,
        blur: 18,
        padding: const EdgeInsets.all(12),
        tintColor: theme.colorScheme.primary.withValues(
          alpha: isDark ? 0.2 : 0.12,
        ),
        borderColor: theme.colorScheme.primary.withValues(
          alpha: isDark ? 0.62 : 0.42,
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            SizedBox(width: 10),
            Text('Validating content...'),
          ],
        ),
      );
    }

    if (result == null) {
      return const SizedBox.shrink();
    }

    final hasWarnings = result!.warnings.isNotEmpty;
    final isValid = result!.isValid;
    final accent = isValid
        ? (hasWarnings ? AppTheme.warning : AppTheme.success)
        : theme.colorScheme.error;

    return GlassSurface(
      borderRadius: 18,
      blur: 18,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      tintColor: accent.withValues(alpha: isDark ? 0.18 : 0.1),
      borderColor: accent.withValues(alpha: isDark ? 0.68 : 0.48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid
                    ? (hasWarnings
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded)
                    : Icons.error_outline_rounded,
                color: accent,
              ),
              const SizedBox(width: 8),
              Text(
                isValid
                    ? (hasWarnings
                          ? 'Valid with warnings'
                          : 'Validation passed')
                    : 'Validation failed',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (result!.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final error in result!.errors) _MessageItem(error: error),
          ],
          if (result!.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final warning in result!.warnings)
              _MessageItem(error: warning),
          ],
        ],
      ),
    );
  }
}

class _MessageItem extends StatelessWidget {
  final ValidationError error;

  const _MessageItem({required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (error.severity) {
      ValidationSeverity.error => theme.colorScheme.error,
      ValidationSeverity.warning => AppTheme.warning,
      ValidationSeverity.info => AppTheme.info,
    };
    final icon = switch (error.severity) {
      ValidationSeverity.error => Icons.error_outline_rounded,
      ValidationSeverity.warning => Icons.warning_amber_rounded,
      ValidationSeverity.info => Icons.info_outline_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
