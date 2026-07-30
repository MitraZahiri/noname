package com.meetra.noname.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque

object OverlayFlutterBridge {

    private val mainHandler =
        Handler(Looper.getMainLooper())

    private var channel:
        MethodChannel? = null

    private val pendingAnswers =
        ArrayDeque<Map<String, Any>>()

    fun attach(
        newChannel: MethodChannel
    ) {
        mainHandler.post {
            channel = newChannel
            flushPendingAnswers()
        }
    }

    fun detach(
        oldChannel: MethodChannel
    ) {
        mainHandler.post {
            if (channel === oldChannel) {
                channel = null
            }
        }
    }

    fun sendQuizAnswered(
        questionId: String,
        selectedIndex: Int,
        isCorrect: Boolean
    ) {
        val payload =
            mapOf<String, Any>(
                "questionId" to questionId,
                "selectedIndex" to selectedIndex,
                "isCorrect" to isCorrect
            )

        mainHandler.post {
            val activeChannel = channel

            if (activeChannel == null) {
                pendingAnswers.addLast(payload)
                return@post
            }

            activeChannel.invokeMethod(
                "quizAnswered",
                payload
            )
        }
    }

    private fun flushPendingAnswers() {
        val activeChannel =
            channel ?: return

        while (pendingAnswers.isNotEmpty()) {
            activeChannel.invokeMethod(
                "quizAnswered",
                pendingAnswers.removeFirst()
            )
        }
    }
}
