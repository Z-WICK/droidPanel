import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/providers/config_provider.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/widgets/config_form.dart';
import 'package:droid_config_panel/widgets/code_editor.dart';
import 'package:droid_config_panel/widgets/type_selector.dart';
import 'package:droid_config_panel/widgets/location_selector.dart';
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
  
  ConfigurationType? _selectedType;
  ConfigurationLocation? _selectedLocation;
  String _content = '';
  ValidationResult? _validationResult;
  bool _isValidating = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _getDefaultContent(ConfigurationType type) {
    final name = _nameController.text.isNotEmpty ? _nameController.text : 'new-config';
    final description = _descriptionController.text.isNotEmpty 
        ? _descriptionController.text 
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
        return '''name: $name
description: $description
event: pre-commit
action: echo "Hook executed"
''';
      case ConfigurationType.mcpServer:
        return '''name: $name
description: $description
command: npx
args:
  - -y
  - some-mcp-server
''';
    }
  }

  Future<void> _validate() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a configuration type first')),
      );
      return;
    }

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    try {
      final validationService = ref.read(validationServiceProvider);
      final result = await validationService.validate(
        content: _content,
        type: _selectedType!,
      );
      setState(() {
        _validationResult = result;
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select type and location')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final validationService = ref.read(validationServiceProvider);
      final result = await validationService.validate(
        content: _content,
        type: _selectedType!,
      );

      if (!result.isValid) {
        setState(() {
          _validationResult = result;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot save: Configuration has validation errors'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await ref.read(configurationStateProvider.notifier).createConfiguration(
        name: _nameController.text.trim(),
        type: _selectedType!,
        location: _selectedLocation!,
        content: _content,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Configuration'),
        actions: [
          TextButton.icon(
            onPressed: _isValidating ? null : _validate,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Validate'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TypeSelector(
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: LocationSelector(
                            selectedLocation: _selectedLocation,
                            onChanged: (location) {
                              setState(() {
                                _selectedLocation = location;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ConfigForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_validationResult != null || _isValidating)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ValidationResultDisplay(
                  result: _validationResult,
                  isValidating: _isValidating,
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Configuration Content',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (_selectedType != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _content = _getDefaultContent(_selectedType!);
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reset to Template'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: CodeEditorWidget(
                        initialContent: _content,
                        onChanged: (value) {
                          _content = value;
                          _validationResult = null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
