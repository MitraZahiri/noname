package com.meetra.noname.overlay

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import com.meetra.noname.overlay.animation.MascotAnimationState
import kotlin.math.abs

class MascotOverlayView(
    context: Context,
    private val onDrag: (
        deltaX: Int,
        deltaY: Int
    ) -> Unit,
    private val onTap: () -> Unit
) : View(context) {

    private val paint =
        Paint(Paint.ANTI_ALIAS_FLAG)

    private val touchSlop =
        ViewConfiguration
            .get(context)
            .scaledTouchSlop

    private var animationState =
        MascotAnimationState.HIDDEN

    private var lastRawX = 0f
    private var lastRawY = 0f

    private var downRawX = 0f
    private var downRawY = 0f

    private var hasMoved = false

    init {
        setBackgroundColor(
            Color.TRANSPARENT
        )

        isClickable = true
        alpha = 0f
    }

    fun setAnimationState(
        state: MascotAnimationState
    ) {
        animationState = state

        animate().cancel()

        when (state) {
            MascotAnimationState.HIDDEN -> {
                alpha = 0f
            }

            MascotAnimationState.PEEKING -> {
                alpha = 1f
                rotation = -7f
                scaleX = 0.92f
                scaleY = 0.92f
                translationY = 7f
            }

            MascotAnimationState.LOOKING_LEFT -> {
                animate()
                    .rotation(-11f)
                    .translationY(2f)
                    .setDuration(220L)
                    .start()
            }

            MascotAnimationState.LOOKING_RIGHT -> {
                animate()
                    .rotation(9f)
                    .translationY(5f)
                    .setDuration(220L)
                    .start()
            }

            MascotAnimationState.CLIMBING -> {
                animate()
                    .rotation(0f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .translationY(-5f)
                    .setDuration(500L)
                    .start()
            }

            MascotAnimationState.IDLE -> {
                animate()
                    .alpha(1f)
                    .rotation(0f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .translationY(0f)
                    .setDuration(260L)
                    .start()
            }

            MascotAnimationState.REACTING -> {
                playTapAnimation()
            }
        }

        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val centerX = width / 2f
        val centerY = height / 2f

        val radius =
            minOf(width, height) * 0.41f

        paint.style = Paint.Style.FILL

        drawHandsIfNeeded(
            canvas = canvas,
            centerX = centerX,
            centerY = centerY,
            radius = radius
        )

        drawHead(
            canvas = canvas,
            centerX = centerX,
            centerY = centerY,
            radius = radius
        )

        drawEyes(
            canvas = canvas,
            centerX = centerX,
            centerY = centerY,
            radius = radius
        )

        drawSmile(
            canvas = canvas,
            centerX = centerX,
            centerY = centerY,
            radius = radius
        )
    }

    private fun drawHead(
        canvas: Canvas,
        centerX: Float,
        centerY: Float,
        radius: Float
    ) {
        paint.style = Paint.Style.FILL
        paint.color = Color.rgb(
            255,
            199,
            52
        )

        canvas.drawCircle(
            centerX,
            centerY,
            radius,
            paint
        )

        paint.color = Color.argb(
            75,
            255,
            255,
            255
        )

        canvas.drawCircle(
            centerX - radius * 0.28f,
            centerY - radius * 0.32f,
            radius * 0.17f,
            paint
        )
    }

    private fun drawEyes(
        canvas: Canvas,
        centerX: Float,
        centerY: Float,
        radius: Float
    ) {
        paint.style = Paint.Style.FILL
        paint.color = Color.WHITE

        val leftEye = RectF(
            centerX - radius * 0.57f,
            centerY - radius * 0.30f,
            centerX - radius * 0.04f,
            centerY + radius * 0.22f
        )

        val rightEye = RectF(
            centerX + radius * 0.04f,
            centerY - radius * 0.30f,
            centerX + radius * 0.57f,
            centerY + radius * 0.22f
        )

        canvas.drawOval(leftEye, paint)
        canvas.drawOval(rightEye, paint)

        val pupilOffset = when (
            animationState
        ) {
            MascotAnimationState.LOOKING_LEFT ->
                -radius * 0.10f

            MascotAnimationState.LOOKING_RIGHT ->
                radius * 0.10f

            else -> 0f
        }

        paint.color = Color.rgb(
            45,
            34,
            30
        )

        canvas.drawCircle(
            centerX -
                radius * 0.25f +
                pupilOffset,
            centerY,
            radius * 0.105f,
            paint
        )

        canvas.drawCircle(
            centerX +
                radius * 0.25f +
                pupilOffset,
            centerY,
            radius * 0.105f,
            paint
        )
    }

    private fun drawSmile(
        canvas: Canvas,
        centerX: Float,
        centerY: Float,
        radius: Float
    ) {
        paint.color = Color.rgb(
            90,
            40,
            35
        )

        paint.style = Paint.Style.STROKE
        paint.strokeWidth = radius * 0.09f
        paint.strokeCap = Paint.Cap.ROUND

        canvas.drawArc(
            RectF(
                centerX - radius * 0.38f,
                centerY + radius * 0.05f,
                centerX + radius * 0.38f,
                centerY + radius * 0.52f
            ),
            15f,
            150f,
            false,
            paint
        )

        paint.style = Paint.Style.FILL
    }

    private fun drawHandsIfNeeded(
        canvas: Canvas,
        centerX: Float,
        centerY: Float,
        radius: Float
    ) {
        if (
            animationState !=
            MascotAnimationState.CLIMBING
        ) {
            return
        }

        paint.style = Paint.Style.FILL
        paint.color = Color.rgb(
            255,
            199,
            52
        )

        canvas.drawCircle(
            centerX - radius * 0.77f,
            centerY + radius * 0.38f,
            radius * 0.17f,
            paint
        )

        canvas.drawCircle(
            centerX + radius * 0.77f,
            centerY + radius * 0.38f,
            radius * 0.17f,
            paint
        )
    }

    override fun onTouchEvent(
        event: MotionEvent
    ): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                downRawX = event.rawX
                downRawY = event.rawY

                lastRawX = event.rawX
                lastRawY = event.rawY

                hasMoved = false

                return true
            }

            MotionEvent.ACTION_MOVE -> {
                val deltaX =
                    (event.rawX - lastRawX)
                        .toInt()

                val deltaY =
                    (event.rawY - lastRawY)
                        .toInt()

                if (
                    abs(
                        event.rawX - downRawX
                    ) > touchSlop ||
                    abs(
                        event.rawY - downRawY
                    ) > touchSlop
                ) {
                    hasMoved = true
                }

                onDrag(deltaX, deltaY)

                lastRawX = event.rawX
                lastRawY = event.rawY

                return true
            }

            MotionEvent.ACTION_UP -> {
                if (!hasMoved) {
                    performClick()
                }

                return true
            }

            MotionEvent.ACTION_CANCEL -> {
                return true
            }
        }

        return super.onTouchEvent(event)
    }

    override fun performClick(): Boolean {
        super.performClick()

        onTap()

        return true
    }

    fun playTapAnimation() {
        animate().cancel()

        animate()
            .scaleX(1.20f)
            .scaleY(0.84f)
            .rotation(-5f)
            .setDuration(130L)
            .withEndAction {
                animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .rotation(0f)
                    .setDuration(190L)
                    .start()
            }
            .start()
    }
}
