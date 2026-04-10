import 'package:path/path.dart';
import '../models/analysis_severity.dart';
import '../models/skill_context.dart';
import '../models/skill_rule.dart';
import '../models/validation_error.dart';

/// Enforces that links in SKILL.md do not use absolute paths.
class AbsolutePathsRule extends SkillRule {
  AbsolutePathsRule({this.severity = defaultSeverity});

  static const String ruleName = 'check-absolute-paths';
  static const AnalysisSeverity defaultSeverity = AnalysisSeverity.warning;

  @override
  String get name => ruleName;

  @override
  final AnalysisSeverity severity;

  static final _markdownLinkRegex = RegExp(r'\[.*?\]\((.*?)\)');
  static const _skillFileName = 'SKILL.md';

  @override
  Future<List<ValidationError>> validate(SkillContext context) async {
    final errors = <ValidationError>[];

    // Extract content after YAML frontmatter
    final skillStartRegex = RegExp(r'^---\s*\n(.*?)\n---\s*\n', dotAll: true);
    final RegExpMatch? match = skillStartRegex.firstMatch(context.rawContent);
    final String markdownContent =
        match != null ? context.rawContent.substring(match.end) : context.rawContent;

    for (final RegExpMatch linkMatch in _markdownLinkRegex.allMatches(markdownContent)) {
      final String path = linkMatch.group(1)!;
      if (isAbsolute(path) || windows.isAbsolute(path)) {
        errors.add(ValidationError(
          ruleId: name,
          severity: severity,
          file: _skillFileName,
          message: 'Absolute filepath found in link: $path',
        ));
      }
    }

    return errors;
  }
}
