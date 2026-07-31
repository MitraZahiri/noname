package com.meetra.noname.overlay.animation

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.view.animation.LinearInterpolator

class MascotMovementController(
    private val onFrame: (
        x: Int,
        progress: Float
    ) -> Unit
) {

    private var animator:
        ValueAnimator? = null

    fun run(
        fromX: Int,
        toX: Int,
        durationMillis: Long,
        onFinished: () -> Unit
    ) {
        cancel()

        var wasCancelled = false

        animator =
            ValueAnimator.ofInt(
                fromX,
                toX
            ).apply {
                duration = durationMillis

                interpolator =
                    LinearInterpolator()

                addUpdateListener {
                    valueAnimator ->

                    onFrame(
                        valueAnimator
                            .animatedValue
                            as Int,
                        valueAnimator
                            .animatedFraction
                    )
                }

                addListener(
                    object :
                        AnimatorListenerAdapter() {

                        override fun onAnimationCancel(
                            animation: Animator
                        ) {
                            wasCancelled = true
                        }

                        override fun onAnimationEnd(
                            animation: Animator
                        ) {
                            if (!wasCancelled) {
                                onFinished()
                            }

                            if (
                                animator ===
                                animation
                            ) {
                                animator = null
                            }
                        }
                    }
                )

                start()
            }
    }

    fun cancel() {
        animator?.cancel()
        animator = null
    }
}
