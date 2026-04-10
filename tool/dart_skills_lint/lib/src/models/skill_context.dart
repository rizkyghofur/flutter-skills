import 'dart:io';
import 'package:yaml/yaml.dart';

/// Context provided to [SkillRule]s during validation.
class SkillContext {
  SkillContext({
    required this.directory,
    required this.rawContent,
    this.parsedYaml,
    this.yamlParsingError,
  });

  final Directory directory;

  /// Guaranteed to be non-null because we only run rules if SKILL.md exists.
  final String rawContent;

  final YamlMap? parsedYaml;

  final String? yamlParsingError;
}
