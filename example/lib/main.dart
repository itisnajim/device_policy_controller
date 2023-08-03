import 'package:flutter/material.dart';

import 'package:device_policy_controller/device_policy_controller.dart';

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
    final screenAwakeValuesNotifier = ValueNotifier([true, false]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Policy Controller Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                DevicePolicyController.instance
                    .requestAdminPrivilegesIfNeeded()
                    .then(
                  (isGranted) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Requests admin privileges"),
                          content: isGranted
                              ? const Text("Admin privileges is granted.")
                              : const Text(
                                  "Admin privileges have not been granted.\n"
                                  "Either the user has declined the request or This app is not a Device Policy Controller (DPC)."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Requests admin privileges if needed.'),
            ),
            ElevatedButton(
              onPressed: () {
                DevicePolicyController.instance.lockApp();
              },
              child: const Text('Locks the app in kiosk mode'),
            ),
            ElevatedButton(
              onPressed: () {
                DevicePolicyController.instance.unlockApp();
              },
              child: const Text('Unlocks the app.'),
            ),
            ElevatedButton(
              onPressed: () {
                DevicePolicyController.instance.isAdminActive().then((isAdmin) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Admin Privileges"),
                        content: isAdmin
                            ? const Text("The app has admin privileges.")
                            : const Text(
                                "The app does not have admin privileges."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: const Text('Checks if admin privileges are active.'),
            ),
            ElevatedButton(
              onPressed: () {
                DevicePolicyController.instance
                    .getDeviceInfo()
                    .then((Map<String, dynamic>? info) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Device Information"),
                        content: info != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: info.entries
                                    .map((i) => Text("${i.key}: ${i.value}"))
                                    .toList(),
                              )
                            : const Text(
                                "Unable to retrieve device information."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: const Text('Gets device information'),
            ),
            const SizedBox(height: 32),
            const Text("Keep Screen Awake ?"),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: screenAwakeValuesNotifier,
              builder: (context, val, _) {
                return ToggleButtons(
                  onPressed: (index) {
                    DevicePolicyController.instance
                        .setKeepScreenAwake(index == 1)
                        .then(
                      (value) {
                        screenAwakeValuesNotifier.value = [
                          index == 0,
                          index == 1
                        ];
                      },
                    );
                  },
                  isSelected: val,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.flash_off, size: 56),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.flash_on, size: 56),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
