import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';

import 'dispose_entry.dart';
import 'dispose_resolver.dart';
import 'auto_dispose_debug.dart';

/// A mixin that automatically disposes registered resources
/// when a [State] object is removed from the widget tree.
///
/// This eliminates boilerplate `dispose()` implementations and
/// prevents common memory leaks caused by forgotten disposals.
///
/// ### Supported types
/// - `ChangeNotifier` (e.g. `TextEditingController`, `ScrollController`)
/// - `AnimationController`
/// - `StreamSubscription`
/// - Custom `Disposable` implementations
/// - Any object exposing a `dispose()` method (duck typing)
///
/// ### Usage
/// ```dart
/// class _MyPageState extends State<MyPage> with AutoDisposeMixin {
///   late final controller = registerForDispose(TextEditingController());
/// }
/// ```
///
/// No need to override `dispose()` manually.
mixin AutoDisposeMixin<T extends StatefulWidget> on State<T> {
  /// Internal list of disposable entries
  final List<DisposeEntry> _entries = [];

  /// Objects that could not be resolved as disposable
  final List<Object> _nonDisposable = [];

  /// Registers an object for automatic disposal.
  ///
  /// If the object is disposable, it will be disposed automatically
  /// when the widget is removed from the tree.
  ///
  /// If the object is **not disposable**, a debug warning is logged
  /// (debug mode only).
  ///
  /// Throws an assertion error if called after the widget is disposed.
  ///
  /// Returns the same object for inline initialization convenience.
  R registerForDispose<R extends Object>(R object) {
    assert(mounted, 'registerForDispose() called after dispose()');

    final DisposeEntry? entry = resolveDisposable(object);

    if (entry != null) {
      _entries.add(entry);
    } else {
      _nonDisposable.add(object);

      assert(() {
        debugPrint(
          '[AutoDisposeMixin] WARNING: '
          '${object.runtimeType} is not disposable',
        );
        return true;
      }());
    }

    return object;
  }

  /// Registers a manual cleanup callback.
  ///
  /// Useful for disposing resources that do not expose a standard
  /// `dispose()` or `cancel()` API.
  ///
  /// ```dart
  /// registerDisposeCallback(() {
  ///   socket.close();
  /// });
  /// ```
  void registerDisposeCallback(VoidCallback callback) {
    _entries.add(DisposeEntry(target: callback, onDispose: callback));
  }

  /// Automatically disposes all registered objects.
  ///
  /// Disposal is executed in **reverse order of registration**
  /// to match Flutter's standard lifecycle expectations.
  ///
  /// Optional features controlled via [AutoDisposeDebug]:
  /// - Performance timing
  /// - DevTools logging
  @override
  void dispose() {
    final Stopwatch? totalStopwatch = AutoDisposeDebug.trackPerformance
        ? Stopwatch()
        : null;

    totalStopwatch?.start();

    for (final DisposeEntry entry in _entries.reversed) {
      entry.dispose(trackPerformance: AutoDisposeDebug.trackPerformance);

      if (AutoDisposeDebug.debugReportEnabled) {
        entry.logToDevTools();
      }
    }

    totalStopwatch?.stop();

    if (AutoDisposeDebug.debugReportEnabled) {
      _logSummary(totalStopwatch?.elapsed);
    }

    _entries.clear();
    _nonDisposable.clear();

    super.dispose();
  }

  /// Logs a disposal summary to DevTools.
  ///
  /// Includes:
  /// - Total disposed objects
  /// - Non-disposable objects
  /// - Total disposal time (if enabled)
  void _logSummary(Duration? totalTime) {
    developer.log('''
Dispose Summary for $runtimeType
---------------------------------
Disposed: ${_entries.length}
Not Disposable: ${_nonDisposable.length}
Total Time: ${totalTime?.inMicroseconds ?? '-'}µs
''', name: 'AutoDispose');

    for (final Object obj in _nonDisposable) {
      developer.log('Not disposable: ${obj.runtimeType}', name: 'AutoDispose');
    }
  }
}
