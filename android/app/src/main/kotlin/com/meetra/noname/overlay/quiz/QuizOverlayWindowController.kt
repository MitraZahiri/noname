package com.meetra.noname.overlay.quiz

import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import kotlin.math.roundToInt

class QuizOverlayWindowController(
    context: Context,
    private val onAnswered: (
        isCorrect: Boolean
    ) -> Unit
) {

    private val applicationContext =
        context.applicationContext

    private val windowManager =
        applicationContext.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager

    private val bubbleWidth = dp(300)
    private val bubbleHeight = dp(270)

    private val questionView =
        QuestionOverlayView(
            context = applicationContext,
            onAnswerSelected = {
                isCorrect ->

                hide()

                onAnswered(
                    isCorrect
                )
            }
        )

    private val layoutParams =
        WindowManager.LayoutParams(
            bubbleWidth,
            bubbleHeight,
            WindowManager.LayoutParams
                .TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams
                .FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams
                    .FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams
                    .FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity =
                Gravity.TOP or Gravity.START
        }

    private var isAttached = false

    fun show(
        question: QuizQuestion,
        anchorCenterX: Int,
        anchorTopY: Int,
        anchorHeight: Int
    ) {
        questionView.bind(question)

        val displayMetrics =
            applicationContext
                .resources
                .displayMetrics

        val maximumX =
            displayMetrics.widthPixels -
                bubbleWidth -
                dp(8)

        layoutParams.x =
            (
                anchorCenterX -
                    bubbleWidth / 2
                ).coerceIn(
                    dp(8),
                    maximumX
                )

        val preferredTopY =
            anchorTopY -
                bubbleHeight -
                dp(8)

        layoutParams.y =
            if (
                preferredTopY >= dp(8)
            ) {
                preferredTopY
            } else {
                (
                    anchorTopY +
                        anchorHeight +
                        dp(8)
                    ).coerceAtMost(
                        displayMetrics.heightPixels -
                            bubbleHeight -
                            dp(8)
                    )
            }

        if (!isAttached) {
            windowManager.addView(
                questionView,
                layoutParams
            )

            isAttached = true
        } else {
            windowManager.updateViewLayout(
                questionView,
                layoutParams
            )
        }

        questionView.alpha = 0f
        questionView.scaleX = 0.78f
        questionView.scaleY = 0.78f

        questionView.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(260L)
            .start()
    }

    fun hide() {
        if (!isAttached) {
            return
        }

        questionView.animate()
            .alpha(0f)
            .scaleX(0.85f)
            .scaleY(0.85f)
            .setDuration(160L)
            .withEndAction {
                if (!isAttached) {
                    return@withEndAction
                }

                runCatching {
                    windowManager
                        .removeViewImmediate(
                            questionView
                        )
                }

                isAttached = false
            }
            .start()
    }

    private fun dp(
        value: Int
    ): Int {
        return (
            value *
                applicationContext
                    .resources
                    .displayMetrics
                    .density
            ).roundToInt()
    }
}
