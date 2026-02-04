enum ConfigurationType {
  droid,
  skill,
  agent,
  hook,
  mcpServer;

  String get displayName {
    switch (this) {
      case ConfigurationType.droid:
        return 'Droid';
      case ConfigurationType.skill:
        return 'Skill';
      case ConfigurationType.agent:
        return 'Agent';
      case ConfigurationType.hook:
        return 'Hook';
      case ConfigurationType.mcpServer:
        return 'MCP Server';
    }
  }

  String get directoryName {
    switch (this) {
      case ConfigurationType.droid:
        return 'droids';
      case ConfigurationType.skill:
        return 'skills';
      case ConfigurationType.agent:
        return 'agents';
      case ConfigurationType.hook:
        return 'hooks';
      case ConfigurationType.mcpServer:
        return 'mcp';
    }
  }

  List<String> get fileExtensions {
    switch (this) {
      case ConfigurationType.droid:
      case ConfigurationType.skill:
        return ['.md'];
      case ConfigurationType.agent:
        return ['.md', '.yaml'];
      case ConfigurationType.hook:
      case ConfigurationType.mcpServer:
        return ['.yaml'];
    }
  }
}

enum ConfigurationLocation {
  project,
  personal;

  String get displayName {
    switch (this) {
      case ConfigurationLocation.project:
        return 'Project';
      case ConfigurationLocation.personal:
        return 'Personal';
    }
  }
}

enum ValidationStatus {
  valid,
  invalid,
  unknown;

  String get displayName {
    switch (this) {
      case ValidationStatus.valid:
        return 'Valid';
      case ValidationStatus.invalid:
        return 'Invalid';
      case ValidationStatus.unknown:
        return 'Unknown';
    }
  }
}

enum ValidationSeverity {
  error,
  warning,
  info;

  String get displayName {
    switch (this) {
      case ValidationSeverity.error:
        return 'Error';
      case ValidationSeverity.warning:
        return 'Warning';
      case ValidationSeverity.info:
        return 'Info';
    }
  }
}
