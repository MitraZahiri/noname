package com.meetra.noname.overlay.quiz

import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import kotlin.math.roundToInt

class ContinueQuizOverlayWindowController(
    context: Context,
    private val onYesSelected: () -> Unit,
    private val onNoSelected: () -> Unit
) {

    private val applicationContext =
        context.applicationContext

    private val windowManager =
        applicationContext.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager

    private val windowWidth =
        dp(300)

    private val windowHeight =
        dp(165)

    private val continueView =
        ContinueQuizOverlayView(
            context = applicationContext,
            onYesSelected =
                onYesSelected,
            onNoSelected =
                onNoSelected
        )

    private val layoutParams =
        WindowManager.LayoutParams(
            windowWidth,
            windowHeight,
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

    private var isAttached =
        false

    fun show(
        localeCode: String,
        anchorCenterX: Int,
        anchorTopY: Int,
        anchorHeight: Int
    ) {
        continueView.bind(
            localeCode
        )

        val displayMetrics =
            applicationContext
                .resources
                .displayMetrics

        val maximumX =
            displayMetrics.widthPixels -
                windowWidth -
                dp(8)

        layoutParams.x =
            (
                anchorCenterX -
                    windowWidth / 2
                ).coerceIn(
                    dp(8),
                    maximumX
                        .coerceAtLeast(dp(8))
                )

        val preferredTopY =
            anchorTopY -
                windowHeight -
                dp(12)

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
                        displayMetrics
                            .heightPixels -
                            windowHeight -
                            dp(8)
                    )
            }

        continueView
            .animate()
            .cancel()

        if (!isAttached) {
            windowManager.addView(
                continueView,
                layoutParams
            )

            isAttached = true
        } else {
            windowManager.updateViewLayout(
                continueView,
                layoutParams
            )
        }

        continueView.alpha = 0f
        continueView.scaleX = 0.75f
        continueView.scaleY = 0.75f

        continueView.animate()
            .alpha(1f)
            .scaleX(1f)
            .scaleY(1f)
            .setDuration(230L)
            .start()
    }

    fun hide() {
        if (!isAttached) {
            return
        }

        continueView
            .animate()
            .cancel()

        continueView.animate()
            .alpha(0f)
            .scaleX(0.82f)
            .scaleY(0.82f)
            .setDuration(140L)
            .withEndAction {
                if (!isAttached) {
                    return@withEndAction
                }

                runCatching {
                    windowManager
                        .removeViewImmediate(
                            continueView
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
