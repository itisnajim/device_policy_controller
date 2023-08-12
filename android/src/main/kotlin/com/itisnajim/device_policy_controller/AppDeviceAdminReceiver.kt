package com.itisnajim.device_policy_controller

import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.content.Intent
import android.preference.PreferenceManager
import android.util.Log
import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor


class AppDeviceAdminReceiver : DeviceAdminReceiver() {
    companion object {
        fun log(message: String) = Log.d("dpc::", message)

        private const val KEY_IS_FROM_BOOT_COMPLETED = "is_from_boot_completed"

        fun setIsFromBootCompleted(context: Context, value: Boolean) {
            val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
            sharedPreferences.edit().putBoolean(KEY_IS_FROM_BOOT_COMPLETED, value).apply()
        }

        fun isFromBootCompleted(context: Context): Boolean {
            val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
            return sharedPreferences.getBoolean(KEY_IS_FROM_BOOT_COMPLETED, false)
        }
    }

    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        log("onProfileProvisioningComplete")
        val i: Intent? =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (i != null) {
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            context.startActivity(i)
        } else {
            log("Couldn't start activity")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        val extras = intent.extras
        log("onReceive: action: $action, extras: $extras")
        if (DevicePolicyManager.ACTION_MANAGED_PROFILE_PROVISIONED == action || Intent.ACTION_MANAGED_PROFILE_ADDED == action) {
            PreferenceManager.getDefaultSharedPreferences(context)
                .edit().putBoolean("is_provisioned", true).apply()
        }
        if (action == Intent.ACTION_BOOT_COMPLETED) {
            setIsFromBootCompleted(context, true)
            val flutterEngine = FlutterEngine(context.applicationContext)
            flutterEngine.plugins.get(DevicePolicyControllerPlugin::class.java) as DevicePolicyControllerPlugin?
            flutterEngine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
            val channel =
                DevicePolicyControllerPlugin.methodChannel(flutterEngine.dartExecutor.binaryMessenger)
            channel.invokeMethod("handleBootCompleted", null)
        }
    }

}