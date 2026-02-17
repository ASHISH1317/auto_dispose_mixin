import 'dart:async';
import 'package:auto_dispose_mixin/auto_dispose_mixin.dart';
import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// AUTO DISPOSE MIXIN – COMPLETE USAGE EXAMPLE
/// ------------------------------------------------------------
///
/// This example demonstrates:
///
/// ✔ ChangeNotifier types
/// ✔ AnimationController (Ticker safe)
/// ✔ ScrollController
/// ✔ PageController
/// ✔ TabController
/// ✔ FocusNode
/// ✔ ValueNotifier
/// ✔ StreamSubscription
/// ✔ Custom Disposable
/// ✔ Manual dispose callbacks
///
/// IMPORTANT:
/// When using with ticker mixins,
/// AutoDisposeMixin MUST be the last mixin.
///
/// Correct:
///   with SingleTickerProviderStateMixin, AutoDisposeMixin
///
/// Wrong:
///   with AutoDisposeMixin, SingleTickerProviderStateMixin
/// ------------------------------------------------------------

void main() {
  AutoDisposeDebug.debugReportEnabled = true;
  AutoDisposeDebug.trackPerformance = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DisposeDemoPage());
  }
}

class DisposeDemoPage extends StatefulWidget {
  const DisposeDemoPage({super.key});

  @override
  State<DisposeDemoPage> createState() => _DisposeDemoPageState();
}

class _DisposeDemoPageState extends State<DisposeDemoPage>
    with SingleTickerProviderStateMixin, AutoDisposeMixin {
  /// ------------------------------------------------------------
  /// CHANGE NOTIFIER TYPES
  /// ------------------------------------------------------------

  late final TextEditingController textController = registerForDispose(
    TextEditingController(),
  );

  late final ScrollController scrollController = registerForDispose(
    ScrollController(),
  );

  late final PageController pageController = registerForDispose(
    PageController(),
  );

  late final TabController tabController = registerForDispose(
    TabController(length: 2, vsync: this),
  );

  late final FocusNode focusNode = registerForDispose(FocusNode());

  late final ValueNotifier<int> counter = registerForDispose(ValueNotifier(0));

  /// ------------------------------------------------------------
  /// ANIMATION CONTROLLER (Ticker Safe)
  /// ------------------------------------------------------------

  late final AnimationController animationController = registerForDispose(
    AnimationController(vsync: this, duration: const Duration(seconds: 2)),
  );

  /// ------------------------------------------------------------
  /// STREAM SUBSCRIPTION
  /// ------------------------------------------------------------

  late final StreamSubscription<int> streamSubscription = registerForDispose(
    Stream.periodic(const Duration(seconds: 1), (v) => v).listen((event) {
      debugPrint('📡 Stream event: $event');
    }),
  );

  /// ------------------------------------------------------------
  /// CUSTOM DISPOSABLE (duck typing or Disposable interface)
  /// ------------------------------------------------------------

  late final FakeSocketClient socketClient = registerForDispose(
    FakeSocketClient(),
  );

  /// ------------------------------------------------------------
  /// INIT
  /// ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    animationController.repeat();

    /// Manual dispose callback
    registerDisposeCallback(() {
      debugPrint('🧹 Manual dispose callback executed');
    });
  }

  /// ------------------------------------------------------------
  /// UI
  /// ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto Dispose – Full Example')),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Pop this page to trigger automatic disposal.\n'
            'Check your debug console and DevTools logs.',
          ),
          const SizedBox(height: 20),

          /// TextEditingController
          TextField(
            controller: textController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'TextEditingController',
            ),
          ),

          const SizedBox(height: 20),

          /// ValueNotifier
          ValueListenableBuilder<int>(
            valueListenable: counter,
            builder: (_, value, __) {
              return Text('Counter: $value');
            },
          ),
          ElevatedButton(
            onPressed: () => counter.value++,
            child: const Text('Increment ValueNotifier'),
          ),

          const SizedBox(height: 20),

          /// PageView
          SizedBox(
            height: 100,
            child: PageView(
              controller: pageController,
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      'Page 1\nPage controller example',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      'Page 2\nPage controller example',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Pop Page (Trigger Dispose)'),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// CUSTOM CLASS WITH dispose() (Duck Typed)
/// ------------------------------------------------------------
class FakeSocketClient {
  void dispose() {
    debugPrint('🧹 FakeSocketClient disposed');
  }
}
