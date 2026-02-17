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
/// - `ChangeNotifier` (e.g. `TextEditingController`, `ScrollController`)
/// - Custom implementations of [Disposable]
/// - Duck-typed objects with a `dispose()` method
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

  // Duck typing: any object with a dispose() method
  try {
    final dynamic dyn = object;
    if (dyn.dispose is Function) {
      return DisposeEntry(target: object, onDispose: dyn.dispose);
    }
  } catch (_) {
    // Ignore reflection failures
  }

  return null;
}
