package com.meetra.noname.overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import com.meetra.noname.MainActivity
import com.meetra.noname.R

object OverlayNotificationFactory {

    const val NOTIFICATION_ID = 4101

    private const val CHANNEL_ID =
        "noname_mascot_overlay"

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT <
            Build.VERSION_CODES.O
        ) {
            return
        }

        val notificationManager =
            context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

        val channel = NotificationChannel(
            CHANNEL_ID,
            "NoName mascot",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description =
                "Shows that the NoName screen mascot is active."
            setShowBadge(false)
        }

        notificationManager.createNotificationChannel(
            channel
        )
    }

    fun createNotification(
        context: Context
    ): Notification {
        val openAppIntent = Intent(
            context,
            MainActivity::class.java
        )

        val openAppPendingIntent =
            PendingIntent.getActivity(
                context,
                4102,
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

        val stopIntent = Intent(
            context,
            MascotOverlayService::class.java
        ).apply {
            action = MascotOverlayService.ACTION_STOP
        }

        val stopPendingIntent =
            PendingIntent.getService(
                context,
                4103,
                stopIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

        val stopAction = Notification.Action.Builder(
            Icon.createWithResource(
                context,
                android.R.drawable.ic_media_pause
            ),
            "Stop mascot",
            stopPendingIntent
        ).build()

        val builder = Notification.Builder(
            context,
            CHANNEL_ID
        )
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("NoName mascot is active")
            .setContentText(
                "Tap to open NoName or stop the mascot."
            )
            .setContentIntent(openAppPendingIntent)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .addAction(stopAction)

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.S
        ) {
            builder.setForegroundServiceBehavior(
                Notification.FOREGROUND_SERVICE_IMMEDIATE
            )
        }

        return builder.build()
    }
}