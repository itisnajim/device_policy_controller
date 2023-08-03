import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_policy_controller_platform_impl.dart';

abstract class DevicePolicyControllerPlatform extends PlatformInterface {
  /// Constructs a DevicePolicyControllerPlatform.
  DevicePolicyControllerPlatform() : super(token: _token);

  static final Object _token = Object();

  static DevicePolicyControllerPlatform _instance =
      DevicePolicyControllerPlatformImpl();

  /// The default instance of [DevicePolicyControllerPlatform] to use.
  ///
  /// Defaults to [DevicePolicyControllerPlatformImpl].
  static DevicePolicyControllerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DevicePolicyControllerPlatform] when
  /// they register themselves.
  static set instance(DevicePolicyControllerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Sets application restrictions for a specified package.
  ///
  /// The [packageName] is the package name of the application for which
  /// restrictions are being set.
  ///
  /// The [restrictions] is a map containing key-value pairs representing the
  /// restrictions to be set.
  ///
  /// Returns a `Future` that completes with `void` if the restrictions were set
  /// successfully, otherwise completes with an error.
  Future<void> setApplicationRestrictions(
    String packageName,
    Map<String, String> restrictions,
  );

  /// Gets application restrictions for a specified package.
  ///
  /// The [packageName] is the package name of the application for which
  /// restrictions are being retrieved.
  ///
  /// Returns a `Future` that completes with a map containing the application
  /// restrictions, or `null` if no restrictions are set or if an error occurs.
  Future<Map<String, String>?> getApplicationRestrictions(String packageName);

  /// Adds user restrictions to the device.
  ///
  /// The [restrictions] is a list of restriction keys to be added.
  ///
  /// Returns a `Future` that completes with `true` if the restrictions were added
  /// successfully, otherwise completes with an error.
  Future<bool> addUserRestrictions(List<String> restrictions);

  /// Clears user restrictions from the device.
  ///
  /// The [restrictions] is a list of restriction keys to be cleared.
  ///
  /// Returns a `Future` that completes with `true` if the restrictions were cleared
  /// successfully, otherwise completes with an error.
  Future<bool> clearUserRestriction(List<String> restrictions);

  /// Locks the device with an optional password.
  ///
  /// The [password] is an optional password to set for locking the device.
  ///
  /// Returns a `Future` that completes with `true` if the device was locked
  /// successfully, otherwise completes with an error.
  Future<bool> lockDevice(String? password);

  /// Installs an application from the given APK URL.
  ///
  /// The [apkUrl] is the URL of the APK file to be installed.
  ///
  /// Returns a `Future` that completes with `true` if the installation was started
  /// successfully, otherwise completes with an error.
  Future<bool> installApplication(String? apkUrl);

  /// Reboots the device.
  ///
  /// Returns a `Future` that completes with `true` if the device was rebooted
  /// successfully, otherwise completes with an error.
  Future<bool> rebootDevice();

  /// Gets device information, such as the model and OS version.
  ///
  /// Returns a `Future` that completes with a map containing the device
  /// information, or an error if retrieval fails.
  Future<Map<String, dynamic>?> getDeviceInfo();

  /// Requests admin privileges if needed.
  ///
  /// Returns a `Future` that completes with `true` if admin privileges were granted,
  /// `false` if the request was denied or cancelled, or an error if the request fails.
  Future<bool> requestAdminPrivilegesIfNeeded();

  /// Sets whether to keep the screen awake.
  ///
  /// The [enable] parameter indicates whether to keep the screen awake (true) or not (false).
  ///
  /// Returns a `Future` that completes with `void` if the screen awake setting was changed
  /// successfully, otherwise completes with an error.
  Future<void> setKeepScreenAwake(bool enable);

  /// Checks if admin privileges are active.
  ///
  /// Returns a `Future` that completes with `true` if admin privileges are active,
  /// otherwise completes with an error.
  Future<bool> isAdminActive();

  /// Locks the app in kiosk mode with an optional [home] parameter to make the app the default home screen.
  ///
  /// The [home] parameter indicates whether to set the app as the default home screen.
  /// If `true`, the app will be the home screen when the device is rebooted.
  /// If `false` or not provided, the app will only be locked temporarily.
  ///
  /// Returns a `Future` that completes with `true` if the app was locked successfully,
  /// otherwise completes with an error.
  Future<bool> lockApp({bool home = false});

  /// Unlocks the app if it was locked using [lockApp].
  ///
  /// Returns a `Future` that completes with `true` if the app was unlocked successfully,
  /// otherwise completes with an error.
  Future<bool> unlockApp();

  /// Checks if the app is locked in kiosk mode.
  ///
  /// Returns a `Future` that completes with `true` if the app is locked in kiosk mode,
  /// otherwise completes with an error.
  Future<bool> isAppLocked();
}
