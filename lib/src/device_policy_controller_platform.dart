import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_policy_controller.dart';
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

  /// Sets the current Flutter app as the device's launcher or disables it as the launcher.
  ///
  /// If [enable] is `true`, the Flutter app will be set as the device's launcher,
  /// meaning it will be launched when the user presses the home button or attempts
  /// to access the launcher screen. The app will become the default launcher until
  /// either the user changes the default launcher or this method is called with [enable]
  /// set to `false`.
  ///
  /// If [enable] is `false`, the app will be disabled as the launcher, and the device
  /// will revert to its default launcher behavior.
  ///
  /// This method returns a [Future<bool>] that completes with `true` if the operation
  /// was successful, and `false` if it failed or encountered an error. If [enable]
  /// is `false`, the operation is considered successful even if there was no previous
  /// launcher set for the app.
  Future<bool> setAsLauncher({bool enable = true});

  /// Starts the specified application identified by [packageName].
  ///
  /// If [packageName] is provided and corresponds to an installed application
  /// package, this method will launch the application. If [packageName] is `null`,
  /// the method will attempt to launch the default application for the current
  /// Flutter app.
  ///
  /// The method returns a [Future<bool>] that completes with `true` if the application
  /// was successfully launched or if the default application for the Flutter app was
  /// started. If the specified [packageName] does not correspond to any installed
  /// application or there is an error during the launch process, the [Future] completes
  /// with `false`.
  ///
  /// Example usage:
  /// ```dart
  /// bool success = await DevicePolicyController.instance.startApp('com.example.app');
  /// if (success) {
  ///   print('Application started successfully!');
  /// } else {
  ///   print('Application not found or failed to start.');
  /// }
  /// ```
  Future<bool> startApp({String? packageName});

  /// Handles the BOOT_COMPLETED event received from the platform side (Android).
  ///
  /// When the Android device boots up, it broadcasts a BOOT_COMPLETED event to the
  /// registered BroadcastReceiver. This method is called in response to the event,
  /// allowing the Flutter app to handle any necessary actions after the device has booted.
  void handleBootCompleted(
      FutureOr<dynamic> Function(DevicePolicyController dpc) handler);

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
  Future<bool> lockDevice({String? password});

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
  Future<bool> rebootDevice({String? reason});

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

  /// Retrieves the current screen awake status.
  ///
  /// Returns a `Future` that completes with a `bool` indicating whether the screen
  /// is being kept awake (true) or not (false). The screen is considered awake if
  /// the keep screen awake setting is currently enabled.
  ///
  /// If the screen awake status cannot be determined or if an error occurs during
  /// retrieval, the `Future` completes with an error.
  Future<bool> isScreenAwake();

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

  /// Clears the device owner app for an application, if it has been set.
  ///
  /// If the [packageName] parameter is provided, the method will attempt to clear the
  /// device owner for the specified package. If [packageName] is null or not provided,
  /// the method will use the package name of the current application as the default.
  Future<void> clearDeviceOwnerApp({String? packageName});

  /// Wipes the device data, restoring it to factory settings.
  ///
  /// The [flags] parameter is an optional integer value representing additional
  /// options for the data wipe process. By default, it is set to `0`.
  /// The [reason] parameter is an optional string that provides a reason or
  /// description for the data wipe operation. If not provided, it will be `null`.
  ///
  /// Returns a `Future` that completes with no value upon successful execution,
  /// otherwise completes with an error if the data wipe operation fails.
  Future<void> wipeData({int flags = 0, String? reason});

  /// Called by a device owner or profile owner of secondary users that is
  /// affiliated with the device to disable the keyguard altogether.
  ///
  /// The [disabled] parameter indicates whether to disable the keyguard.
  ///
  /// Returns a `Future` that completes with no value upon successful execution,
  /// otherwise completes with an error if the operation fails.
  Future<void> setKeyguardDisabled({required bool disabled});

  /// Enables or disables screen capture on the device.
  ///
  /// The [disabled] parameter indicates whether to disable screen capture.
  /// When screen capture is disabled, users won't be able to take screenshots
  /// or record the screen contents.
  ///
  /// Returns a `Future` that completes with no value upon successful execution,
  /// otherwise completes with an error if the operation fails.
  Future<void> setScreenCaptureDisabled({required bool disabled});

  /// Enables or disables the camera on the device.
  ///
  /// The [disabled] parameter indicates whether to disable the camera.
  /// When the camera is disabled, users won't be able to access the camera app
  /// or use any apps that require camera access.
  ///
  /// Returns a `Future` that completes with no value upon successful execution,
  /// otherwise completes with an error if the operation fails.
  Future<void> setCameraDisabled({required bool disabled});

  /// Retrieves the value associated with the provided [contentKey] from the
  /// plugin shared preferences instance.
  ///
  /// If a value corresponding to [contentKey] is found, it will be returned.
  /// If no value is found and a [default] value is provided, the [default]
  /// value will be returned. If neither a value nor a [default] is found,
  /// `null` will be returned.
  Future<String?> get(String contentKey, {String? defaultContent});

  /// Stores the provided [content] with the associated [contentKey] in the
  /// plugin shared preferences instance.
  ///
  /// The [content] value will be associated with the provided [contentKey].
  /// If [content] is `null`, any existing value associated with [contentKey]
  /// will be removed from the shared preferences.
  Future<void> put(String contentKey, {String? content});

  /// Removes the value associated with the provided [contentKey] from the
  /// plugin shared preferences instance.
  ///
  /// If a value corresponding to [contentKey] is found, it will be removed.
  /// If no value is found, no action will be taken.
  Future<void> remove(String contentKey);

  /// Clears all values stored in the plugin shared preferences instance.
  ///
  /// This function will remove all key-value pairs stored in the plugin shared
  /// preferences instance, effectively resetting it to its initial state.
  Future<void> clear();
}
