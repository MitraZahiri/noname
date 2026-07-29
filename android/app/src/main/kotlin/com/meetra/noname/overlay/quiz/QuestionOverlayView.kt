package com.meetra.noname.overlay.quiz

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.view.MotionEvent
import android.view.View
import kotlin.math.max

class QuestionOverlayView(
    context: Context,
    private val onAnswerSelected: (
        isCorrect: Boolean
    ) -> Unit
) : View(context) {

    private val density =
        resources.displayMetrics.density

    private val scaledDensity =
        resources.displayMetrics.scaledDensity

    private val backgroundPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(
                255,
                255,
                255
            )

            setShadowLayer(
                dp(12).toFloat(),
                0f,
                dp(5).toFloat(),
                Color.argb(
                    85,
                    0,
                    0,
                    0
                )
            )
        }

    private val optionPaint =
        Paint(Paint.ANTI_ALIAS_FLAG)

    private val optionTextPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(
                55,
                46,
                72
            )

            textSize = sp(15)
            typeface = Typeface.DEFAULT_BOLD
        }

    private val questionTextPaint =
        TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(
                38,
                31,
                49
            )

            textSize = sp(17)
            typeface = Typeface.DEFAULT_BOLD
        }

    private var question:
        QuizQuestion? = null

    private var selectedIndex:
        Int? = null

    private var answerLocked = false

    private val optionRects =
        mutableListOf<RectF>()

    init {
        setLayerType(
            LAYER_TYPE_SOFTWARE,
            null
        )

        setBackgroundColor(
            Color.TRANSPARENT
        )

        isClickable = true
    }

    fun bind(
        newQuestion: QuizQuestion
    ) {
        question = newQuestion
        selectedIndex = null
        answerLocked = false
        optionRects.clear()
        invalidate()
    }

    override fun onDraw(
        canvas: Canvas
    ) {
        super.onDraw(canvas)

        val currentQuestion =
            question ?: return

        val bubbleRect = RectF(
            dp(8).toFloat(),
            dp(8).toFloat(),
            width - dp(8).toFloat(),
            height - dp(8).toFloat()
        )

        canvas.drawRoundRect(
            bubbleRect,
            dp(24).toFloat(),
            dp(24).toFloat(),
            backgroundPaint
        )

        drawPointer(canvas)

        val horizontalPadding = dp(22)

        val availableTextWidth =
            width -
                horizontalPadding * 2

        val questionLayout =
            StaticLayout.Builder.obtain(
                currentQuestion.prompt,
                0,
                currentQuestion.prompt.length,
                questionTextPaint,
                availableTextWidth
            )
                .setAlignment(
                    Layout.Alignment.ALIGN_CENTER
                )
                .setIncludePad(false)
                .setLineSpacing(
                    0f,
                    1.05f
                )
                .build()

        canvas.save()

        canvas.translate(
            horizontalPadding.toFloat(),
            dp(24).toFloat()
        )

        questionLayout.draw(canvas)

        canvas.restore()

        val optionsStartY = max(
            dp(92),
            dp(24) +
                questionLayout.height +
                dp(18)
        )

        optionRects.clear()

        currentQuestion.options
            .forEachIndexed {
                index,
                option ->

                val optionTop =
                    optionsStartY +
                        index * (
                            dp(46) +
                                dp(9)
                            )

                val rect = RectF(
                    dp(20).toFloat(),
                    optionTop.toFloat(),
                    width -
                        dp(20).toFloat(),
                    (
                        optionTop +
                            dp(46)
                        ).toFloat()
                )

                optionRects.add(rect)

                drawOption(
                    canvas = canvas,
                    rect = rect,
                    index = index,
                    option = option,
                    question = currentQuestion
                )
            }
    }

    private fun drawPointer(
        canvas: Canvas
    ) {
        val pointerPaint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
            }

        val centerX = width / 2f
        val bottom = height - dp(1).toFloat()

        val path =
            android.graphics.Path().apply {
                moveTo(
                    centerX - dp(13),
                    bottom - dp(15)
                )

                lineTo(
                    centerX,
                    bottom
                )

                lineTo(
                    centerX + dp(13),
                    bottom - dp(15)
                )

                close()
            }

        canvas.drawPath(
            path,
            pointerPaint
        )
    }

    private fun drawOption(
        canvas: Canvas,
        rect: RectF,
        index: Int,
        option: String,
        question: QuizQuestion
    ) {
        val selected =
            selectedIndex == index

        optionPaint.style =
            Paint.Style.FILL

        optionPaint.color = when {
            !selected -> {
                Color.rgb(
                    242,
                    239,
                    252
                )
            }

            index ==
                question.correctIndex -> {
                Color.rgb(
                    201,
                    241,
                    211
                )
            }

            else -> {
                Color.rgb(
                    255,
                    211,
                    207
                )
            }
        }

        canvas.drawRoundRect(
            rect,
            dp(15).toFloat(),
            dp(15).toFloat(),
            optionPaint
        )

        val letter = when (index) {
            0 -> "A"
            1 -> "B"
            else -> "C"
        }

        optionTextPaint.textAlign =
            Paint.Align.CENTER

        val letterCenterX =
            rect.left +
                dp(25)

        val textCenterY =
            rect.centerY() -
                (
                    optionTextPaint
                        .fontMetrics
                        .ascent +
                        optionTextPaint
                            .fontMetrics
                            .descent
                    ) / 2f

        canvas.drawText(
            letter,
            letterCenterX,
            textCenterY,
            optionTextPaint
        )

        optionTextPaint.textAlign =
            Paint.Align.LEFT

        canvas.drawText(
            option,
            rect.left + dp(50),
            textCenterY,
            optionTextPaint
        )
    }

    override fun onTouchEvent(
        event: MotionEvent
    ): Boolean {
        if (
            event.actionMasked !=
            MotionEvent.ACTION_UP
        ) {
            return true
        }

        if (answerLocked) {
            return true
        }

        val currentQuestion =
            question ?: return true

        val index =
            optionRects.indexOfFirst { rect ->
                rect.contains(
                    event.x,
                    event.y
                )
            }

        if (index == -1) {
            return true
        }

        performClick()

        answerLocked = true
        selectedIndex = index
        invalidate()

        val isCorrect =
            index ==
                currentQuestion.correctIndex

        postDelayed(
            {
                onAnswerSelected(
                    isCorrect
                )
            },
            550L
        )

        return true
    }

    override fun performClick():
        Boolean {
        super.performClick()
        return true
    }

    private fun dp(
        value: Int
    ): Int {
        return (
            value * density
            ).toInt()
    }

    private fun sp(
        value: Int
    ): Float {
        return value *
            scaledDensity
    }
}
