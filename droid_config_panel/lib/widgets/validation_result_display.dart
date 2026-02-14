import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/models/enums.dart';
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
        borderRadius: 20,
        blur: 20,
        padding: const EdgeInsets.all(12),
        tintColor: theme.colorScheme.primary.withValues(
          alpha: isDark ? 0.12 : 0.14,
        ),
        borderColor: theme.colorScheme.primary.withValues(
          alpha: isDark ? 0.5 : 0.38,
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Validating...'),
          ],
        ),
      );
    }

    if (result == null) {
      return const SizedBox.shrink();
    }

    final isValid = result!.isValid;
    final hasWarnings = result!.warnings.isNotEmpty;
    final accent = isValid
        ? (hasWarnings ? const Color(0xFFDA7B13) : const Color(0xFF0EA76B))
        : theme.colorScheme.error;

    return GlassSurface(
      borderRadius: 20,
      blur: 20,
      padding: const EdgeInsets.all(12),
      tintColor: accent.withValues(alpha: isDark ? 0.13 : 0.11),
      borderColor: accent.withValues(alpha: isDark ? 0.62 : 0.48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid
                    ? (hasWarnings ? Icons.warning : Icons.check_circle)
                    : Icons.error,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isValid
                    ? (hasWarnings ? 'Valid with warnings' : 'Valid')
                    : 'Invalid',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (result!.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final error in result!.errors) _buildMessageItem(error, theme),
          ],
          if (result!.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final warning in result!.warnings)
              _buildMessageItem(warning, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageItem(ValidationError error, ThemeData theme) {
    Color color;
    IconData icon;

    switch (error.severity) {
      case ValidationSeverity.error:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case ValidationSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning_amber;
        break;
      case ValidationSeverity.info:
        color = Colors.blue;
        icon = Icons.info_outline;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
