import 'dart:async';

import 'package:device_policy_controller/device_policy_controller.dart';
import 'package:flutter/material.dart';

DevicePolicyController get dpc => DevicePolicyController.instance;

class TaskAction {
  final String label;
  final FutureOr<dynamic> Function(BuildContext context) task;
  void Function()? didPressed;

  TaskAction({
    required this.label,
    required this.task,
    this.didPressed,
  });

  ElevatedButton button(BuildContext context) => ElevatedButton(
        onPressed: () async {
          await task(context);
          didPressed?.call();
        },
        child: Text(label),
      );
}

const toggleScreenAwakeLabel = "Toggle Screen Awake ⚡";
final taskActions = <TaskAction>[
  TaskAction(
    label: "Requests admin privileges if needed.",
    task: (context) {
      dpc.requestAdminPrivilegesIfNeeded().then(
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
      dpc.isAdminActive().then((isAdmin) {
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
      dpc.lockApp();
    },
  ),
  TaskAction(
    label: "Unlocks the app",
    task: (_) {
      dpc.unlockApp();
    },
  ),
  TaskAction(
    label: toggleScreenAwakeLabel,
    task: (_) async {
      await dpc.setKeepScreenAwake(!(await dpc.isScreenAwake()));
    },
  ),
  TaskAction(
    label: "Gets device information",
    task: (context) {
      dpc.getDeviceInfo().then((Map<String, dynamic>? info) {
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
    label: "Set As Launcher",
    task: (context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set As Launcher'),
          content: const Text(
              "Do you want to set the current app as the device's launcher."),
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
                dpc.setAsLauncher(enable: false);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                dpc.setAsLauncher(enable: true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  ),
  TaskAction(
    label: "Clear Device Owner App",
    task: (_) => dpc.clearDeviceOwnerApp(),
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
                dpc.setCameraDisabled(disabled: true);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                dpc.setCameraDisabled(disabled: false);
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
                dpc.setScreenCaptureDisabled(disabled: true);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                dpc.setScreenCaptureDisabled(disabled: false);
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
                dpc.setKeyguardDisabled(disabled: true);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () {
                dpc.setKeyguardDisabled(disabled: false);
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
                  dpc.wipeData();
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
