# device_policy_controller

[![pub package](https://img.shields.io/pub/v/device_policy_controller.svg)](https://pub.dartlang.org/packages/device_policy_controller) [![GitHub license](https://img.shields.io/github/license/itisnajim/device_policy_controller)](https://github.com/itisnajim/device_policy_controller/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/itisnajim/device_policy_controller)](https://github.com/itisnajim/device_policy_controller/issues)

The Device Policy Controller (DPC) `device_policy_controller` plugin for Flutter allows your `android` app to become a Device Policy Controller and manage device policies. With this plugin, you can set application restrictions, lock the device, install applications, and more.

## Getting Started

### Installation

Run the command:
```bash
flutter pub add device_policy_controller
```

### Setup DPC

To enable your app to become a Device Policy Controller (DPC), you can do it using cloud services, QR code, Near Field Communication (NFC), or directly from your computer using ADB (Android Debug Bridge). If you own the device, the following command can be used:

1. Open a terminal and navigate to the root directory of your Flutter project.

2. Connect your Android device to your computer and ensure that your Flutter app is running on the device.

3. Run the following command to make your app a device admin:

```bash
adb shell dpm set-device-owner com.your_flutter_app_id/com.itisnajim.device_policy_controller.AppDeviceAdminReceiver
```
Replace **`com.your_flutter_app_id`** with your app's bundle ID. You can find the app's bundle ID in **android/app/build.gradle** file, under `android.defaultConfig.applicationId`.

To generate the QR code or write the provisioning data into an NFC tag, you can use the information from the `provisioning_data.example.json` file located in the `example folder`. This JSON file contains the necessary data to configure your Flutter app as a Device Policy Controller (DPC).
To access the full documentation and learn about these methods, visit the following link:
[Android Management API - Provision a Device](https://developers.google.com/android/management/provision-device#qr_code_method)

## Usage

After setting up your app as a Device Policy Controller, you can use the plugin to manage device policies. The DevicePolicyController class provides various methods to interact with the device. Here's an example of how to use the plugin:


```dart
import 'package:device_policy_controller/device_policy_controller.dart';

// Create an instance of the DevicePolicyController
final dpc = DevicePolicyController.instance;

// Example: Lock the device, password is optional
final bool locked = await dpc.lockDevice("password123");
if (locked) {
  print("Device locked successfully!");
} else {
  print("Failed to lock the device.");
}

// Example: Set application restrictions
Map<String, String> restrictions = {
  "max_password_length": "10",
  "allow_camera": "false",
};
await dpc.setApplicationRestrictions("com.example.app", restrictions);
```

## Features
The plugin provides the following features:

* Get and set application restrictions for a specified package.
* Add and clear user restrictions on the device.
* Lock the device with an optional password.
* Install an application from a given APK URL.
* Get device information, such as the model and OS version. *(no admin privileges is needed)*
* Request admin privileges if needed.
* Set whether to keep the screen awake. *(no admin privileges is needed)*
* Check if admin privileges are active.
* Lock the app in kiosk mode. (If the app doesn't have administrator privileges, the system's default pinning behavior will be applied.)
* Unlock the app if it was locked using the plugin. (If the app doesn't have administrator privileges, the system's default unpinning behavior will be applied.)
* For more, see [API reference](https://pub.dev/documentation/device_policy_controller/latest/)

**Please Note**: This plugin deals with device policies and admin privileges, use it with caution, and ensure that your app complies with all the relevant Google Play and Android Enterprise policies.

## Troubleshooting
If you encounter any issues or have questions related to the `device_policy_controller` plugin, feel free to reach out to the plugin maintainers on the [GitHub repository](https://github.com/itisnajim/device_policy_controller).

## License
This plugin package is published under the `MIT` License.
