import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'task_actions.dart';

class ScreenAwakeStatusProvider extends ChangeNotifier {
  bool _isScreenAwake = false;

  bool get isScreenAwake => _isScreenAwake;

  Future<void> updateScreenAwakeStatus({bool? value}) async {
    _isScreenAwake = value ?? await dpc.isScreenAwake();
    notifyListeners();
  }
}

final _statusProvider = ScreenAwakeStatusProvider();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initKioskMode();
  runApp(
    ChangeNotifierProvider(
      create: (context) => _statusProvider,
      child: const MyApp(),
    ),
  );
}

const bootCompletedHandlerStartedKey = "bootCompletedHandlerStarted";
Future<void> enableKioskMode() async {
  try {
    await dpc.setAsLauncher();
    await dpc.lockApp();
    await dpc.setKeepScreenAwake(true);
    _statusProvider.updateScreenAwakeStatus(value: true);

    await dpc.put(bootCompletedHandlerStartedKey, content: "false");
  } catch (e) {
    print('dpc:: enableKioskMode error: $e');
  }
}

Future<void> initKioskMode() async {
  dpc.handleBootCompleted((_) async {
    final startedValue = await dpc.get(bootCompletedHandlerStartedKey);
    final isStarted = startedValue == "true";
    print('dpc:: handleBootCompleted:: isStarted: $isStarted');
    await dpc.put(bootCompletedHandlerStartedKey, content: "true");
    if (!isStarted) {
      try {
        await dpc.startApp();
      } catch (e) {
        print('dpc:: handleBootCompleted startApp error: $e');
      }
    }

    // It's important to highlight that if handleBootCompleted was called
    // earlier, dpc.startApp() could make Flutter engine reset (or invalidate)
    // the code to its initial entry point "main".
    // As a result, there's a high probability that the subsequent
    // (next) code lines won't execute as expected.
    // We will not call enableKioskMode method here.
    // enableKioskMode();
  });

  final startedValue = await dpc.get(bootCompletedHandlerStartedKey);
  final isStarted = startedValue == "true";
  print('dpc:: init:: startedValue $startedValue, isStarted: $isStarted');

  if (isStarted) {
    enableKioskMode();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _statusProvider.updateScreenAwakeStatus();
  }

  @override
  Widget build(BuildContext context) {
    final screenSizeWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Policy Controller Example'),
        actions: [
          TextButton(
            onPressed: () {
              dpc.setKeepScreenAwake(!_statusProvider.isScreenAwake).then(
                (value) {
                  _statusProvider.updateScreenAwakeStatus(
                      value: !_statusProvider.isScreenAwake);
                },
              );
            },
            child: Consumer<ScreenAwakeStatusProvider>(
                builder: (context, statusProvider, _) {
              return Icon(
                Icons.flash_on,
                color: statusProvider.isScreenAwake
                    ? Colors.amberAccent
                    : Colors.blueGrey,
                size: 36,
              );
            }),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio:
                      (screenSizeWidth / 2) / (screenSizeWidth / 7),
                ),
                itemCount: taskActions.length,
                itemBuilder: (context, index) {
                  final action = taskActions[index];
                  if (action.label == toggleScreenAwakeLabel) {
                    action.didPressed = () {
                      _statusProvider.updateScreenAwakeStatus();
                    };
                  }
                  return action.button(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
