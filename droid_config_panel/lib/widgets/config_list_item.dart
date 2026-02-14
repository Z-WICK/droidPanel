import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/theme/app_theme.dart';
import 'package:droid_config_panel/widgets/entrance_transition.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';
import 'package:droid_config_panel/widgets/location_badge.dart';

class ConfigListItem extends StatefulWidget {
  final Configuration configuration;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ConfigListItem({
    super.key,
    required this.configuration,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ConfigListItem> createState() => _ConfigListItemState();
}

class _ConfigListItemState extends State<ConfigListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _colorForType(widget.configuration.type, theme);

    return EntranceTransition(
      delay: Duration(
        milliseconds: 16 * (widget.configuration.id.hashCode.abs() % 8),
      ),
      duration: const Duration(milliseconds: 320),
      beginOffset: const Offset(0, 0.02),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _isHovered ? 1.003 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
            child: GlassSurface(
              borderRadius: 20,
              blur: 22,
              shadowOpacity: _isHovered ? 1.05 : 0.95,
              tintColor: theme.colorScheme.surfaceContainer.withValues(
                alpha: _isHovered ? 0.82 : 0.74,
              ),
              borderColor: theme.colorScheme.outlineVariant.withValues(
                alpha: _isHovered ? 0.86 : 0.66,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TypeIcon(
                          icon: _iconForType(widget.configuration.type),
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.configuration.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.12,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusBadge(
                                    status: widget.configuration.status,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _TokenChip(
                                    icon: _iconForType(
                                      widget.configuration.type,
                                    ),
                                    text: widget.configuration.type.displayName,
                                  ),
                                  LocationBadge(
                                    location: widget.configuration.location,
                                  ),
                                ],
                              ),
                              if (widget
                                  .configuration
                                  .description
                                  .isNotEmpty) ...[
                                const SizedBox(height: 9),
                                Text(
                                  widget.configuration.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 9),
                              Text(
                                widget.configuration.filePath,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onEdit != null ||
                            widget.onDelete != null) ...[
                          const SizedBox(width: 8),
                          AnimatedOpacity(
                            opacity: _isHovered ? 1 : 0.82,
                            duration: const Duration(milliseconds: 180),
                            child: PopupMenuButton<String>(
                              tooltip: 'Actions',
                              icon: const Icon(Icons.more_horiz_rounded),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  widget.onEdit?.call();
                                } else if (value == 'delete') {
                                  widget.onDelete?.call();
                                }
                              },
                              itemBuilder: (context) => [
                                if (widget.onEdit != null)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                if (widget.onDelete != null)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 18),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(ConfigurationType type) {
    return switch (type) {
      ConfigurationType.droid => Icons.smart_toy_outlined,
      ConfigurationType.skill => Icons.psychology_alt_outlined,
      ConfigurationType.hook => Icons.bolt_outlined,
      ConfigurationType.mcpServer => Icons.hub_outlined,
    };
  }

  Color _colorForType(ConfigurationType type, ThemeData theme) {
    return switch (type) {
      ConfigurationType.droid => AppTheme.info,
      ConfigurationType.skill => AppTheme.success,
      ConfigurationType.hook => AppTheme.warning,
      ConfigurationType.mcpServer => theme.colorScheme.tertiary,
    };
  }
}

class _TokenChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TokenChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TypeIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ValidationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      ValidationStatus.valid => AppTheme.success,
      ValidationStatus.invalid => theme.colorScheme.error,
      ValidationStatus.unknown => theme.colorScheme.outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.33)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.displayName,
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
