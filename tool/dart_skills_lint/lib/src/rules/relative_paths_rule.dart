import 'dart:io';
import 'package:path/path.dart';
import '../models/analysis_severity.dart';
import '../models/skill_context.dart';
import '../models/skill_rule.dart';
import '../models/validation_error.dart';

/// Enforces that relative links in SKILL.md point to existing files.
class RelativePathsRule extends SkillRule {
  RelativePathsRule({this.severity = defaultSeverity});

  static const String ruleName = 'check-relative-paths';
  static const AnalysisSeverity defaultSeverity = AnalysisSeverity.disabled;

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

      // Skip absolute paths (handled by AbsolutePathsRule)
      if (isAbsolute(path) || windows.isAbsolute(path)) {
        continue;
      }

      try {
        final Uri uri = Uri.parse(path);
        if (uri.hasScheme || path.startsWith('#')) {
          continue; // Ignore web URLs, email links, anchors, etc.
        }
      } catch (_) {
        // If Uri parsing fails, treat it as a potential filepath.
      }

      final linkedFile = File(join(context.directory.path, path));
      if (!linkedFile.existsSync()) {
        errors.add(ValidationError(
          ruleId: name,
          severity: severity,
          file: _skillFileName,
          message: 'Linked file does not exist: $path',
        ));
      }
    }

    return errors;
  }
}
