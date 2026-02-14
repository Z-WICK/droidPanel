import 'package:flutter/material.dart';

import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
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
    final color = _colorForType(widget.configuration.type);

    return EntranceTransition(
      delay: Duration(
        milliseconds: 18 * (widget.configuration.id.hashCode.abs() % 8),
      ),
      duration: const Duration(milliseconds: 360),
      beginOffset: const Offset(0, 0.025),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          child: GlassSurface(
            borderRadius: 24,
            blur: 24,
            tintColor: theme.colorScheme.surface.withValues(
              alpha: _isHovered ? 0.34 : 0.24,
            ),
            borderColor: theme.colorScheme.outlineVariant.withValues(
              alpha: _isHovered ? 0.65 : 0.4,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TypeIcon(
                        icon: _iconForType(widget.configuration.type),
                        color: color,
                      ),
                      const SizedBox(width: 14),
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
                                          letterSpacing: -0.1,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusIndicator(theme),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Chip(
                                  label: Text(
                                    widget.configuration.type.displayName,
                                  ),
                                  avatar: Icon(
                                    _iconForType(widget.configuration.type),
                                    size: 16,
                                  ),
                                  visualDensity: VisualDensity.compact,
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
                              const SizedBox(height: 8),
                              Text(
                                widget.configuration.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.onEdit != null || widget.onDelete != null) ...[
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          tooltip: 'More actions',
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
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    final status = widget.configuration.status;
    final color = switch (status) {
      ValidationStatus.valid => const Color(0xFF0EA76B),
      ValidationStatus.invalid => theme.colorScheme.error,
      ValidationStatus.unknown => theme.colorScheme.outline,
    };

    return Tooltip(
      message: 'Validation: ${status.displayName}',
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.38),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
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

  Color _colorForType(ConfigurationType type) {
    return switch (type) {
      ConfigurationType.droid => const Color(0xFF1570EF),
      ConfigurationType.skill => const Color(0xFF0EA76B),
      ConfigurationType.hook => const Color(0xFFDA7B13),
      ConfigurationType.mcpServer => const Color(0xFF2B6CB0),
    };
  }
}

class _TypeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TypeIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Icon(icon, color: color),
    );
  }
}
