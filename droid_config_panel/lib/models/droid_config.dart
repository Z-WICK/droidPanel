import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class DroidConfig extends Configuration {
  final String? model;
  final String? systemPrompt;
  final List<String> capabilities;

  DroidConfig({
    required super.id,
    required super.name,
    super.description,
    required super.location,
    required super.filePath,
    required super.content,
    super.status,
    required super.createdAt,
    required super.modifiedAt,
    this.model,
    this.systemPrompt,
    this.capabilities = const [],
  }) : super(type: ConfigurationType.droid);

  factory DroidConfig.fromConfiguration(
    Configuration config, {
    String? model,
    String? systemPrompt,
    List<String>? capabilities,
  }) {
    return DroidConfig(
      id: config.id,
      name: config.name,
      description: config.description,
      location: config.location,
      filePath: config.filePath,
      content: config.content,
      status: config.status,
      createdAt: config.createdAt,
      modifiedAt: config.modifiedAt,
      model: model,
      systemPrompt: systemPrompt,
      capabilities: capabilities ?? [],
    );
  }

  @override
  DroidConfig copyWith({
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
    String? model,
    String? systemPrompt,
    List<String>? capabilities,
  }) {
    return DroidConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      capabilities: capabilities ?? this.capabilities,
    );
  }
}
