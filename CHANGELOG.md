# Changelog

## 1.1.0 - 2026-03-06

### Features

* **Massive Disposable Support Support Expansion:** Added native support for exhaustive list of Flutter standard interfaces, including `OverlayEntry`, `StreamController`, `IOSink`, `EventSink`, and `WebSocket` closures via `Sink`.
* **Advanced Duck Typing:** In addition to `dispose()`, the reflection matcher now safely checks for and triggers `.cancel()`, `.close()`, and `.kill()`. This naturally covers timers, isolates, workers, and thousands of 3rd party controllers (e.g., GetX `Worker`, `ReceivePort`, `PersistentBottomSheetController`) without boilerplate.

## 1.0.0 - 2026-02-17

### Initial Release

* Added `AutoDisposeMixin` for automatic resource cleanup
* Supports `ChangeNotifier`, `AnimationController`, `ScrollController`, `StreamSubscription`, and more
* Added `registerForDispose()` and `registerDisposeCallback()`
* DevTools logging and performance tracking support
* Ticker-safe disposal handling
* Included example project and full documentation

---
