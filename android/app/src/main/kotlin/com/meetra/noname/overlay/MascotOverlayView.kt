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
import kotlin.math.sin

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

    private var runProgress = 0f
    private var facingRight = true

    private var lastRawX = 0f
    private var lastRawY = 0f
    private var downRawX = 0f
    private var downRawY = 0f
    private var hasMoved = false

    init {
        setBackgroundColor(Color.TRANSPARENT)
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
                translationY = 8f
            }

            MascotAnimationState.LOOKING_LEFT -> {
                animate()
                    .rotation(-11f)
                    .translationY(3f)
                    .setDuration(220L)
                    .start()
            }

            MascotAnimationState.LOOKING_RIGHT -> {
                animate()
                    .rotation(9f)
                    .translationY(6f)
                    .setDuration(220L)
                    .start()
            }

            MascotAnimationState.CLIMBING -> {
                animate()
                    .rotation(0f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .translationY(-4f)
                    .setDuration(500L)
                    .start()
            }

            MascotAnimationState.STANDING,
            MascotAnimationState.RUNNING,
            MascotAnimationState.IDLE -> {
                animate()
                    .alpha(1f)
                    .rotation(0f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .translationY(0f)
                    .setDuration(240L)
                    .start()
            }

            MascotAnimationState.TURNING -> {
                animate()
                    .scaleX(0.25f)
                    .scaleY(1.08f)
                    .setDuration(150L)
                    .start()
            }

            MascotAnimationState.ASKING -> {
                animate()
                    .alpha(1f)
                    .rotation(0f)
                    .scaleX(1f)
                    .scaleY(1f)
                    .translationY(-8f)
                    .setDuration(220L)
                    .start()
            }

            MascotAnimationState.ANSWER_CORRECT -> {
                animate()
                    .translationY(-28f)
                    .rotation(8f)
                    .scaleX(1.12f)
                    .scaleY(1.12f)
                    .setDuration(220L)
                    .withEndAction {
                        animate()
                            .translationY(0f)
                            .rotation(0f)
                            .scaleX(1f)
                            .scaleY(1f)
                            .setDuration(260L)
                            .start()
                    }
                    .start()
            }

            MascotAnimationState.ANSWER_WRONG -> {
                animate()
                    .rotation(-11f)
                    .translationX(-9f)
                    .setDuration(120L)
                    .withEndAction {
                        animate()
                            .rotation(11f)
                            .translationX(9f)
                            .setDuration(120L)
                            .withEndAction {
                                animate()
                                    .rotation(0f)
                                    .translationX(0f)
                                    .setDuration(140L)
                                    .start()
                            }
                            .start()
                    }
                    .start()
            }
            

            MascotAnimationState.REACTING -> {
                playTapAnimation()
            }
        }

        invalidate()
    }

    fun setRunProgress(
        progress: Float,
        isFacingRight: Boolean
    ) {
        runProgress = progress
        facingRight = isFacingRight
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        canvas.save()

        if (!facingRight) {
            canvas.scale(
                -1f,
                1f,
                width / 2f,
                height / 2f
            )
        }

        val centerX = width / 2f
        val headRadius = width * 0.26f
        val headCenterY = height * 0.27f

        val fullBodyVisible = when (
            animationState
        ) {
            MascotAnimationState.CLIMBING,
            MascotAnimationState.STANDING,
            MascotAnimationState.RUNNING,
            MascotAnimationState.TURNING,
            MascotAnimationState.IDLE,
            MascotAnimationState.ASKING,
            MascotAnimationState.REACTING,
            MascotAnimationState.ANSWER_CORRECT,
            MascotAnimationState.ANSWER_WRONG -> true

            else -> false
        }

        if (fullBodyVisible) {
            drawLegs(
                canvas,
                centerX,
                headCenterY,
                headRadius
            )

            drawArms(
                canvas,
                centerX,
                headCenterY,
                headRadius
            )

            drawBody(
                canvas,
                centerX,
                headCenterY,
                headRadius
            )
        }

        if (
            animationState ==
            MascotAnimationState.CLIMBING
        ) {
            drawClimbingHands(
                canvas,
                centerX,
                headCenterY,
                headRadius
            )
        }

        drawHead(
            canvas,
            centerX,
            headCenterY,
            headRadius
        )

        drawEyes(
            canvas,
            centerX,
            headCenterY,
            headRadius
        )

        drawSmile(
            canvas,
            centerX,
            headCenterY,
            headRadius
        )

        canvas.restore()
    }

    private fun drawBody(
        canvas: Canvas,
        centerX: Float,
        headCenterY: Float,
        radius: Float
    ) {
        val bodyTop =
            headCenterY + radius * 0.72f

        val bodyBottom =
            bodyTop + radius * 1.15f

        paint.style = Paint.Style.FILL
        paint.color = Color.rgb(
            105,
            74,
            190
        )

        canvas.drawRoundRect(
            RectF(
                centerX - radius * 0.62f,
                bodyTop,
                centerX + radius * 0.62f,
                bodyBottom
            ),
            radius * 0.32f,
            radius * 0.32f,
            paint
        )

        paint.color = Color.rgb(
            255,
            210,
            68
        )

        canvas.drawCircle(
            centerX,
            bodyTop + radius * 0.55f,
            radius * 0.18f,
            paint
        )

        paint.color = Color.rgb(
            78,
            48,
            155
        )

        paint.style = Paint.Style.STROKE
        paint.strokeWidth = radius * 0.07f

        canvas.drawLine(
            centerX,
            bodyTop + radius * 0.10f,
            centerX,
            bodyBottom - radius * 0.12f,
            paint
        )

        paint.style = Paint.Style.FILL
    }

    private fun drawArms(
        canvas: Canvas,
        centerX: Float,
        headCenterY: Float,
        radius: Float
    ) {
        val bodyTop =
            headCenterY + radius * 0.78f

        val shoulderY =
            bodyTop + radius * 0.22f

        val runWave = if (
            animationState ==
            MascotAnimationState.RUNNING
        ) {
            sin(
                runProgress *
                    Math.PI *
                    12.0
            ).toFloat()
        } else {
            0f
        }

        val armSwing =
            runWave * radius * 0.28f

        paint.style = Paint.Style.STROKE
        paint.strokeCap = Paint.Cap.ROUND
        paint.strokeWidth = radius * 0.25f
        paint.color = Color.rgb(
            105,
            74,
            190
        )

        val leftShoulderX =
            centerX - radius * 0.48f

        val rightShoulderX =
            centerX + radius * 0.48f

        val leftHandX =
            centerX - radius * 0.82f +
                armSwing

        val rightHandX =
            centerX + radius * 0.82f -
                armSwing

        val handY =
            shoulderY + radius * 0.64f

        canvas.drawLine(
            leftShoulderX,
            shoulderY,
            leftHandX,
            handY,
            paint
        )

        canvas.drawLine(
            rightShoulderX,
            shoulderY,
            rightHandX,
            handY,
            paint
        )

        paint.style = Paint.Style.FILL
        paint.color = Color.rgb(
            255,
            199,
            52
        )

        canvas.drawCircle(
            leftHandX,
            handY,
            radius * 0.14f,
            paint
        )

        canvas.drawCircle(
            rightHandX,
            handY,
            radius * 0.14f,
            paint
        )
    }

    private fun drawLegs(
        canvas: Canvas,
        centerX: Float,
        headCenterY: Float,
        radius: Float
    ) {
        val bodyTop =
            headCenterY + radius * 0.72f

        val bodyBottom =
            bodyTop + radius * 1.15f

        val runWave = if (
            animationState ==
            MascotAnimationState.RUNNING
        ) {
            sin(
                runProgress *
                    Math.PI *
                    12.0
            ).toFloat()
        } else {
            0f
        }

        val legSwing =
            runWave * radius * 0.33f

        val hipY =
            bodyBottom - radius * 0.06f

        val footY =
            hipY + radius * 0.86f

        val leftHipX =
            centerX - radius * 0.25f

        val rightHipX =
            centerX + radius * 0.25f

        val leftFootX =
            leftHipX + legSwing

        val rightFootX =
            rightHipX - legSwing

        paint.style = Paint.Style.STROKE
        paint.strokeCap = Paint.Cap.ROUND
        paint.strokeWidth = radius * 0.24f
        paint.color = Color.rgb(
            65,
            65,
            78
        )

        canvas.drawLine(
            leftHipX,
            hipY,
            leftFootX,
            footY,
            paint
        )

        canvas.drawLine(
            rightHipX,
            hipY,
            rightFootX,
            footY,
            paint
        )

        paint.style = Paint.Style.FILL
        paint.color = Color.rgb(
            99,
            69,
            196
        )

        canvas.drawOval(
            RectF(
                leftFootX - radius * 0.24f,
                footY - radius * 0.08f,
                leftFootX + radius * 0.30f,
                footY + radius * 0.20f
            ),
            paint
        )

        canvas.drawOval(
            RectF(
                rightFootX - radius * 0.24f,
                footY - radius * 0.08f,
                rightFootX + radius * 0.30f,
                footY + radius * 0.20f
            ),
            paint
        )
    }

    private fun drawClimbingHands(
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
            centerX - radius * 0.78f,
            centerY + radius * 0.58f,
            radius * 0.17f,
            paint
        )

        canvas.drawCircle(
            centerX + radius * 0.78f,
            centerY + radius * 0.58f,
            radius * 0.17f,
            paint
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

        canvas.drawOval(
            RectF(
                centerX - radius * 0.57f,
                centerY - radius * 0.30f,
                centerX - radius * 0.04f,
                centerY + radius * 0.22f
            ),
            paint
        )

        canvas.drawOval(
            RectF(
                centerX + radius * 0.04f,
                centerY - radius * 0.30f,
                centerX + radius * 0.57f,
                centerY + radius * 0.22f
            ),
            paint
        )

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
            .scaleX(1.18f)
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
