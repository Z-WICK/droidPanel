import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/enums.dart';

class TypeSelector extends StatelessWidget {
  final ConfigurationType? selectedType;
  final ValueChanged<ConfigurationType?> onChanged;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ConfigurationType>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'Configuration Type',
        border: OutlineInputBorder(),
      ),
      items: ConfigurationType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(_getIconForType(type), size: 20),
              const SizedBox(width: 8),
              Text(type.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select a configuration type';
        }
        return null;
      },
    );
  }

  IconData _getIconForType(ConfigurationType type) {
    switch (type) {
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
