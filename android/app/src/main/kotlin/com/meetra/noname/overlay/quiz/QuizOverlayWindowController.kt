package com.meetra.noname.overlay.quiz

import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import kotlin.math.roundToInt

class QuizOverlayWindowController(
    context: Context,
    private val onAnswered: (
        questionId: String,
        selectedIndex: Int,
        isCorrect: Boolean
    ) -> Unit
) {

    private val applicationContext =
        context.applicationContext

    private val windowManager =
        applicationContext.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager

    private val bubbleWidth = dp(310)
    private val bubbleHeight = dp(360)

    private var currentQuestion:
        QuizQuestion? = null

    private val questionView =
        QuestionOverlayView(
            context = applicationContext,
            onAnswerSelected =
                ::handleAnswerSelected
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
        currentQuestion = question

        questionView.animate().cancel()
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
                    maximumX.coerceAtLeast(dp(8))
                )

        val preferredTopY =
            anchorTopY -
                bubbleHeight -
                dp(8)

        layoutParams.y =
            if (preferredTopY >= dp(8)) {
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
        questionView.scaleX = 0.82f
        questionView.scaleY = 0.82f

        questionView.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(240L)
            .start()
    }

    fun hide() {
        if (!isAttached) {
            return
        }

        questionView.animate().cancel()

        questionView.animate()
            .alpha(0f)
            .scaleX(0.88f)
            .scaleY(0.88f)
            .setDuration(150L)
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

    private fun handleAnswerSelected(
        selectedIndex: Int,
        isCorrect: Boolean
    ) {
        val answeredQuestion =
            currentQuestion ?: return

        hide()

        onAnswered(
            answeredQuestion.id,
            selectedIndex,
            isCorrect
        )
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
