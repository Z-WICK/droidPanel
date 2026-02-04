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
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter configuration name',
              border: OutlineInputBorder(),
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
              hintText: 'Enter a brief description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
