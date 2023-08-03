package com.itisnajim.device_policy_controller

import android.app.admin.DeviceAdminReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.broadcastreceiver.BroadcastReceiverControlSurface

class AppDeviceAdminReceiver : DeviceAdminReceiver() {
    override fun onProfileProvisioningComplete(context: Context, intent: Intent) {
        Log.e("AppDeviceAdminReceiver", "onProfileProvisioningComplete")
        super.onProfileProvisioningComplete(context, intent)
    }

    fun attach(controlSurface: BroadcastReceiverControlSurface, lifecycle: Lifecycle) = controlSurface.attachToBroadcastReceiver(this, lifecycle)

}