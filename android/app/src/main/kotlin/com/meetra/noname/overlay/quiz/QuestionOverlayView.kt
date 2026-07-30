package com.meetra.noname.overlay.quiz

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.TypedValue
import android.view.MotionEvent
import android.view.View
import kotlin.math.max

class QuestionOverlayView(
    context: Context,
    private val onAnswerSelected: (
        selectedIndex: Int,
        isCorrect: Boolean
    ) -> Unit
) : View(context) {

    private val density =
        resources.displayMetrics.density

    private val backgroundPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE

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

    private val letterPaint =
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(
                55,
                46,
                72
            )

            textSize = sp(15)
            typeface = Typeface.DEFAULT_BOLD
            textAlign = Paint.Align.CENTER
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

    private val optionTextPaint =
        TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(
                55,
                46,
                72
            )

            textSize = sp(14)
            typeface = Typeface.DEFAULT_BOLD
        }

    private val feedbackTextPaint =
        TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            textSize = sp(16)
            typeface = Typeface.DEFAULT_BOLD
        }

    private val explanationTextPaint =
        TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(
                75,
                68,
                85
            )

            textSize = sp(13)
        }

    private var question:
        QuizQuestion? = null

    private var selectedIndex:
        Int? = null

    private var answerWasCorrect:
        Boolean? = null

    private var answerLocked = false

    private var pendingAnswerAction:
        Runnable? = null

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
        pendingAnswerAction?.let {
            removeCallbacks(it)
        }

        pendingAnswerAction = null
        question = newQuestion
        selectedIndex = null
        answerWasCorrect = null
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
            height - dp(22).toFloat()
        )

        canvas.drawRoundRect(
            bubbleRect,
            dp(24).toFloat(),
            dp(24).toFloat(),
            backgroundPaint
        )

        drawPointer(canvas)

        val horizontalPadding = dp(22)

        val questionLayout =
            createTextLayout(
                text = currentQuestion.prompt,
                paint = questionTextPaint,
                width =
                    width -
                        horizontalPadding * 2,
                alignment =
                    Layout.Alignment.ALIGN_CENTER
            )

        canvas.save()

        canvas.translate(
            horizontalPadding.toFloat(),
            dp(23).toFloat()
        )

        questionLayout.draw(canvas)

        canvas.restore()

        val optionsStartY = max(
            dp(92),
            dp(23) +
                questionLayout.height +
                dp(16)
        )

        optionRects.clear()

        currentQuestion.options
            .forEachIndexed {
                index,
                option ->

                val optionTop =
                    optionsStartY +
                        index * (
                            dp(48) +
                                dp(8)
                            )

                val rect = RectF(
                    dp(20).toFloat(),
                    optionTop.toFloat(),
                    width -
                        dp(20).toFloat(),
                    (
                        optionTop +
                            dp(48)
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

        if (answerWasCorrect != null) {
            drawAnswerFeedback(
                canvas = canvas,
                question = currentQuestion,
                topY =
                    optionsStartY +
                        3 * (
                            dp(48) +
                                dp(8)
                            ) +
                        dp(3)
            )
        }
    }

    private fun drawOption(
        canvas: Canvas,
        rect: RectF,
        index: Int,
        option: String,
        question: QuizQuestion
    ) {
        optionPaint.style =
            Paint.Style.FILL

        optionPaint.color =
            getOptionColor(
                index = index,
                question = question
            )

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

        val letterCenterX =
            rect.left + dp(25)

        val textCenterY =
            rect.centerY() -
                (
                    letterPaint.fontMetrics.ascent +
                        letterPaint.fontMetrics.descent
                    ) / 2f

        canvas.drawText(
            letter,
            letterCenterX,
            textCenterY,
            letterPaint
        )

        val optionLayout =
            createTextLayout(
                text = option,
                paint = optionTextPaint,
                width =
                    (
                        rect.width() -
                            dp(65)
                        ).toInt(),
                alignment =
                    Layout.Alignment.ALIGN_NORMAL
            )

        canvas.save()

        canvas.translate(
            rect.left + dp(50),
            rect.centerY() -
                optionLayout.height / 2f
        )

        optionLayout.draw(canvas)

        canvas.restore()
    }

    private fun getOptionColor(
        index: Int,
        question: QuizQuestion
    ): Int {
        if (answerWasCorrect == null) {
            return Color.rgb(
                242,
                239,
                252
            )
        }

        if (index == question.correctIndex) {
            return Color.rgb(
                190,
                239,
                204
            )
        }

        if (index == selectedIndex) {
            return Color.rgb(
                255,
                203,
                198
            )
        }

        return Color.rgb(
            242,
            239,
            252
        )
    }

    private fun drawAnswerFeedback(
        canvas: Canvas,
        question: QuizQuestion,
        topY: Int
    ) {
        val isCorrect =
            answerWasCorrect ?: return

        val isTurkish =
            question.localeCode
                .lowercase()
                .startsWith("tr")

        feedbackTextPaint.color =
            if (isCorrect) {
                Color.rgb(
                    35,
                    145,
                    72
                )
            } else {
                Color.rgb(
                    205,
                    63,
                    55
                )
            }

        val title =
            if (isCorrect) {
                if (isTurkish) {
                    "Doğru! Harika 🎉"
                } else {
                    "Correct! Great job 🎉"
                }
            } else {
                val correctAnswer =
                    question.options[
                        question.correctIndex
                    ]

                if (isTurkish) {
                    "Yanlış. Doğru cevap: $correctAnswer"
                } else {
                    "Wrong. Correct answer: $correctAnswer"
                }
            }

        val titleLayout =
            createTextLayout(
                text = title,
                paint = feedbackTextPaint,
                width = width - dp(44),
                alignment =
                    Layout.Alignment.ALIGN_CENTER
            )

        canvas.save()

        canvas.translate(
            dp(22).toFloat(),
            topY.toFloat()
        )

        titleLayout.draw(canvas)

        canvas.restore()

        if (question.explanation.isBlank()) {
            return
        }

        val explanationLayout =
            createTextLayout(
                text = question.explanation,
                paint = explanationTextPaint,
                width = width - dp(50),
                alignment =
                    Layout.Alignment.ALIGN_CENTER
            )

        canvas.save()

        canvas.translate(
            dp(25).toFloat(),
            (
                topY +
                    titleLayout.height +
                    dp(5)
                ).toFloat()
        )

        explanationLayout.draw(canvas)

        canvas.restore()
    }

    private fun drawPointer(
        canvas: Canvas
    ) {
        val pointerPaint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
            }

        val centerX = width / 2f

        val pointerTop =
            height - dp(30).toFloat()

        val pointerBottom =
            height - dp(4).toFloat()

        val path =
            Path().apply {
                moveTo(
                    centerX - dp(14),
                    pointerTop
                )

                lineTo(
                    centerX,
                    pointerBottom
                )

                lineTo(
                    centerX + dp(14),
                    pointerTop
                )

                close()
            }

        canvas.drawPath(
            path,
            pointerPaint
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

        val isCorrect =
            index ==
                currentQuestion.correctIndex

        answerWasCorrect =
            isCorrect

        invalidate()

        val action =
            Runnable {
                onAnswerSelected(
                    index,
                    isCorrect
                )

                pendingAnswerAction = null
            }

        pendingAnswerAction = action

        postDelayed(
            action,
            1400L
        )

        return true
    }

    override fun performClick():
        Boolean {
        super.performClick()
        return true
    }

    override fun onDetachedFromWindow() {
        pendingAnswerAction?.let {
            removeCallbacks(it)
        }

        pendingAnswerAction = null

        super.onDetachedFromWindow()
    }

    private fun createTextLayout(
        text: String,
        paint: TextPaint,
        width: Int,
        alignment: Layout.Alignment
    ): StaticLayout {
        return StaticLayout.Builder.obtain(
            text,
            0,
            text.length,
            paint,
            width.coerceAtLeast(1)
        )
            .setAlignment(alignment)
            .setIncludePad(false)
            .setLineSpacing(
                0f,
                1.04f
            )
            .build()
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
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_SP,
            value.toFloat(),
            resources.displayMetrics
        )
    }
}
