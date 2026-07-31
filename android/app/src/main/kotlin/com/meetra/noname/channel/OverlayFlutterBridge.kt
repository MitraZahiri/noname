package com.meetra.noname.channel

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayDeque

object OverlayFlutterBridge {

    private data class PendingCall(
        val method: String,
        val arguments: Any?
    )

    private val mainHandler =
        Handler(
            Looper.getMainLooper()
        )

    private var channel:
        MethodChannel? = null

    private val pendingCalls =
        ArrayDeque<PendingCall>()

    fun attach(
        newChannel: MethodChannel
    ) {
        mainHandler.post {
            channel = newChannel
            flushPendingCalls()
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
        send(
            method = "quizAnswered",
            arguments =
                mapOf<String, Any>(
                    "questionId" to
                        questionId,
                    "selectedIndex" to
                        selectedIndex,
                    "isCorrect" to
                        isCorrect
                )
        )
    }

    fun sendNextQuestionRequested() {
        send(
            method =
                "nextQuestionRequested",
            arguments = null
        )
    }

    fun sendMascotDismissed() {
        send(
            method =
                "mascotDismissed",
            arguments = null
        )
    }

    private fun send(
        method: String,
        arguments: Any?
    ) {
        mainHandler.post {
            val activeChannel =
                channel

            if (activeChannel == null) {
                pendingCalls.addLast(
                    PendingCall(
                        method = method,
                        arguments = arguments
                    )
                )

                return@post
            }

            activeChannel.invokeMethod(
                method,
                arguments
            )
        }
    }

    private fun flushPendingCalls() {
        val activeChannel =
            channel ?: return

        while (
            pendingCalls.isNotEmpty()
        ) {
            val call =
                pendingCalls.removeFirst()

            activeChannel.invokeMethod(
                call.method,
                call.arguments
            )
        }
    }
}
