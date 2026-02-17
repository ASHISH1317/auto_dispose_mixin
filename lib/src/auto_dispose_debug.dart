/// Configuration class for debugging and performance tracking
/// in AutoDisposeMixin.
///
/// This class allows developers to enable logging and timing
/// diagnostics during development.
///
/// ⚠️ These options are intended for debug/development use only.
/// It is recommended to keep them disabled in production builds.
class AutoDisposeDebug {
  /// Enables detailed disposal logs in the debug console
  /// and DevTools.
  ///
  /// When set to `true`, the mixin will:
  /// - Log each disposed object
  /// - Print non-disposable warnings
  /// - Output a disposal summary per State
  ///
  /// Default: `false`
  static bool debugReportEnabled = false;

  /// Enables performance tracking for each dispose call.
  ///
  /// When set to `true`, the mixin will:
  /// - Measure execution time using `Stopwatch`
  /// - Report per-object disposal duration
  /// - Log total dispose time for the State
  ///
  /// Useful for profiling heavy cleanup operations.
  ///
  /// Default: `false`
  static bool trackPerformance = false;
}
