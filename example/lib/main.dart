import 'package:flutter/material.dart';

import 'package:device_policy_controller/device_policy_controller.dart';

import 'task_actions.dart';

void main() {
  runApp(const MyApp());
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenAwakeValueNotifier = ValueNotifier(false);

    final screenSizeWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Policy Controller Example'),
        actions: [
          ValueListenableBuilder(
            valueListenable: screenAwakeValueNotifier,
            builder: (context, val, _) {
              return TextButton(
                onPressed: () {
                  DevicePolicyController.instance
                      .setKeepScreenAwake(!screenAwakeValueNotifier.value)
                      .then(
                    (value) {
                      screenAwakeValueNotifier.value =
                          !screenAwakeValueNotifier.value;
                    },
                  );
                },
                child: Icon(Icons.flash_on,
                    color: val ? Colors.amberAccent : Colors.blueGrey,
                    size: 36),
              );
            },
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
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio:
                      (screenSizeWidth / 2) / (screenSizeWidth / 8),
                ),
                itemCount: taskActions.length,
                itemBuilder: (context, index) {
                  final action = taskActions[index];
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
