package com.meetra.noname.overlay

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import kotlin.math.abs

class MascotOverlayView(
    context: Context,
    private val onDrag: (deltaX: Int, deltaY: Int) -> Unit,
    private val onTap: () -> Unit
) : View(context) {

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    private val touchSlop =
        ViewConfiguration.get(context).scaledTouchSlop

    private var lastRawX = 0f
    private var lastRawY = 0f
    private var downRawX = 0f
    private var downRawY = 0f
    private var hasMoved = false

    init {
        setBackgroundColor(Color.TRANSPARENT)
        isClickable = true
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        val centerX = width / 2f
        val centerY = height / 2f
        val radius = minOf(width, height) * 0.43f

        paint.style = Paint.Style.FILL

        paint.color = Color.rgb(255, 199, 52)
        canvas.drawCircle(centerX, centerY, radius, paint)

        paint.color = Color.argb(80, 255, 255, 255)
        canvas.drawCircle(
            centerX - radius * 0.28f,
            centerY - radius * 0.32f,
            radius * 0.18f,
            paint
        )

        paint.color = Color.WHITE

        canvas.drawOval(
            RectF(
                centerX - radius * 0.55f,
                centerY - radius * 0.28f,
                centerX - radius * 0.05f,
                centerY + radius * 0.20f
            ),
            paint
        )

        canvas.drawOval(
            RectF(
                centerX + radius * 0.05f,
                centerY - radius * 0.28f,
                centerX + radius * 0.55f,
                centerY + radius * 0.20f
            ),
            paint
        )

        paint.color = Color.rgb(45, 34, 30)

        canvas.drawCircle(
            centerX - radius * 0.23f,
            centerY,
            radius * 0.10f,
            paint
        )

        canvas.drawCircle(
            centerX + radius * 0.23f,
            centerY,
            radius * 0.10f,
            paint
        )

        paint.color = Color.rgb(90, 40, 35)
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

    override fun onTouchEvent(event: MotionEvent): Boolean {
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
                val deltaX = (event.rawX - lastRawX).toInt()
                val deltaY = (event.rawY - lastRawY).toInt()

                if (
                    abs(event.rawX - downRawX) > touchSlop ||
                    abs(event.rawY - downRawY) > touchSlop
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
        animate()
            .scaleX(1.18f)
            .scaleY(1.18f)
            .setDuration(120L)
            .withEndAction {
                animate()
                    .scaleX(1f)
                    .scaleY(1f)
                    .setDuration(160L)
                    .start()
            }
            .start()
    }
}
