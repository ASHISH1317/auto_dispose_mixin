/// A contract for objects that require controlled manual disposal.
///
/// Classes implementing [Disposable] can be registered with
/// `AutoDisposeMixin` to enable safe lifecycle management.
///
/// This interface adds internal disposal state tracking,
/// preventing double-disposal and improving debugging reliability.
///
/// ------------------------------------------------------------
///
/// ## When to Use
///
/// Implement [Disposable] when:
/// - Your class manages external resources (e.g. sockets, streams, isolates)
/// - You need explicit lifecycle tracking
/// - You want to prevent accidental double disposal
///
/// ------------------------------------------------------------
///
/// ## Example
///
/// ```dart
/// class SocketService implements Disposable {
///   @override
///   void dispose() {
///     _socket.close();
///     markDisposed();
///   }
/// }
/// ```
///
/// Then register inside a State:
///
/// ```dart
/// late final socketService =
///     registerForDispose(SocketService());
/// ```
///
/// ------------------------------------------------------------
///
/// ⚠ Important:
/// Always call [markDisposed] inside your `dispose()` implementation
/// after cleanup logic is complete.
abstract class Disposable {
  bool _isDisposed = false;

  /// Returns `true` if this object has already been disposed.
  ///
  /// Useful for guarding against double disposal.
  bool get isDisposed => _isDisposed;

  /// Marks the object as disposed.
  ///
  /// Should be called inside your `dispose()` implementation
  /// after cleanup is complete.
  void markDisposed() {
    _isDisposed = true;
  }

  /// Releases any resources held by this object.
  ///
  /// Must be implemented by subclasses.
  ///
  /// This method should:
  /// - Free external resources
  /// - Cancel active subscriptions
  /// - Close connections
  /// - Call [markDisposed] at the end
  void dispose();
}
