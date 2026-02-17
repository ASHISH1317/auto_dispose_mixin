import 'dart:developer' as developer;

/// Internal representation of a disposable resource.
///
/// A [DisposeEntry] wraps a target object and its corresponding
/// cleanup function. It ensures:
/// - Safe single-execution disposal
/// - Optional performance tracking
/// - DevTools logging support
///
/// This class is used internally by `AutoDisposeMixin` and should
/// not be instantiated directly by package consumers.
class DisposeEntry {
  /// The object being managed for disposal.
  ///
  /// Used for debugging, logging, and reporting purposes only.
  final Object target;

  /// Callback that performs the actual cleanup.
  ///
  /// This may call:
  /// - `dispose()` on controllers
  /// - `cancel()` on stream subscriptions
  /// - Custom cleanup logic
  final void Function() onDispose;

  bool _disposed = false;

  /// Time taken to dispose this entry (if performance tracking is enabled).
  Duration? disposeDuration;

  /// Creates a new [DisposeEntry].
  ///
  /// Both [target] and [onDispose] are required.
  DisposeEntry({required this.target, required this.onDispose});

  /// Whether this entry has already been disposed.
  ///
  /// Prevents duplicate disposal calls.
  bool get isDisposed => _disposed;

  /// Executes the dispose callback safely.
  ///
  /// - Ensures disposal is only performed once
  /// - Optionally measures execution time
  ///
  /// If [trackPerformance] is `true`, disposal duration
  /// is recorded in [disposeDuration].
  void dispose({bool trackPerformance = false}) {
    if (_disposed) return;

    if (trackPerformance) {
      final sw = Stopwatch()..start();
      onDispose();
      sw.stop();
      disposeDuration = sw.elapsed;
    } else {
      onDispose();
    }

    _disposed = true;
  }

  /// Logs disposal information to Dart DevTools.
  ///
  /// Includes:
  /// - Target runtime type
  /// - Disposal duration (if available)
  ///
  /// Output appears under the `AutoDispose` log category.
  void logToDevTools() {
    developer.log(
      'Disposed ${target.runtimeType}'
      '${disposeDuration != null ? ' in ${disposeDuration!.inMicroseconds}µs' : ''}',
      name: 'AutoDispose',
    );
  }
}
