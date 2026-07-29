package com.meetra.noname.overlay

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import com.meetra.noname.overlay.animation.MascotAnimationController
import com.meetra.noname.overlay.animation.MascotAnimationState
import kotlin.math.roundToInt

class OverlayWindowController(
    context: Context
) {

    private val applicationContext =
        context.applicationContext

    private val windowManager =
        applicationContext.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager

    private val mascotView:
        MascotOverlayView

    private val animationController:
        MascotAnimationController

    private val layoutParams:
        WindowManager.LayoutParams

    private var isAttached = false

    private var windowAnimator:
        ValueAnimator? = null

    init {
        mascotView = MascotOverlayView(
            context = applicationContext,
            onDrag = ::moveBy,
            onTap = ::handleMascotTap
        )

        animationController =
            MascotAnimationController(
                onStateChanged =
                    mascotView::setAnimationState,
                onClimbRequested =
                    ::animateClimb
            )

        val size = dp(104)

        layoutParams =
            WindowManager.LayoutParams(
                size,
                size,
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
    }

    fun show() {
        if (isAttached) {
            animationController.react()
            return
        }

        val hiddenX = -dp(92)
        val peekX = -dp(49)

        layoutParams.x = hiddenX

        layoutParams.y = (
            applicationContext
                .resources
                .displayMetrics
                .heightPixels * 0.28f
            ).roundToInt()

        windowManager.addView(
            mascotView,
            layoutParams
        )

        isAttached = true

        mascotView.setAnimationState(
            MascotAnimationState.PEEKING
        )

        animateWindowX(
            fromX = hiddenX,
            toX = peekX,
            durationMillis = 600L
        )

        animationController.startEntrance()
    }

    fun hide() {
        windowAnimator?.cancel()
        windowAnimator = null

        animationController.hide()

        if (!isAttached) {
            return
        }

        runCatching {
            windowManager.removeViewImmediate(
                mascotView
            )
        }

        isAttached = false
    }

    private fun animateClimb() {
        if (!isAttached) {
            return
        }

        animateWindowX(
            fromX = layoutParams.x,
            toX = dp(12),
            durationMillis = 850L
        )
    }

    private fun handleMascotTap() {
        animationController.react()
    }

    private fun moveBy(
        deltaX: Int,
        deltaY: Int
    ) {
        if (!isAttached) {
            return
        }

        windowAnimator?.cancel()
        animationController.showIdle()

        val displayMetrics =
            applicationContext
                .resources
                .displayMetrics

        val maxX =
            displayMetrics.widthPixels -
                layoutParams.width

        val maxY =
            displayMetrics.heightPixels -
                layoutParams.height

        layoutParams.x =
            (layoutParams.x + deltaX)
                .coerceIn(
                    -dp(38),
                    maxX
                )

        layoutParams.y =
            (layoutParams.y + deltaY)
                .coerceIn(
                    0,
                    maxY
                )

        updateLayout()
    }

    private fun animateWindowX(
        fromX: Int,
        toX: Int,
        durationMillis: Long
    ) {
        windowAnimator?.cancel()

        windowAnimator =
            ValueAnimator.ofInt(
                fromX,
                toX
            ).apply {
                duration = durationMillis

                addUpdateListener { animator ->
                    if (!isAttached) {
                        return@addUpdateListener
                    }

                    layoutParams.x =
                        animator.animatedValue
                            as Int

                    updateLayout()
                }

                start()
            }
    }

    private fun updateLayout() {
        if (!isAttached) {
            return
        }

        runCatching {
            windowManager.updateViewLayout(
                mascotView,
                layoutParams
            )
        }
    }

    private fun dp(value: Int): Int {
        return (
            value *
                applicationContext
                    .resources
                    .displayMetrics
                    .density
            ).roundToInt()
    }
}
