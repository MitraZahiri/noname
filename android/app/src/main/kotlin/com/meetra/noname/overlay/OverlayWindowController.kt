package com.meetra.noname.overlay

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import kotlin.math.roundToInt

class OverlayWindowController(
    context: Context
) {
    private val applicationContext = context.applicationContext

    private val windowManager =
        applicationContext.getSystemService(
            Context.WINDOW_SERVICE
        ) as WindowManager

    private lateinit var mascotView: MascotOverlayView
    private lateinit var layoutParams: WindowManager.LayoutParams

    private var isAttached = false
    private var entranceAnimator: ValueAnimator? = null

    init {
        createMascotView()
        createLayoutParams()
    }

    fun show() {
        if (isAttached) {
            mascotView.playTapAnimation()
            return
        }

        val hiddenX = -dp(68)
        val targetX = dp(12)

        layoutParams.x = hiddenX
        layoutParams.y = (
            applicationContext
                .resources
                .displayMetrics
                .heightPixels * 0.30f
            ).roundToInt()

        windowManager.addView(
            mascotView,
            layoutParams
        )

        isAttached = true

        entranceAnimator?.cancel()

        entranceAnimator = ValueAnimator.ofInt(
            hiddenX,
            targetX
        ).apply {
            duration = 750L

            addUpdateListener { animator ->
                if (!isAttached) {
                    return@addUpdateListener
                }

                layoutParams.x =
                    animator.animatedValue as Int

                updateLayout()
            }

            start()
        }
    }

    fun hide() {
        entranceAnimator?.cancel()
        entranceAnimator = null

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

    private fun createMascotView() {
        mascotView = MascotOverlayView(
            context = applicationContext,
            onDrag = ::moveBy,
            onTap = {
                mascotView.playTapAnimation()
            }
        )
    }

    private fun createLayoutParams() {
        val size = dp(92)

        layoutParams = WindowManager.LayoutParams(
            size,
            size,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
        }
    }

    private fun moveBy(
        deltaX: Int,
        deltaY: Int
    ) {
        if (!isAttached) {
            return
        }

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
            (layoutParams.x + deltaX).coerceIn(
                -dp(35),
                maxX
            )

        layoutParams.y =
            (layoutParams.y + deltaY).coerceIn(
                0,
                maxY
            )

        updateLayout()
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
