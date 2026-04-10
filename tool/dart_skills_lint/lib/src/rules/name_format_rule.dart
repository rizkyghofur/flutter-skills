import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import '../models/analysis_severity.dart';
import '../models/skill_context.dart';
import '../models/skill_rule.dart';
import '../models/validation_error.dart';

/// Enforces constraints on the skill name field.
class NameFormatRule extends SkillRule {
  NameFormatRule({this.severity = defaultSeverity});

  static const String ruleName = 'invalid-skill-name';
  static const AnalysisSeverity defaultSeverity = AnalysisSeverity.error;

  @override
  String get name => ruleName;

  @override
  final AnalysisSeverity severity;

  static const maxNameLength = 64;
  static final _validNameRegex = RegExp(r'^[a-z0-9\-]+$');
  static const _skillFileName = 'SKILL.md';
  static const _nameFieldUrl = 'https://agentskills.io/specification#name-field';

  @override
  Future<List<ValidationError>> validate(SkillContext context) async {
    final errors = <ValidationError>[];

    if (context.parsedYaml == null) {
      return errors;
    }

    final YamlMap yaml = context.parsedYaml!;
    final String skillName = yaml['name']?.toString() ?? '';

    if (skillName.isEmpty) {
      return errors; // Handled by required fields check
    }

    if (skillName != skillName.toLowerCase()) {
      errors.add(ValidationError(
        ruleId: name,
        severity: severity,
        file: _skillFileName,
        message: 'Skill name must be lowercase: $skillName (see $_nameFieldUrl)',
      ));
    }

    if (skillName.length > maxNameLength) {
      errors.add(ValidationError(
        ruleId: name,
        severity: severity,
        file: _skillFileName,
        message: 'Skill name too long. Maximum $maxNameLength characters (see $_nameFieldUrl)',
      ));
    }

    if (!_validNameRegex.hasMatch(skillName)) {
      errors.add(ValidationError(
        ruleId: name,
        severity: severity,
        file: _skillFileName,
        message:
            'Skill name contains invalid characters. Only lowercase letters, digits, and hyphens allowed (see $_nameFieldUrl)',
      ));
    }

    if (skillName.startsWith('-') || skillName.endsWith('-')) {
      errors.add(ValidationError(
        ruleId: name,
        severity: severity,
        file: _skillFileName,
        message: 'Skill name cannot have leading or trailing hyphens (see $_nameFieldUrl)',
      ));
    }

    if (skillName.contains('--')) {
      errors.add(ValidationError(
        ruleId: name,
        severity: severity,
        file: _skillFileName,
        message: 'Skill name cannot have consecutive hyphens (see $_nameFieldUrl)',
      ));
    }

    final String dirName = basename(context.directory.path);
    if (skillName != dirName) {
      errors.add(ValidationError(
        ruleId: name,
        severity: severity,
        file: _skillFileName,
        message:
            'Skill name ($skillName) must exactly match the name of its parent directory ($dirName) (see $_nameFieldUrl)',
      ));
    }

    return errors;
  }
}
