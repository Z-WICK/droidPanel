import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';
import 'package:droid_config_panel/models/validation_result.dart';
import 'package:droid_config_panel/providers/config_provider.dart';
import 'package:droid_config_panel/providers/providers.dart';
import 'package:droid_config_panel/widgets/code_editor.dart';
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
    _descriptionController = TextEditingController(text: widget.configuration.description);
    _content = widget.configuration.content;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    try {
      final validationService = ref.read(validationServiceProvider);
      final result = await validationService.validate(
        content: _content,
        type: widget.configuration.type,
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final validationService = ref.read(validationServiceProvider);
      final result = await validationService.validate(
        content: _content,
        type: widget.configuration.type,
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

      await ref.read(configurationStateProvider.notifier).updateConfiguration(
        id: widget.configuration.id,
        content: _content,
        name: _nameController.text.trim() != widget.configuration.name
            ? _nameController.text.trim()
            : null,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration updated successfully'),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.configuration.name}'),
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
                    Row(
                      children: [
                        Text(
                          'Configuration Details',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Chip(
                          label: Text(widget.configuration.type.displayName),
                          avatar: Icon(_getIconForType(), size: 18),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(widget.configuration.location.displayName),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() => _hasChanges = true),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (_) => setState(() => _hasChanges = true),
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
                    Text(
                      'Configuration Content',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: CodeEditorWidget(
                        initialContent: _content,
                        onChanged: (value) {
                          _content = value;
                          _hasChanges = true;
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

  IconData _getIconForType() {
    switch (widget.configuration.type) {
      case ConfigurationType.droid:
        return Icons.smart_toy;
      case ConfigurationType.skill:
        return Icons.psychology;
      case ConfigurationType.agent:
        return Icons.support_agent;
      case ConfigurationType.hook:
        return Icons.webhook;
      case ConfigurationType.mcpServer:
        return Icons.dns;
    }
  }
}
