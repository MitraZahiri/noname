package com.meetra.noname.overlay

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import com.meetra.noname.channel.OverlayFlutterBridge
import com.meetra.noname.overlay.quiz.QuizQuestion

class MascotOverlayService : Service() {

    companion object {
        const val ACTION_START =
            "com.meetra.noname.overlay.START"

        const val ACTION_STOP =
            "com.meetra.noname.overlay.STOP"

        const val ACTION_SHOW =
            "com.meetra.noname.overlay.SHOW"

        @Volatile
        var isRunning: Boolean = false
            private set

        @Volatile
        private var activeInstance:
            MascotOverlayService? = null

        @Volatile
        private var pendingQuestion:
            QuizQuestion? = null

        fun updateQuizQuestion(
            question: QuizQuestion
        ) {
            pendingQuestion = question

            activeInstance
                ?.windowController
                ?.setQuestion(question)
        }
    }

    private lateinit var windowController:
        OverlayWindowController

    override fun onCreate() {
        super.onCreate()

        OverlayNotificationFactory
            .createChannel(this)

        val notification =
            OverlayNotificationFactory
                .createNotification(this)

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.UPSIDE_DOWN_CAKE
        ) {
            startForeground(
                OverlayNotificationFactory
                    .NOTIFICATION_ID,
                notification,
                ServiceInfo
                    .FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(
                OverlayNotificationFactory
                    .NOTIFICATION_ID,
                notification
            )
        }

        windowController =
            OverlayWindowController(
                context = this,
                onQuizAnswered =
                    OverlayFlutterBridge::
                        sendQuizAnswered,
                onNextQuestionRequested =
                    OverlayFlutterBridge::
                        sendNextQuestionRequested,
                onDismissRequested = {
                    OverlayFlutterBridge
                        .sendMascotDismissed()

                    stopSelf()
                }
            )

        pendingQuestion?.let {
            question ->

            windowController.setQuestion(
                question
            )
        }

        activeInstance = this
        isRunning = true
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
            }

            ACTION_START,
            ACTION_SHOW,
            null -> {
                if (
                    Settings.canDrawOverlays(
                        this
                    )
                ) {
                    windowController.show()
                } else {
                    stopSelf()
                }
            }
        }

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        if (activeInstance === this) {
            activeInstance = null
        }

        windowController.hide()
        isRunning = false

        stopForeground(
            STOP_FOREGROUND_REMOVE
        )

        super.onDestroy()
    }

    override fun onBind(
        intent: Intent?
    ): IBinder? {
        return null
    }
}
