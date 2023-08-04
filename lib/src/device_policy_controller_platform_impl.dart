import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_policy_controller_platform.dart';

/// An implementation of [DevicePolicyControllerPlatform] that uses method channels.
class DevicePolicyControllerPlatformImpl
    extends DevicePolicyControllerPlatform {
  DevicePolicyControllerPlatformImpl();

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('device_policy_controller');

  @override
  Future<bool> addUserRestrictions(List<String> restrictions) async {
    return await methodChannel.invokeMethod(
        'addUserRestrictions', restrictions);
  }

  @override
  Future<bool> clearUserRestriction(List<String> restrictions) async {
    return await methodChannel.invokeMethod(
        'clearUserRestriction', restrictions);
  }

  @override
  Future<Map<String, String>?> getApplicationRestrictions(String packageName) {
    return methodChannel.invokeMapMethod<String, String>(
        'getApplicationRestrictions', packageName);
  }

  @override
  Future<Map<String, dynamic>?> getDeviceInfo() {
    return methodChannel.invokeMapMethod<String, dynamic>('getDeviceInfo');
  }

  @override
  Future<bool> installApplication(String? apkUrl) async {
    return await methodChannel.invokeMethod('installApplication', apkUrl);
  }

  @override
  Future<bool> isAdminActive() async {
    return await methodChannel.invokeMethod('isAdminActive');
  }

  @override
  Future<bool> isAppLocked() async {
    return await methodChannel.invokeMethod('isAppLocked');
  }

  @override
  Future<bool> lockApp({bool home = true}) async {
    return await methodChannel.invokeMethod('lockApp', {'home': home});
  }

  @override
  Future<bool> lockDevice({String? password}) async {
    return await methodChannel
        .invokeMethod('lockDevice', {'password': password});
  }

  @override
  Future<bool> rebootDevice({String? reason}) async {
    return await methodChannel.invokeMethod('rebootDevice', {'reason': reason});
  }

  @override
  Future<bool> wipeData({int flags = 0, String? reason}) async {
    return await methodChannel.invokeMethod('wipeData', {
      'flags': flags,
      'reason': reason,
    });
  }

  @override
  Future<bool> requestAdminPrivilegesIfNeeded() async {
    return await methodChannel.invokeMethod('requestAdminPrivilegesIfNeeded');
  }

  @override
  Future<void> setApplicationRestrictions(
      String packageName, Map<String, String> restrictions) {
    return methodChannel.invokeMethod('setApplicationRestrictions', {
      'packageName': packageName,
      'restrictions': restrictions,
    });
  }

  @override
  Future<void> setKeepScreenAwake(bool enable) {
    return methodChannel.invokeMethod('setKeepScreenAwake', {'enable': enable});
  }

  @override
  Future<bool> unlockApp() async {
    return await methodChannel.invokeMethod('unlockApp');
  }

  @override
  Future<void> clearDeviceOwnerApp({String? packageName}) {
    return methodChannel
        .invokeMethod('clearDeviceOwnerApp', {'packageName': packageName});
  }

  @override
  Future<void> setCameraDisabled({required bool disabled}) {
    return methodChannel
        .invokeMethod('setCameraDisabled', {'disabled': disabled});
  }

  @override
  Future<void> setKeyguardDisabled({required bool disabled}) {
    return methodChannel
        .invokeMethod('setKeyguardDisabled', {'disabled': disabled});
  }

  @override
  Future<void> setScreenCaptureDisabled({required bool disabled}) {
    return methodChannel
        .invokeMethod('setScreenCaptureDisabled', {'disabled': disabled});
  }
}
