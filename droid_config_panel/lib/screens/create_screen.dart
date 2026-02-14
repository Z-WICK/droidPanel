import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/providers/config_provider.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/widgets/app_background.dart';
import 'package:droid_config_panel/widgets/code_editor.dart';
import 'package:droid_config_panel/widgets/config_form.dart';
import 'package:droid_config_panel/widgets/entrance_transition.dart';
import 'package:droid_config_panel/widgets/glass_surface.dart';
import 'package:droid_config_panel/widgets/location_selector.dart';
import 'package:droid_config_panel/widgets/type_selector.dart';
import 'package:droid_config_panel/widgets/validation_result_display.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  ConfigurationType? _selectedType = ConfigurationType.droid;
  ConfigurationLocation? _selectedLocation = ConfigurationLocation.project;
  String _content = '';
  ValidationResult? _validationResult;
  bool _isValidating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _content = _getDefaultContent(ConfigurationType.droid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getDefaultContent(ConfigurationType type) {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'new-config';
    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'Description here';

    switch (type) {
      case ConfigurationType.droid:
        return '''---
name: $name
description: $description
model: sonnet
---

You are a helpful assistant.
''';
      case ConfigurationType.skill:
        return '''---
name: $name
description: $description
---

Skill instructions here.
''';
      case ConfigurationType.hook:
        return '''{
  "event": "PreToolUse",
  "name": "$name",
  "matcher": "$name",
  "action": "echo Hook executed"
}''';
      case ConfigurationType.mcpServer:
        return '''{
  "name": "$name",
  "description": "$description",
  "command": "npx",
  "args": [
    "-y",
    "some-mcp-server"
  ]
}''';
    }
  }

  Future<void> _validate() async {
    final selectedType = _selectedType;
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a configuration type first'),
        ),
      );
      return;
    }

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    final validationService = ref.read(validationServiceProvider);
    final result = await validationService.validate(
      content: _content,
      type: selectedType,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final selectedType = _selectedType;
    final selectedLocation = _selectedLocation;
    if (selectedType == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select type and location')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final validationService = ref.read(validationServiceProvider);
    final result = await validationService.validate(
      content: _content,
      type: selectedType,
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
          .createConfiguration(
            name: _nameController.text.trim(),
            type: selectedType,
            location: selectedLocation,
            content: _content,
            description: _descriptionController.text.trim(),
          );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Configuration created')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $error')));
      return;
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CallbackShortcuts(
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
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.maybePop(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Configuration'),
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
                    final metaColumn = _buildMetaPanel(theme, isDark);
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
                            metaColumn,
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
                        SizedBox(width: 380, child: metaColumn),
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
            Text(
              'Setup',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Define type, location and metadata first.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            TypeSelector(
              selectedType: _selectedType,
              onChanged: (type) {
                setState(() {
                  _selectedType = type;
                  if (type != null) {
                    _content = _getDefaultContent(type);
                  }
                  _validationResult = null;
                });
              },
            ),
            const SizedBox(height: 12),
            LocationSelector(
              selectedLocation: _selectedLocation,
              onChanged: (location) {
                setState(() => _selectedLocation = location);
              },
            ),
            const SizedBox(height: 14),
            ConfigForm(
              formKey: _formKey,
              nameController: _nameController,
              descriptionController: _descriptionController,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Configuration Content',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_selectedType != null)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _content = _getDefaultContent(_selectedType!);
                        _validationResult = null;
                      });
                    },
                    icon: const Icon(Icons.restart_alt_rounded, size: 17),
                    label: const Text('Reset Template'),
                  ),
              ],
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
}
