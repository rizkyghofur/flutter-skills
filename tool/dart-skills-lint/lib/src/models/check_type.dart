// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Severity level for a specific analysis rule.
enum AnalysisSeverity {
  /// Check is completely disabled.
  disabled,

  /// Failures are reported as warnings and do not fail the overall validation.
  warning,

  /// Failures are reported as errors and fail the overall validation.
  error,
}

/// Encapsulates metadata and severity state for a specific validation rule.
class CheckType {
  CheckType({
    required this.name,
    required this.defaultSeverity,
  }) : severity = defaultSeverity;
  final String name;

  /// The default severity if not overridden by config or flags.
  final AnalysisSeverity defaultSeverity;

  /// The current resolved severity for this run.
  AnalysisSeverity severity;
}
