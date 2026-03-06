# Auto Dispose Mixin

> **Zero-Boilerplate Lifecycle Management for Flutter Widgets**

`auto_dispose_mixin` automatically disposes controllers, subscriptions, notifiers, and custom resources when a `StatefulWidget` is removed from the widget tree — **without overriding `dispose()`**.

Designed for **performance**, **safety**, and **developer ergonomics**.

---

## 🚀 Why This Package Exists

Memory leaks are one of the most common performance issues in Flutter apps.

Typical problems:

* Forgetting to dispose `TextEditingController`
* Leaking `StreamSubscription`
* Missing `AnimationController.dispose()`
* Bloated `dispose()` methods
* Inconsistent cleanup across teams

### ❌ Traditional Approach

```dart
@override
void dispose() {
  controller.dispose();
  scrollController.dispose();
  animationController.dispose();
  subscription.cancel();
  super.dispose();
}
```

### ✅ With AutoDisposeMixin

```dart
class _MyWidgetState extends State<MyWidget>
    with AutoDisposeMixin {

  late final controller =
      registerForDispose(TextEditingController());

  // No dispose() override needed 🎉
}
```

---

## ✨ Features

* ✅ Automatic disposal of common Flutter resources
* ✅ Works with **AnimationController** (ticker-safe)
* ✅ Stream subscription cleanup
* ✅ Custom disposable objects
* ✅ Duck typing (`dispose()` detection)
* ✅ Manual cleanup callbacks
* ✅ DevTools logging
* ✅ Performance timing
* ✅ Zero runtime overhead in release mode
* ✅ No code generation
* ✅ No reflection
* ✅ No magic

---

## 📦 Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  auto_dispose_mixin: ^1.*.*
```

Then run:

```bash
flutter pub get
```

---

## 🧩 Basic Usage

### Step 1: Add the mixin

```dart
class _MyPageState extends State<MyPage>
    with AutoDisposeMixin {
```

### Step 2: Register disposables

```dart
late final TextEditingController controller =
    registerForDispose(TextEditingController());

late final ScrollController scrollController =
    registerForDispose(ScrollController());
```

That’s it.

No `dispose()` override required.

---

## 🎯 Supported Disposable Types

`AutoDisposeMixin` automatically handles an exhaustive list of Flutter and Dart controllers, natively saving you from writing disposal boilerplate.

### ChangeNotifier / ValueNotifier Family
*(Most UI Controllers)*

* `TextEditingController`
* `ScrollController`, `PageController`, `TabController`
* `AnimationController`
* `FocusNode`, `FocusScopeNode`
* `SearchController`
* Any custom class extending `ChangeNotifier` or `ValueNotifier`

### Streams & Sinks
*(Async Data)*

* `StreamSubscription` → `.cancel()`
* `StreamController`, `BroadcastStreamController` → `.close()`
* `IOSink`, `EventSink`, `WebSocket` → `.close()`

### UI & Flutter Core
* `OverlayEntry` → Natively calls `.remove()` if mounted, then `.dispose()`
* `Timer` / `RestartableTimer` → `.cancel()`
* `Ticker` → `.stop()`, `.dispose()`

### Custom Disposable Interface

```dart
abstract class Disposable {
  bool get isDisposed;
  void dispose();
  void markDisposed();
}
```

### Advanced Duck Typing (The "Senior Dev" Checklist)

If your object isn't in the standard Flutter list above, `AutoDisposeMixin` will dynamically detect and safely call its cleanup method. This automatically handles thousands of 3rd party plugins (like `VideoPlayerController`, GetX `Worker`, etc).

The mixin implicitly supports anything that has:
* `.dispose()` (e.g. `TapGestureRecognizer`, Plugin controllers)
* `.cancel()` (e.g. `Worker`, `EventChannel` subscriptions)
* `.close()` (e.g. `ReceivePort`, `PersistentBottomSheetController`)
* `.kill()` (e.g. `Isolate`)

```dart
class FakeSocketClient {
  void close() {
    print('Socket closed');
  }
}

late final socket =
    registerForDispose(FakeSocketClient());
```

### Manual Cleanup

```dart
registerDisposeCallback(() {
  // custom cleanup
});
```

---

## 🎞 AnimationController & Ticker Support

### ✅ Correct Mixin Order (IMPORTANT)

When using tickers:

```dart
class _MyWidgetState extends State<MyWidget>
    with SingleTickerProviderStateMixin, AutoDisposeMixin {
```

> **Rule:** `AutoDisposeMixin` must be the **last** mixin.

### Why?

* Flutter requires ticker providers to be initialized first
* AutoDisposeMixin depends on fully constructed controllers

---

## 🧠 Example: AnimationController

```dart
late final AnimationController animationController =
    registerForDispose(
      AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      ),
    );
```

The package will:

* Stop animation if running
* Dispose safely
* Track performance (optional)

---

## 🔌 StreamSubscription Example

```dart
late final StreamSubscription<int> subscription =
    registerForDispose(
      Stream.periodic(const Duration(seconds: 1))
          .listen(print),
    );
```

Automatically calls `.cancel()` on dispose.

---

## 🧪 Custom Disposable Example

```dart
class FakeSocketClient {
  void dispose() {
    print('Socket closed');
  }
}

late final socket =
    registerForDispose(FakeSocketClient());
```

Duck typing detects `.dispose()` automatically.

---

## 🧹 Manual Dispose Callback

For edge cases:

```dart
registerDisposeCallback(() {
  debugPrint('Manual cleanup');
});
```

Executed **after** all registered disposables.

---

## 🛠 Debug & DevTools Integration

### Enable Debug Reporting

```dart
void main() {
  AutoDisposeDebug.debugReportEnabled = true;
  AutoDisposeDebug.trackPerformance = true;
  runApp(MyApp());
}
```

### What You Get

* ✔ Per-object dispose logs
* ✔ Non-disposable warnings
* ✔ Total dispose time
* ✔ DevTools timeline visibility

Example output:

```
Dispose Summary for _MyPageState
---------------------------------
Disposed: 6
Not Disposable: 1
Total Time: 312µs
```

---

## 📊 Performance Tracking

When enabled:

* Each disposable tracks execution time
* Total dispose duration is logged
* Uses `Stopwatch` internally
* Disabled in release mode by default

---

## ⚠️ Best Practices

### ✅ DO

* Use `late final` with `registerForDispose`
* Keep AutoDisposeMixin last
* Enable debug mode during development

### ❌ DON’T

* Manually call `.dispose()` on registered objects
* Register objects after `dispose()` is called
* Use with non-State classes

---

## 🧪 Example App

To generate an example project:

```bash
flutter create example
```

Then import your package:

```dart
import 'package:auto_dispose_mixin/auto_dispose_mixin.dart';
```

A full example is included in `/example`.

---

## 🧩 Architecture Philosophy

* No code generation
* No build_runner
* No reflection
* No runtime cost
* Flutter-native lifecycle
* Predictable behavior

This package **augments** Flutter — it does not fight it.

---

## 🛣 Roadmap

Planned features:

* Leak detection warnings
* DevTools UI extension
* Dispose order visualization
* Zone-based lifecycle scopes

---

## ❤️ Contributing

Contributions welcome.

* Add new disposable resolvers
* Improve DevTools logging
* Write tests
* Improve documentation

---

## 📄 License

MIT License  
https://github.com/ASHISH1317/auto_dispose_mixin/blob/main/LICENSE

---

## ⭐ Final Note

If you’ve ever forgotten to dispose something in Flutter
**this package is for you.**

Simple. Safe. Fast.

---
