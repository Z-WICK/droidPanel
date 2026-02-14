import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/exceptions.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/providers/config_provider.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/widgets/app_background.dart';
import 'package:droid_config_panel/widgets/code_editor.dart';
import 'package:droid_config_panel/widgets/delete_confirmation_dialog.dart';
import 'package:droid_config_panel/widgets/entrance_transition.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';
import 'package:droid_config_panel/widgets/validation_result_display.dart';

class EditScreen extends ConsumerStatefulWidget {
  final Configuration configuration;

  const EditScreen({super.key, required this.configuration});

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _content;

  ValidationResult? _validationResult;
  bool _isValidating = false;
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.configuration.name);
    _descriptionController = TextEditingController(
      text: widget.configuration.description,
    );
    _content = widget.configuration.content;

    _nameController.addListener(_markAsChanged);
    _descriptionController.addListener(_markAsChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_markAsChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_markAsChanged)
      ..dispose();
    super.dispose();
  }

  void _markAsChanged() {
    final changed =
        _nameController.text.trim() != widget.configuration.name ||
        _descriptionController.text.trim() !=
            widget.configuration.description ||
        _content != widget.configuration.content;

    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> _validate() async {
    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    final validationService = ref.read(validationServiceProvider);
    final result = await validationService.validate(
      content: _content,
      type: widget.configuration.type,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _validationResult = result;
      _isValidating = false;
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    if (!_hasChanges) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No changes to save')));
      return;
    }

    setState(() => _isSaving = true);

    final validationService = ref.read(validationServiceProvider);
    final result = await validationService.validate(
      content: _content,
      type: widget.configuration.type,
    );

    if (!mounted) {
      return;
    }

    if (!result.isValid) {
      setState(() {
        _validationResult = result;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save: configuration has validation errors'),
        ),
      );
      return;
    }

    try {
      await ref
          .read(configurationStateProvider.notifier)
          .updateConfiguration(
            id: widget.configuration.id,
            content: _content,
            name: _nameController.text.trim() != widget.configuration.name
                ? _nameController.text.trim()
                : null,
            description: _descriptionController.text.trim(),
            expectedModifiedAt: widget.configuration.modifiedAt,
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configuration updated')));
      Navigator.pop(context, true);
    } on ConcurrentModificationException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: 'Reload',
            onPressed: () {
              if (mounted) {
                Navigator.pop(context, false);
              }
            },
          ),
        ),
      );
      return;
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $error')));
      return;
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasChanges || _isSaving) {
      return true;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Leave without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _deleteCurrentConfiguration() async {
    if (_isSaving) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          DeleteConfirmationDialog(configuration: widget.configuration),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(configurationStateProvider.notifier)
          .deleteConfiguration(widget.configuration.id);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configuration deleted')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_hasChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _isSaving || !_hasChanges) {
          return;
        }
        final discard = await _confirmDiscardChanges();
        if (discard && mounted) {
          Navigator.of(this.context).pop();
        }
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () {
            if (!_isSaving) {
              _save();
            }
          },
          const SingleActivator(LogicalKeyboardKey.enter, meta: true): () {
            if (!_isValidating) {
              _validate();
            }
          },
          const SingleActivator(LogicalKeyboardKey.delete, meta: true): () {
            _deleteCurrentConfiguration();
          },
          const SingleActivator(LogicalKeyboardKey.backspace, meta: true): () {
            _deleteCurrentConfiguration();
          },
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Navigator.maybePop(context);
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Edit ${widget.configuration.name}'),
              actions: [
                TextButton.icon(
                  onPressed: _isValidating ? null : _validate,
                  icon: _isValidating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fact_check_outlined),
                  label: const Text('Validate'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete (⌘⌫)',
                  onPressed: _isSaving ? null : _deleteCurrentConfiguration,
                  icon: const Icon(Icons.delete_outline),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: AppBackground(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 980;
                      final metaPanel = _buildMetaPanel(theme, isDark);
                      final editorPanel = _buildEditorPanel(
                        theme,
                        isDark,
                        compact: compact,
                      );

                      if (compact) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              metaPanel,
                              const SizedBox(height: 12),
                              if (_validationResult != null || _isValidating)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ValidationResultDisplay(
                                    result: _validationResult,
                                    isValidating: _isValidating,
                                  ),
                                ),
                              editorPanel,
                            ],
                          ),
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 380, child: metaPanel),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                if (_validationResult != null || _isValidating)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ValidationResultDisplay(
                                      result: _validationResult,
                                      isValidating: _isValidating,
                                    ),
                                  ),
                                Expanded(child: editorPanel),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaPanel(ThemeData theme, bool isDark) {
    return EntranceTransition(
      delay: const Duration(milliseconds: 20),
      child: GlassSurface(
        borderRadius: 22,
        blur: 28,
        tintColor: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.54 : 0.88,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Configuration Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.32,
                        ),
                      ),
                    ),
                    child: Text(
                      'Unsaved',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    _iconForType(widget.configuration.type),
                    size: 16,
                  ),
                  label: Text(widget.configuration.type.displayName),
                ),
                Chip(label: Text(widget.configuration.location.displayName)),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Configuration name',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What this configuration does',
              ),
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Text(
              widget.configuration.filePath,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorPanel(
    ThemeData theme,
    bool isDark, {
    required bool compact,
  }) {
    return EntranceTransition(
      delay: const Duration(milliseconds: 90),
      child: GlassSurface(
        borderRadius: 22,
        blur: 30,
        tintColor: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.5 : 0.86,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Configuration Content',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Shortcut: ⌘Enter validate, ⌘S save',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (compact)
              SizedBox(
                height: 460,
                child: CodeEditorWidget(
                  initialContent: _content,
                  onChanged: (value) {
                    _content = value;
                    _markAsChanged();
                    if (_validationResult != null) {
                      setState(() => _validationResult = null);
                    }
                  },
                ),
              )
            else
              Expanded(
                child: CodeEditorWidget(
                  initialContent: _content,
                  onChanged: (value) {
                    _content = value;
                    _markAsChanged();
                    if (_validationResult != null) {
                      setState(() => _validationResult = null);
                    }
                  },
                ),
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
}
