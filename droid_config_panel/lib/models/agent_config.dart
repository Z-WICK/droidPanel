import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class AgentConfig extends Configuration {
  final String subagentType;
  final String prompt;

  AgentConfig({
    required super.id,
    required super.name,
    super.description,
    required super.location,
    required super.filePath,
    required super.content,
    super.status,
    required super.createdAt,
    required super.modifiedAt,
    required this.subagentType,
    required this.prompt,
  }) : super(type: ConfigurationType.agent);

  factory AgentConfig.fromConfiguration(
    Configuration config, {
    required String subagentType,
    required String prompt,
  }) {
    return AgentConfig(
      id: config.id,
      name: config.name,
      description: config.description,
      location: config.location,
      filePath: config.filePath,
      content: config.content,
      status: config.status,
      createdAt: config.createdAt,
      modifiedAt: config.modifiedAt,
      subagentType: subagentType,
      prompt: prompt,
    );
  }

  @override
  AgentConfig copyWith({
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
    String? subagentType,
    String? prompt,
  }) {
    return AgentConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      subagentType: subagentType ?? this.subagentType,
      prompt: prompt ?? this.prompt,
    );
  }
}
