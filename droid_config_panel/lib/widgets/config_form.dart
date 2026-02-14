import 'package:flutter/material.dart';

class ConfigForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState>? formKey;

  const ConfigForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Metadata',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'example: core-agent',
              helperText: 'Letters, numbers, hyphens, underscores only',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              if (value.contains(' ')) {
                return 'Name cannot contain spaces';
              }
              if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
                return 'Name can only contain letters, numbers, hyphens, and underscores';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What this configuration is used for',
            ),
            minLines: 2,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
