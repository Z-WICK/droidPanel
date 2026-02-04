import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class SkillConfig extends Configuration {
  final List<String> triggers;
  final String? when;

  SkillConfig({
    required super.id,
    required super.name,
    super.description,
    required super.location,
    required super.filePath,
    required super.content,
    super.status,
    required super.createdAt,
    required super.modifiedAt,
    this.triggers = const [],
    this.when,
  }) : super(type: ConfigurationType.skill);

  factory SkillConfig.fromConfiguration(
    Configuration config, {
    List<String>? triggers,
    String? when,
  }) {
    return SkillConfig(
      id: config.id,
      name: config.name,
      description: config.description,
      location: config.location,
      filePath: config.filePath,
      content: config.content,
      status: config.status,
      createdAt: config.createdAt,
      modifiedAt: config.modifiedAt,
      triggers: triggers ?? [],
      when: when,
    );
  }

  @override
  SkillConfig copyWith({
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
    List<String>? triggers,
    String? when,
  }) {
    return SkillConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      triggers: triggers ?? this.triggers,
      when: when ?? this.when,
    );
  }
}
