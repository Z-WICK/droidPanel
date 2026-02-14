import 'package:yaml/yaml.dart';

class YamlUtils {
  static Map<String, dynamic>? parseYaml(String content) {
    try {
      final yaml = loadYaml(content);
      if (yaml is YamlMap) {
        return _convertYamlMap(yaml);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> _convertYamlMap(YamlMap yamlMap) {
    final result = <String, dynamic>{};
    for (final entry in yamlMap.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is YamlMap) {
        result[key] = _convertYamlMap(value);
      } else if (value is YamlList) {
        result[key] = _convertYamlList(value);
      } else {
        result[key] = value;
      }
    }
    return result;
  }

  static List<dynamic> _convertYamlList(YamlList yamlList) {
    return yamlList.map((item) {
      if (item is YamlMap) {
        return _convertYamlMap(item);
      } else if (item is YamlList) {
        return _convertYamlList(item);
      }
      return item;
    }).toList();
  }

  static ({Map<String, dynamic>? frontmatter, String body})
  parseMarkdownWithFrontmatter(String content) {
    final lines = content.split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') {
      return (frontmatter: null, body: content);
    }

    int endIndex = -1;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim() == '---') {
        endIndex = i;
        break;
      }
    }

    if (endIndex == -1) {
      return (frontmatter: null, body: content);
    }

    final frontmatterContent = lines.sublist(1, endIndex).join('\n');
    final bodyContent = lines.sublist(endIndex + 1).join('\n').trim();
    final frontmatter = parseYaml(frontmatterContent);

    return (frontmatter: frontmatter, body: bodyContent);
  }

  static String generateYamlString(
    Map<String, dynamic> data, {
    int indent = 0,
  }) {
    final buffer = StringBuffer();
    final prefix = '  ' * indent;

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        buffer.writeln('$prefix$key:');
        buffer.write(generateYamlString(value, indent: indent + 1));
      } else if (value is List) {
        buffer.writeln('$prefix$key:');
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            buffer.writeln('$prefix  -');
            buffer.write(generateYamlString(item, indent: indent + 2));
          } else {
            buffer.writeln('$prefix  - $item');
          }
        }
      } else if (value is String && value.contains('\n')) {
        buffer.writeln('$prefix$key: |');
        for (final line in value.split('\n')) {
          buffer.writeln('$prefix  $line');
        }
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    }

    return buffer.toString();
  }

  static String generateMarkdownWithFrontmatter(
    Map<String, dynamic> frontmatter,
    String body,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('---');
    buffer.write(generateYamlString(frontmatter));
    buffer.writeln('---');
    buffer.writeln();
    buffer.write(body);
    return buffer.toString();
  }
}
