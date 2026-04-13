// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'models/skill_context.dart';

/// Interface for rules that support fixes.
/// Kept internal to the package for now.
abstract class FixableRule {
  /// Returns the updated content of the file at [filePath].
  /// [currentContent] is the content after previous fixes have been applied.
  /// If the rule does not support fixing the file at [filePath], it should return [currentContent].
  Future<String> fix(String filePath, String currentContent, SkillContext context);
}
