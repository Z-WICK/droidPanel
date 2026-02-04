import 'package:flutter/material.dart';
import 'package:droid_config_panel/models/enums.dart';

class LocationSelector extends StatelessWidget {
  final ConfigurationLocation? selectedLocation;
  final ValueChanged<ConfigurationLocation?> onChanged;

  const LocationSelector({
    super.key,
    required this.selectedLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ConfigurationLocation>(
      value: selectedLocation,
      decoration: const InputDecoration(
        labelText: 'Storage Location',
        border: OutlineInputBorder(),
      ),
      items: ConfigurationLocation.values.map((location) {
        return DropdownMenuItem(
          value: location,
          child: Row(
            children: [
              Icon(
                location == ConfigurationLocation.project
                    ? Icons.folder
                    : Icons.home,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(location.displayName),
              const SizedBox(width: 8),
              Text(
                location == ConfigurationLocation.project
                    ? '(.factory/)'
                    : '(~/.factory/)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select a storage location';
        }
        return null;
      },
    );
  }
}
