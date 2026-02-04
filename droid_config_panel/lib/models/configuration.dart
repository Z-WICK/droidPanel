import 'package:droid_config_panel/models/enums.dart';

class Configuration {
  final String id;
  final String name;
  final ConfigurationType type;
  final String description;
  final ConfigurationLocation location;
  final String filePath;
  final String content;
  final ValidationStatus status;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Configuration({
    required this.id,
    required this.name,
    required this.type,
    this.description = '',
    required this.location,
    required this.filePath,
    required this.content,
    this.status = ValidationStatus.unknown,
    required this.createdAt,
    required this.modifiedAt,
  });

  Configuration copyWith({
    String? id,
    String? name,
    ConfigurationType? type,
    String? description,
    ConfigurationLocation? location,
    String? filePath,
    String? content,
    ValidationStatus? status,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Configuration(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  static String generateId(String filePath) {
    return filePath.hashCode.toRadixString(16);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Configuration && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Configuration(id: $id, name: $name, type: ${type.displayName}, location: ${location.displayName})';
  }
}
