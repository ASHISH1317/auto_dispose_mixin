import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'disposable.dart';
import 'dispose_entry.dart';

/// Resolves an object into a [DisposeEntry] if it supports disposal.
///
/// This function acts as the central disposal registry for
/// `AutoDisposeMixin`. It detects known Flutter and Dart resource
/// types and maps them to the correct cleanup logic.
///
/// ------------------------------------------------------------
///
/// ## Supported Types
///
/// The following object types are automatically recognized:
///
/// - `AnimationController`
/// - `Ticker`
/// - `Timer`
/// - `StreamSubscription`
/// - `FocusNode`
/// - `ChangeNotifier` / `ValueNotifier` (e.g. `TextEditingController`, `ScrollController`)
/// - `OverlayEntry` (calls `remove()` then `dispose()`)
/// - `Sink` / `StreamController` / `WebSocket` / `IOSink`
/// - Custom implementations of [Disposable]
/// - Duck-typed objects resolving:
///   - `dispose()` (e.g. `TabController`, Plugin Controllers)
///   - `cancel()` (e.g. `Timer`, `Worker`)
///   - `close()` (e.g. `ReceivePort`, `PersistentBottomSheetController`)
///   - `kill()` (e.g. `Isolate`)
///
/// ------------------------------------------------------------
///
/// ## Disposal Safety
///
/// Special handling is applied where required:
///
/// - `AnimationController` → stopped before disposal
/// - `Ticker` → stopped if active
/// - `Timer` → cancelled if active
/// - `Disposable` → protected against double disposal
///
/// ------------------------------------------------------------
///
/// ## Returns
///
/// - A [DisposeEntry] if the object is disposable
/// - `null` if the object does not support disposal
///
/// Objects that return `null` will be reported as
/// **non-disposable** when debug reporting is enabled.
DisposeEntry? resolveDisposable(Object object) {
  // AnimationController (must stop before dispose)
  if (object is AnimationController) {
    return DisposeEntry(
      target: object,
      onDispose: () {
        object.stop(canceled: true);
        object.dispose();
      },
    );
  }

  // Ticker
  if (object is Ticker) {
    return DisposeEntry(
      target: object,
      onDispose: () {
        if (object.isActive) {
          object.stop();
        }
        object.dispose();
      },
    );
  }

  // Timer
  if (object is Timer) {
    return DisposeEntry(
      target: object,
      onDispose: () {
        if (object.isActive) {
          object.cancel();
        }
      },
    );
  }

  // StreamSubscription
  if (object is StreamSubscription) {
    return DisposeEntry(target: object, onDispose: object.cancel);
  }

  // FocusNode
  if (object is FocusNode) {
    return DisposeEntry(target: object, onDispose: object.dispose);
  }

  // ChangeNotifier (TextEditingController, ScrollController, etc.)
  if (object is ChangeNotifier) {
    return DisposeEntry(target: object, onDispose: object.dispose);
  }

  // Sink (StreamController, EventSink, IOSink, WebSocket, etc.)
  if (object is Sink) {
    return DisposeEntry(target: object, onDispose: object.close);
  }

  // OverlayEntry
  if (object is OverlayEntry) {
    return DisposeEntry(
      target: object,
      onDispose: () {
        if (object.mounted) {
          object.remove();
        }
        object.dispose();
      },
    );
  }

  // Custom Disposable
  if (object is Disposable) {
    return DisposeEntry(
      target: object,
      onDispose: () {
        if (!object.isDisposed) {
          object.dispose();
          object.markDisposed();
        }
      },
    );
  }

  // Duck typing: dispose()
  try {
    final dynamic dyn = object;
    if (dyn.dispose is Function) {
      return DisposeEntry(target: object, onDispose: () => dyn.dispose());
    }
  } catch (_) {}

  // Duck typing: cancel()
  try {
    final dynamic dyn = object;
    if (dyn.cancel is Function) {
      return DisposeEntry(target: object, onDispose: () => dyn.cancel());
    }
  } catch (_) {}

  // Duck typing: close()
  try {
    final dynamic dyn = object;
    if (dyn.close is Function) {
      return DisposeEntry(target: object, onDispose: () => dyn.close());
    }
  } catch (_) {}

  // Duck typing: kill() (e.g. Isolate)
  try {
    final dynamic dyn = object;
    if (dyn.kill is Function) {
      return DisposeEntry(target: object, onDispose: () => dyn.kill());
    }
  } catch (_) {}

  return null;
}
