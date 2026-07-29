package com.meetra.noname.channel

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.meetra.noname.overlay.MascotOverlayService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class OverlayChannelHandler(
    private val activity: Activity,
    messenger: BinaryMessenger
) {

    companion object {
        private const val CHANNEL_NAME =
            "noname/overlay"

        private const val NOTIFICATION_REQUEST_CODE =
            4201
    }

    private val channel = MethodChannel(
        messenger,
        CHANNEL_NAME
    )

    fun register() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "hasOverlayPermission" -> {
                    result.success(
                        Settings.canDrawOverlays(activity)
                    )
                }

                "requestOverlayPermission" -> {
                    openOverlayPermissionSettings()
                    result.success(null)
                }

                "startMascotOverlay" -> {
                    if (!Settings.canDrawOverlays(activity)) {
                        result.error(
                            "overlay_permission_required",
                            "Overlay permission is required.",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    requestNotificationPermissionIfNeeded()
                    startOverlayService(
                        MascotOverlayService.ACTION_START
                    )

                    result.success(true)
                }

                "stopMascotOverlay" -> {
                    stopOverlayService()
                    result.success(true)
                }

                "showMascotOverlay" -> {
                    if (!MascotOverlayService.isRunning) {
                        startOverlayService(
                            MascotOverlayService.ACTION_START
                        )
                    } else {
                        startOverlayService(
                            MascotOverlayService.ACTION_SHOW
                        )
                    }

                    result.success(true)
                }

                "isMascotOverlayRunning" -> {
                    result.success(
                        MascotOverlayService.isRunning
                    )
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    private fun openOverlayPermissionSettings() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse(
                "package:${activity.packageName}"
            )
        )

        activity.startActivity(intent)
    }

    private fun startOverlayService(action: String) {
        val intent = Intent(
            activity,
            MascotOverlayService::class.java
        ).apply {
            this.action = action
        }

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.O
        ) {
            activity.startForegroundService(intent)
        } else {
            activity.startService(intent)
        }
    }

    private fun stopOverlayService() {
        val intent = Intent(
            activity,
            MascotOverlayService::class.java
        ).apply {
            action = MascotOverlayService.ACTION_STOP
        }

        activity.startService(intent)
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (
            Build.VERSION.SDK_INT <
            Build.VERSION_CODES.TIRAMISU
        ) {
            return
        }

        if (
            activity.checkSelfPermission(
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        activity.requestPermissions(
            arrayOf(
                Manifest.permission.POST_NOTIFICATIONS
            ),
            NOTIFICATION_REQUEST_CODE
        )
    }
}