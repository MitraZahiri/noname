package com.meetra.noname.overlay.quiz

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.widget.LinearLayout
import android.widget.TextView

class ContinueQuizOverlayView(
    context: Context,
    private val onYesSelected: () -> Unit,
    private val onNoSelected: () -> Unit
) : LinearLayout(context) {

    private val titleView =
        TextView(context)

    private val yesButton =
        TextView(context)

    private val noButton =
        TextView(context)

    init {
        orientation = VERTICAL
        gravity = Gravity.CENTER

        setPadding(
            dp(20),
            dp(18),
            dp(20),
            dp(16)
        )

        background =
            createRoundedBackground(
                color = Color.WHITE,
                radius = 24
            )

        elevation = dp(12).toFloat()

        titleView.apply {
            gravity = Gravity.CENTER
            setTextColor(
                Color.rgb(
                    42,
                    35,
                    55
                )
            )

            setTextSize(
                TypedValue.COMPLEX_UNIT_SP,
                17f
            )

            typeface =
                Typeface.DEFAULT_BOLD

            setPadding(
                dp(5),
                0,
                dp(5),
                dp(16)
            )
        }

        yesButton.apply {
            gravity = Gravity.CENTER

            setTextColor(
                Color.rgb(
                    25,
                    105,
                    55
                )
            )

            setTextSize(
                TypedValue.COMPLEX_UNIT_SP,
                15f
            )

            typeface =
                Typeface.DEFAULT_BOLD

            background =
                createRoundedBackground(
                    color = Color.rgb(
                        198,
                        241,
                        211
                    ),
                    radius = 15
                )

            setOnClickListener {
                onYesSelected()
            }
        }

        noButton.apply {
            gravity = Gravity.CENTER

            setTextColor(
                Color.rgb(
                    160,
                    55,
                    50
                )
            )

            setTextSize(
                TypedValue.COMPLEX_UNIT_SP,
                15f
            )

            typeface =
                Typeface.DEFAULT_BOLD

            background =
                createRoundedBackground(
                    color = Color.rgb(
                        255,
                        216,
                        211
                    ),
                    radius = 15
                )

            setOnClickListener {
                onNoSelected()
            }
        }

        val buttonRow =
            LinearLayout(context).apply {
                orientation = HORIZONTAL
                gravity = Gravity.CENTER
            }

        buttonRow.addView(
            yesButton,
            LayoutParams(
                0,
                dp(48),
                1f
            ).apply {
                marginEnd = dp(6)
            }
        )

        buttonRow.addView(
            noButton,
            LayoutParams(
                0,
                dp(48),
                1f
            ).apply {
                marginStart = dp(6)
            }
        )

        addView(
            titleView,
            LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            )
        )

        addView(
            buttonRow,
            LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.WRAP_CONTENT
            )
        )
    }

    fun bind(
        localeCode: String
    ) {
        val isTurkish =
            localeCode
                .lowercase()
                .startsWith("tr")

        titleView.text =
            if (isTurkish) {
                "Başka bir bilgi sorusu ister misin?"
            } else {
                "Would you like another trivia question?"
            }

        yesButton.text =
            if (isTurkish) {
                "Evet"
            } else {
                "Yes"
            }

        noButton.text =
            if (isTurkish) {
                "Hayır"
            } else {
                "No"
            }
    }

    private fun createRoundedBackground(
        color: Int,
        radius: Int
    ): GradientDrawable {
        return GradientDrawable().apply {
            shape =
                GradientDrawable.RECTANGLE

            setColor(color)

            cornerRadius =
                dp(radius).toFloat()
        }
    }

    private fun dp(
        value: Int
    ): Int {
        return (
            value *
                resources
                    .displayMetrics
                    .density
            ).toInt()
    }
}
