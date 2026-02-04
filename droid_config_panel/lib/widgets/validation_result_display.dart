import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/models/enums.dart';

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

    if (isValidating) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? (hasWarnings
                ? Colors.orange.withAlpha(25)
                : Colors.green.withAlpha(25))
            : Colors.red.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? (hasWarnings ? Colors.orange : Colors.green)
              : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid
                    ? (hasWarnings ? Icons.warning : Icons.check_circle)
                    : Icons.error,
                color: isValid
                    ? (hasWarnings ? Colors.orange : Colors.green)
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isValid
                    ? (hasWarnings ? 'Valid with warnings' : 'Valid')
                    : 'Invalid',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isValid
                      ? (hasWarnings ? Colors.orange : Colors.green)
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (result!.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...result!.errors.map((error) => _buildErrorItem(error, theme)),
          ],
          if (result!.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...result!.warnings.map((warning) => _buildErrorItem(warning, theme)),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorItem(ValidationError error, ThemeData theme) {
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
    );
  }
}
