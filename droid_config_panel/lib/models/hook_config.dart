import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class HookConfig extends Configuration {
  final String event;
  final String action;
  final Map<String, dynamic> conditions;

  HookConfig({
    required super.id,
    required super.name,
    super.description,
    required super.location,
    required super.filePath,
    required super.content,
    super.status,
    required super.createdAt,
    required super.modifiedAt,
    required this.event,
    required this.action,
    this.conditions = const {},
  }) : super(type: ConfigurationType.hook);

  factory HookConfig.fromConfiguration(
    Configuration config, {
    required String event,
    required String action,
    Map<String, dynamic>? conditions,
  }) {
    return HookConfig(
      id: config.id,
      name: config.name,
      description: config.description,
      location: config.location,
      filePath: config.filePath,
      content: config.content,
      status: config.status,
      createdAt: config.createdAt,
      modifiedAt: config.modifiedAt,
      event: event,
      action: action,
      conditions: conditions ?? {},
    );
  }

  @override
  HookConfig copyWith({
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
    String? event,
    String? action,
    Map<String, dynamic>? conditions,
  }) {
    return HookConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      event: event ?? this.event,
      action: action ?? this.action,
      conditions: conditions ?? this.conditions,
    );
  }
}
