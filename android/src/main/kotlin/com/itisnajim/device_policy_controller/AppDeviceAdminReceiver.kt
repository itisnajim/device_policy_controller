package com.itisnajim.device_policy_controller

import android.app.ActivityManager
import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.content.Intent
import android.preference.PreferenceManager
import android.util.Log

class AppDeviceAdminReceiver : DeviceAdminReceiver() {
    companion object {
        fun log(message: String) = Log.d("dpc::", message);

        private const val KEY_SHOULD_START_ACTIVITY = "should_start_activity_at_boot"

        fun shouldStartActivityAtBootCompleted(context: Context): Boolean {
            val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
            return sharedPreferences.getBoolean(KEY_SHOULD_START_ACTIVITY, false)
        }

        fun setShouldStartActivityAtBootCompleted(context: Context, shouldStart: Boolean) {
            val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)
            val editor = sharedPreferences.edit()
            editor.putBoolean(KEY_SHOULD_START_ACTIVITY, shouldStart)
            editor.apply()
        }
    }

    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        log("onProfileProvisioningComplete")
        val i: Intent? =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (i != null) {
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        } else {
            log("Couldn't start activity")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        if (DevicePolicyManager.ACTION_MANAGED_PROFILE_PROVISIONED == action || Intent.ACTION_MANAGED_PROFILE_ADDED == action) {
            PreferenceManager.getDefaultSharedPreferences(context)
                .edit().putBoolean("is_provisioned", true).apply();
        }

        val i: Intent? =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
        val isActivityVisible = isActivityVisible(context);
        val shouldStartActivityAtBootCompleted = shouldStartActivityAtBootCompleted(context)
        log("shouldStartActivityAtBootCompleted: $shouldStartActivityAtBootCompleted")
        if (action == Intent.ACTION_BOOT_COMPLETED && i != null && shouldStartActivityAtBootCompleted && !isActivityVisible) {
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        }else if(action == Intent.ACTION_BOOT_COMPLETED && !isActivityVisible && shouldStartActivityAtBootCompleted){
            log("Couldn't start activity")
        }

    }

    private fun isActivityVisible(context: Context): Boolean {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val tasks =
            activityManager.runningAppProcesses.filter {
                it.processName == context.packageName &&
                        it.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
            }

        return tasks.isNotEmpty();
    }


}