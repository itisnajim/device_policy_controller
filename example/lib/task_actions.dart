import 'package:device_policy_controller/device_policy_controller.dart';
import 'package:flutter/material.dart';

class TaskAction {
  final String label;
  final void Function(BuildContext context) task;

  const TaskAction({
    required this.label,
    required this.task,
  });

  ElevatedButton button(BuildContext context) => ElevatedButton(
        onPressed: () => task(context),
        child: Text(label),
      );
}

final taskActions = <TaskAction>[
  TaskAction(
    label: "Requests admin privileges if needed.",
    task: (context) {
      DevicePolicyController.instance.requestAdminPrivilegesIfNeeded().then(
        (isGranted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Requests admin privileges"),
                content: isGranted
                    ? const Text("Admin privileges is granted.")
                    : const Text("Admin privileges have not been granted.\n"
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
  ),
  TaskAction(
    label: "Checks if admin privileges are active",
    task: (context) {
      DevicePolicyController.instance.isAdminActive().then((isAdmin) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Admin Privileges"),
              content: isAdmin
                  ? const Text("The app has admin privileges.")
                  : const Text("The app does not have admin privileges."),
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
  ),
  TaskAction(
    label: "Locks the app in kiosk mode",
    task: (_) {
      DevicePolicyController.instance.lockApp();
    },
  ),
  TaskAction(
      label: "Unlocks the app",
      task: (_) {
        DevicePolicyController.instance.unlockApp();
      }),
  TaskAction(
    label: "Gets device information",
    task: (context) {
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
                  : const Text("Unable to retrieve device information."),
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
  ),
  TaskAction(
    label: "Clear Device Owner App",
    task: (_) => DevicePolicyController.instance.clearDeviceOwnerApp(),
  ),
  TaskAction(
    label: "Set Camera",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Camera'),
          content: const Text('Do you want to disable the camera?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () {
                DevicePolicyController.instance
                    .setCameraDisabled(disabled: true);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                DevicePolicyController.instance
                    .setCameraDisabled(disabled: false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Set screen capture",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Screen Capture'),
          content: const Text('Do you want to disable the Screen Capture?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () {
                DevicePolicyController.instance
                    .setScreenCaptureDisabled(disabled: true);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                DevicePolicyController.instance
                    .setScreenCaptureDisabled(disabled: false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Set Keyguard",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Keyguard'),
          content: const Text('Do you want to disable the keyguard?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () {
                DevicePolicyController.instance
                    .setKeyguardDisabled(disabled: true);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                DevicePolicyController.instance
                    .setKeyguardDisabled(disabled: false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Wipe Data",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Wipe Data'),
            content: const Text(
              'Are you sure you want to wipe all device data?\n'
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  DevicePolicyController.instance.wipeData();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Wipe',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  ),
];
