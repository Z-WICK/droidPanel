import 'package:droid_config_panel/models/configuration.dart';
import 'package:droid_config_panel/models/enums.dart';

class MCPServerConfig extends Configuration {
  final String? command;
  final String? url;
  final List<String> args;
  final Map<String, String> env;

  MCPServerConfig({
    required super.id,
    required super.name,
    super.description,
    required super.location,
    required super.filePath,
    required super.content,
    super.status,
    required super.createdAt,
    required super.modifiedAt,
    this.command,
    this.url,
    this.args = const [],
    this.env = const {},
  }) : super(type: ConfigurationType.mcpServer);

  factory MCPServerConfig.fromConfiguration(
    Configuration config, {
    String? command,
    String? url,
    List<String>? args,
    Map<String, String>? env,
  }) {
    return MCPServerConfig(
      id: config.id,
      name: config.name,
      description: config.description,
      location: config.location,
      filePath: config.filePath,
      content: config.content,
      status: config.status,
      createdAt: config.createdAt,
      modifiedAt: config.modifiedAt,
      command: command,
      url: url,
      args: args ?? [],
      env: env ?? {},
    );
  }

  @override
  MCPServerConfig copyWith({
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
    String? command,
    String? url,
    List<String>? args,
    Map<String, String>? env,
  }) {
    return MCPServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      filePath: filePath ?? this.filePath,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      command: command ?? this.command,
      url: url ?? this.url,
      args: args ?? this.args,
      env: env ?? this.env,
    );
  }
}
