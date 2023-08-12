import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:device_policy_controller/src/device_policy_controller_platform.dart';
import 'package:device_policy_controller/src/device_policy_controller_platform_impl.dart';

class MockDevicePolicyControllerPlatform
    with MockPlatformInterfaceMixin
    implements DevicePolicyControllerPlatform {
  @override
  Future<void> setKeepScreenAwake(bool enable) => Future.value();

  @override
  Future<bool> addUserRestrictions(List<String> restrictions) =>
      Future.value(true);

  @override
  Future<bool> clearUserRestriction(List<String> restrictions) =>
      Future.value(true);

  @override
  Future<Map<String, String>?> getApplicationRestrictions(String packageName) =>
      Future.value({
        "max_password_length": "10",
        "allow_camera": "false",
      });

  @override
  Future<Map<String, dynamic>?> getDeviceInfo() => Future.value({});

  @override
  Future<bool> installApplication(String? apkUrl) => Future.value(true);

  @override
  Future<bool> isAdminActive() => Future.value(true);

  @override
  Future<bool> isAppLocked() => Future.value(false);

  @override
  Future<bool> lockApp({bool home = false}) => Future.value(true);

  @override
  Future<bool> lockDevice({String? password}) => Future.value(true);

  @override
  Future<bool> rebootDevice({String? reason}) => Future.value(true);

  @override
  Future<bool> requestAdminPrivilegesIfNeeded() => Future.value(true);

  @override
  Future<void> setApplicationRestrictions(
          String packageName, Map<String, String> restrictions) =>
      Future.value();

  @override
  Future<bool> unlockApp() => Future.value(true);

  @override
  Future<void> clearDeviceOwnerApp({String? packageName}) => Future.value();

  @override
  Future<void> wipeData({int flags = 0, String? reason}) => Future.value();

  @override
  Future<void> setCameraDisabled({required bool disabled}) => Future.value();

  @override
  Future<void> setKeyguardDisabled({required bool disabled}) => Future.value();

  @override
  Future<void> setScreenCaptureDisabled({required bool disabled}) =>
      Future.value();

  @override
  void handleBootCompleted(handler) {}

  @override
  Future<bool> startApp({String? packageName}) => Future.value(true);

  @override
  Future<bool> setAsLauncher({bool enable = true}) => Future.value(true);

  @override
  Future<void> clear() => Future.value();

  @override
  Future<String?> get(String contentKey, {String? defaultContent}) =>
      Future.value("content");

  @override
  Future<void> put(String contentKey, {String? content}) => Future.value();

  @override
  Future<void> remove(String contentKey) => Future.value();

  @override
  Future<bool> isScreenAwake() => Future.value(false);
}

void main() {
  final DevicePolicyControllerPlatform initialPlatform =
      DevicePolicyControllerPlatform.instance;

  final MockDevicePolicyControllerPlatform fakeDevicePolicyController =
      MockDevicePolicyControllerPlatform();

  test('$DevicePolicyControllerPlatformImpl is the default instance', () {
    expect(initialPlatform, isInstanceOf<DevicePolicyControllerPlatformImpl>());
  });

  test('Lock Device', () async {
    // Call the method to lock the device
    bool locked =
        await fakeDevicePolicyController.lockDevice(password: "password123");

    // Check if the device is locked successfully
    expect(locked, true);
  });

  test('Set Application Restrictions', () async {
    // Prepare the data
    const packageName = "com.example.app";
    final restrictions = {
      "max_password_length": "10",
      "allow_camera": "false",
    };

    // Call the method to set application restrictions
    await fakeDevicePolicyController.setApplicationRestrictions(
        packageName, restrictions);

    // Verify that the restrictions are set correctly
    Map<String, String>? retrievedRestrictions =
        await fakeDevicePolicyController
            .getApplicationRestrictions(packageName);
    expect(retrievedRestrictions, restrictions);
  });

  test('Get Application Restrictions', () async {
    // Prepare the data
    const packageName = "com.example.app";
    final expectedRestrictions = {
      "max_password_length": "10",
      "allow_camera": "false",
    };

    // Set the expected restrictions
    MockDevicePolicyControllerPlatform()
        .setApplicationRestrictions(packageName, expectedRestrictions);

    // Call the method to get application restrictions
    Map<String, String>? restrictions = await fakeDevicePolicyController
        .getApplicationRestrictions(packageName);

    // Verify that the retrieved restrictions match the expected restrictions
    expect(restrictions, expectedRestrictions);
  });

  test('Lock App', () async {
    // Call the method to lock the app
    bool locked = await fakeDevicePolicyController.lockApp(home: true);

    // Check if the app is locked successfully
    expect(locked, true);
  });

  test('Unlock App', () async {
    // Call the method to unlock the app
    bool unlocked = await fakeDevicePolicyController.unlockApp();

    // Check if the app is unlocked successfully
    expect(unlocked, true);
  });
}
