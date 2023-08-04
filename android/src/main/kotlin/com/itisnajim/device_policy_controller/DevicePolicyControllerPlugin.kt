package com.itisnajim.device_policy_controller

import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.util.Base64
import android.util.Log
import android.view.ViewGroup
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


private const val PROVISION_REQUEST_CODE = 1337

/** DevicePolicyControllerPlugin */
class DevicePolicyControllerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var mDevicePolicyManager: DevicePolicyManager
    private lateinit var adminComponentName: ComponentName
    private lateinit var context: Context
    private var activity: Activity? = null
    private var isInitialized = false;
    private var adminPrivilegeCallback: ((Boolean) -> Unit)? = null


    companion object {
        fun log(message: String) = Log.d("dpc::", message);
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
        initializeIfNeeded();
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "device_policy_controller")
        channel.setMethodCallHandler(this)

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setApplicationRestrictions" -> {
                val packageName = call.argument<String>("packageName")
                val restrictions = call.argument<Map<String, String>>("restrictions")
                setApplicationRestrictions(packageName, restrictions, result)
            }

            "getApplicationRestrictions" -> {
                val packageName = call.argument<String>("packageName")
                getApplicationRestrictions(packageName, result)
            }

            "addUserRestrictions" -> {
                val restrictions = call.argument<List<String>>("restrictions")
                addUserRestrictions(restrictions, result)
            }

            "clearUserRestriction" -> {
                val restrictions = call.argument<List<String>>("restrictions")
                clearUserRestriction(restrictions, result)
            }

            "lockDevice" -> {
                val password = call.argument<String>("password")
                lockDevice(password, result)
            }

            "installApplication" -> {
                val apkUrl = call.argument<String>("apkUrl")
                installApplication(apkUrl, result)
            }

            "rebootDevice" -> {
                val reason = call.argument<String>("reason")
                rebootDevice(reason, result)
            }

            "getDeviceInfo" -> getDeviceInfo(result)
            "requestAdminPrivilegesIfNeeded" -> requestAdminPrivilegesIfNeeded(result)
            "setKeepScreenAwake" -> {
                val enable = call.argument<Boolean>("enable")
                setKeepScreenAwake(enable ?: false, result)
            }

            "isAdminActive" -> result.success(isAdminActive())
            "lockApp" -> {
                val home = call.argument<Boolean>("home") ?: false
                lockApp(home, result)
            }

            "unlockApp" -> unlockApp(result)

            "isAppLocked" -> result.success(isAppLocked())
            "clearDeviceOwnerApp" -> {
                val packageName = call.argument<String>("packageName")
                clearDeviceOwnerApp(packageName, result)
            }

            "wipeData" -> {
                val flags = call.argument<Int>("flags")
                val reason = call.argument<String>("reason")

                wipeData(flags ?: 0, reason, result)
            }

            "setKeyguardDisabled" -> {
                val disabled = call.argument<Boolean>("disabled")
                setKeyguardDisabled(disabled ?: true, result)
            }

            "setScreenCaptureDisabled" -> {
                val disabled = call.argument<Boolean>("disabled")
                setScreenCaptureDisabled(disabled ?: true, result)
            }

            "setCameraDisabled" -> {
                val disabled = call.argument<Boolean>("disabled")
                setCameraDisabled(disabled ?: true, result)
            }

            else -> result.notImplemented()
        }
    }

    private fun setKeyguardDisabled(disabled: Boolean, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                mDevicePolicyManager.setKeyguardDisabled(adminComponentName, disabled)
                result.success(null)
            } catch (e: SecurityException) {
                result.error("SET_KEYGUARD_DISABLED", e.localizedMessage, null)
            }
        } else {
            result.error(
                "SET_KEYGUARD_DISABLED",
                "Setting keyguard disabled is not supported on this Android version.",
                null
            )
        }
    }

    private fun setScreenCaptureDisabled(disabled: Boolean, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                mDevicePolicyManager.setScreenCaptureDisabled(adminComponentName, disabled)
                result.success(null)
            } catch (e: SecurityException) {
                result.error("SET_SCREEN_CAPTURE_DISABLED", e.localizedMessage, null)
            }
        } else {
            result.error(
                "SET_SCREEN_CAPTURE_DISABLED",
                "Setting screen capture disabled is not supported on this Android version.",
                null
            )
        }
    }

    private fun setCameraDisabled(disabled: Boolean, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                mDevicePolicyManager.setCameraDisabled(adminComponentName, disabled)
                result.success(null)
            } catch (e: SecurityException) {
                result.error("SET_CAMERA_DISABLED", e.localizedMessage, null)
            }
        } else {
            result.error(
                "SET_CAMERA_DISABLED",
                "Setting camera disabled is not supported on this Android version.",
                null
            )
        }
    }


    private fun bundleToMap(extras: Bundle): Map<String, String?> {
        val map: MutableMap<String, String?> = HashMap()
        val ks = extras.keySet()
        val iterator: Iterator<String> = ks.iterator()
        while (iterator.hasNext()) {
            val key = iterator.next()
            map[key] = extras.getString(key)
        }
        return map
    }

    private fun setApplicationRestrictions(
        packageName: String?,
        restrictions: Map<String, String>?,
        result: Result
    ) {
        if (restrictions != null) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    val bundle = Bundle()
                    restrictions.entries.forEach {
                        bundle.putString(it.key, it.value)
                    }

                    mDevicePolicyManager.setApplicationRestrictions(
                        adminComponentName, packageName, bundle
                    )
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("SET_APPLICATION_RESTRICTIONS", e.localizedMessage, null)
            }
        } else {
            result.error(
                "INVALID_ARGUMENTS",
                "The 'packageName' argument is null or invalid",
                null
            )
        }
    }


    private fun getApplicationRestrictions(packageName: String?, result: Result) {
        if (packageName != null) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    val bundle = mDevicePolicyManager.getApplicationRestrictions(
                        adminComponentName,
                        packageName
                    )
                    result.success(bundleToMap(bundle))
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("GET_APPLICATION_RESTRICTIONS", e.localizedMessage, null)
            }
        } else {
            result.error(
                "INVALID_ARGUMENTS",
                "The 'packageName' argument is null or invalid",
                null
            )
        }
    }

    private fun addUserRestrictions(restrictions: List<String>?, result: Result) {
        if (restrictions != null) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    restrictions.forEach {
                        mDevicePolicyManager.addUserRestriction(
                            adminComponentName, it
                        )
                    }
                }

                result.success(true) // Return the appropriate result value
            } catch (e: Exception) {
                result.error("ADD_USER_RESTRICTIONS_FAILED", e.localizedMessage, null)
            }
        } else {
            result.error(
                "INVALID_ARGUMENTS",
                "The 'restrictions' argument is null or invalid",
                null
            )
        }
    }

    private fun clearUserRestriction(restrictions: List<String>?, result: Result) {
        if (restrictions != null) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    restrictions.forEach {
                        mDevicePolicyManager.clearUserRestriction(
                            adminComponentName, it
                        )
                    }
                }

                result.success(true) // Return the appropriate result value
            } catch (e: Exception) {
                result.error("CLEAR_USER_RESTRICTIONS_FAILED", e.localizedMessage, null)
            }
        } else {
            result.error(
                "INVALID_ARGUMENTS",
                "The 'restrictions' argument is null or invalid",
                null
            )
        }
    }

    private fun lockDevice(password: String?, result: Result) {
        if (!password.isNullOrEmpty()) {
            mDevicePolicyManager.setPasswordQuality(
                adminComponentName,
                DevicePolicyManager.PASSWORD_QUALITY_UNSPECIFIED
            )
            val passwordBytes = Base64.decode(password, Base64.NO_WRAP);
            var res = false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (mDevicePolicyManager.isResetPasswordTokenActive(adminComponentName)) {
                    mDevicePolicyManager.resetPasswordWithToken(
                        adminComponentName, null, passwordBytes, 0
                    )
                    res = true
                } else {
                    // Try to set again token
                    // On Android 8+, set reset password token if not active
                    res = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        !mDevicePolicyManager.isResetPasswordTokenActive(adminComponentName)
                    ) {
                        mDevicePolicyManager.setResetPasswordToken(
                            adminComponentName, passwordBytes
                        )
                        true
                    } else false
                }
            } // else Cannot for Android 7 or less

            mDevicePolicyManager.setPasswordQuality(
                adminComponentName,
                DevicePolicyManager.PASSWORD_QUALITY_SOMETHING
            )

            result.success(res)

        } else {
            mDevicePolicyManager.lockNow()
            result.success(true)
        }
    }

    private fun installApplication(apkUrl: String?, result: Result) {
        if (!apkUrl.isNullOrEmpty()) {
            try {
                val uri = Uri.parse(apkUrl)

                // Create an Intent to start the installation process
                val installIntent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "application/vnd.android.package-archive")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }

                // Check if the app installer is available
                val packageManager = context.packageManager
                val activities = packageManager.queryIntentActivities(installIntent, 0)

                if (activities.isNotEmpty()) {
                    context.startActivity(installIntent)
                    result.success(true) // Return success if the installation is started successfully
                } else {
                    result.error("INSTALL_APPLICATION_FAILED", "App installer not available.", null)
                }
            } catch (e: Exception) {
                result.error("INSTALL_APPLICATION_FAILED", e.localizedMessage, null)
            }
        } else {
            result.error("INVALID_ARGUMENTS", "The 'apkUrl' argument is null or empty", null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun rebootDevice(reason: String?, result: Result) {
        try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            powerManager.reboot(reason)
            result.success(true) // Return the appropriate result value
        } catch (e: Exception) {
            result.error("REBOOT_DEVICE_FAILED", e.localizedMessage, null)
        }
    }

    private fun getDeviceInfo(result: Result) {
        try {
            val deviceInfoMap = HashMap<String, Any>()
            deviceInfoMap["model"] = Build.MODEL
            deviceInfoMap["manufacturer"] = Build.MANUFACTURER
            deviceInfoMap["brand"] = Build.BRAND
            deviceInfoMap["product"] = Build.PRODUCT
            deviceInfoMap["device"] = Build.DEVICE
            deviceInfoMap["board"] = Build.BOARD
            deviceInfoMap["display"] = Build.DISPLAY
            deviceInfoMap["hardware"] = Build.HARDWARE
            deviceInfoMap["id"] = Build.ID
            deviceInfoMap["fingerprint"] = Build.FINGERPRINT
            deviceInfoMap["serial"] = Build.SERIAL
            deviceInfoMap["osVersion"] = Build.VERSION.SDK_INT
            deviceInfoMap["osRelease"] = Build.VERSION.RELEASE
            deviceInfoMap["sdkVersion"] = Build.VERSION.SDK_INT
            deviceInfoMap["type"] = Build.TYPE
            deviceInfoMap["tags"] = Build.TAGS
            result.success(deviceInfoMap) // Return the appropriate result value
        } catch (e: Exception) {
            result.error("GET_DEVICE_INFO_FAILED", e.localizedMessage, null)
        }
    }

    private fun initializeIfNeeded() {
        if (!isInitialized) {
            val appDeviceAdminReceiver = AppDeviceAdminReceiver()
            val intentFilter = IntentFilter()
            intentFilter.addAction("android.app.action.DEVICE_ADMIN_ENABLED")
            context.registerReceiver(appDeviceAdminReceiver, intentFilter)
            adminComponentName = appDeviceAdminReceiver.getWho(context);
            log("registerReceiver packageName: " + adminComponentName.packageName + ", className: " + adminComponentName.className)
            mDevicePolicyManager =
                context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager

            val shouldStartActivityAtBootCompleted = AppDeviceAdminReceiver.shouldStartActivityAtBootCompleted(context)
            if(shouldStartActivityAtBootCompleted){
                lockApp(true, null)
            }
        }
        isInitialized = true
    }

    private fun requestAdminPrivilegesIfNeeded(callback: (Boolean) -> Unit) {
        adminPrivilegeCallback = callback
        val isDeviceOwnerApp = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
            mDevicePolicyManager.isDeviceOwnerApp(adminComponentName.packageName)
        } else false


        if (!isDeviceOwnerApp) {
            adminPrivilegeCallback?.invoke(false)
            adminPrivilegeCallback = null
            return;
        }

        if (!isAdminActive()) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponentName)
            intent.putExtra(
                DevicePolicyManager.ACTION_PROVISION_MANAGED_PROFILE,
                context.packageName
            )

            intent.putExtra(
                DevicePolicyManager.EXTRA_PROVISIONING_DEVICE_ADMIN_PACKAGE_NAME,
                context.packageName
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                intent.putExtra(DevicePolicyManager.EXTRA_PROVISIONING_SKIP_ENCRYPTION, true)
                intent.putExtra(
                    DevicePolicyManager.EXTRA_PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME,
                    adminComponentName
                )
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                intent.putExtra(DevicePolicyManager.EXTRA_PROVISIONING_SKIP_USER_CONSENT, true);
            }

            intent.putExtra(
                DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Administrator privileges are required for this app."
            )
            activity?.finish()
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK)
            activity?.startActivityForResult(intent, PROVISION_REQUEST_CODE)
        } else {
            log("Device admin privilege already granted.")
            adminPrivilegeCallback?.invoke(true)
            adminPrivilegeCallback = null
        }
    }

    private fun requestAdminPrivilegesIfNeeded(result: Result) {
        requestAdminPrivilegesIfNeeded { isPrivilegeGranted ->
            result.success(isPrivilegeGranted);
        }
    }

    private fun setKeepScreenAwake(enable: Boolean, result: Result) {
        if (activity == null) return result.error(
            "A foreground activity is required.",
            "setKeepScreenAwake requires a foreground activity",
            null
        )
        if (enable) {
            activity!!.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            activity!!.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
        result.success(null);
    }

    private fun isAdminActive(): Boolean {
        val devicePolicyManager = mDevicePolicyManager
        val adminComponent = adminComponentName

        return devicePolicyManager.isAdminActive(adminComponent);
    }

    private fun clearDeviceOwnerApp(packageName: String?, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mDevicePolicyManager.clearDeviceOwnerApp(packageName ?: context.packageName)
        };
        result.success(null);
    }

    private fun setLauncher(enable: Boolean) {
        if (activity == null) return;
        try {

            val packageManager = context.packageManager
            val activityComponent = ComponentName(context, activity!!::class.java)

            if (enable) {
                packageManager.setComponentEnabledSetting(
                    activityComponent,
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                    PackageManager.DONT_KILL_APP
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    val intentFilter = IntentFilter(Intent.ACTION_MAIN)
                    intentFilter.addCategory(Intent.CATEGORY_HOME)
                    intentFilter.addCategory(Intent.CATEGORY_DEFAULT)

                    mDevicePolicyManager.addPersistentPreferredActivity(
                        adminComponentName,
                        intentFilter,
                        activityComponent
                    )
                }
                AppDeviceAdminReceiver.setShouldStartActivityAtBootCompleted(context, true)
                log("setLauncher enabled")
            } else {
                // Disable your app as the launcher
                packageManager.setComponentEnabledSetting(
                    activityComponent,
                    PackageManager.COMPONENT_ENABLED_STATE_DEFAULT,
                    PackageManager.DONT_KILL_APP
                )
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    mDevicePolicyManager.clearPackagePersistentPreferredActivities(
                        adminComponentName,
                        context.packageName
                    )
                }
                AppDeviceAdminReceiver.setShouldStartActivityAtBootCompleted(context, false)
                log("setLauncher disabled")
            }

        } catch (e: Exception) {
            log(e.localizedMessage)
        }
    }


    private fun lockApp(home: Boolean, result: Result?) {
        if (activity == null) {
            result?.success(false)
            return;
        }
        val isAdminActive = isAdminActive()
        if (isAdminActive) {
            // Set the activity as the preferred option for the device.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val activityComponent = ComponentName(context, activity!!::class.java)
                val intentFilter = IntentFilter(Intent.ACTION_MAIN)
                intentFilter.addCategory(Intent.CATEGORY_DEFAULT)
                if (home) {
                    intentFilter.addCategory(Intent.CATEGORY_HOME)
                }
                mDevicePolicyManager.addPersistentPreferredActivity(
                    adminComponentName,
                    intentFilter,
                    activityComponent
                )

                mDevicePolicyManager.setLockTaskPackages(
                    adminComponentName,
                    arrayOf(context.packageName)
                )
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                try {
                    activity!!.startLockTask()
                    result?.success(true)
                } catch (e: IllegalArgumentException) {
                    result?.success(false)
                    return
                }
            }

            setLauncher(true);
            result?.success(true)

        } else {
            // ensures that startLockTask() will not throw
            // see https://stackoverflow.com/questions/27826431/activity-startlocktask-occasionally-throws-illegalargumentexception
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activity!!.findViewById<ViewGroup>(android.R.id.content).getChildAt(0).post {
                    try {
                        activity!!.startLockTask()
                        result?.success(true)
                    } catch (e: IllegalArgumentException) {
                        result?.success(false)
                    }
                }
            } else result?.success(false)
        }
    }

    private fun unlockApp(result: Result) {
        if (activity == null) {
            result.success(false)
            return;
        }
        if (isAdminActive()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activity!!.stopLockTask()
                //mDevicePolicyManager.clearDeviceOwnerApp(context.packageName);
            }

        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activity!!.stopLockTask()
            }
        }

        setLauncher(false);
        result.success(true)
    }

    private fun isAppLocked(): Boolean {
        activity?.let { activity ->
            val service = activity.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
                ?: return false

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                return service.lockTaskModeState == ActivityManager.LOCK_TASK_MODE_LOCKED
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                return service.isInLockTaskMode;
            }
            return false
        }
        return false
    }

    private fun wipeData(flags: Int, reason: String?, result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && reason != null) {
            mDevicePolicyManager.wipeData(flags, reason)
        } else {
            mDevicePolicyManager.wipeData(flags)
        }
        result.success(null)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == PROVISION_REQUEST_CODE) {
            // Check if the result is OK (admin privilege request was successful)
            if (resultCode == Activity.RESULT_OK) {
                // Notify the callback that admin privilege was granted
                // The callback will proceed with the next steps in the `start` function
                adminPrivilegeCallback?.invoke(true)
            } else {
                // Notify the callback that admin privilege request was denied or cancelled
                adminPrivilegeCallback?.invoke(false)
            }
        }
        return false
    }
}
