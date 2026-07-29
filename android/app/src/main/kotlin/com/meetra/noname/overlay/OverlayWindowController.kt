package com.meetra.noname.overlay

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import com.meetra.noname.overlay.animation.MascotAnimationController
import com.meetra.noname.overlay.animation.MascotAnimationState
import com.meetra.noname.overlay.animation.MascotMovementController
import com.meetra.noname.overlay.quiz.DemoQuizRepository
import com.meetra.noname.overlay.quiz.QuizOverlayWindowController
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

    private val movementController:
        MascotMovementController

    private val quizRepository =
        DemoQuizRepository()

    private val quizWindowController:
        QuizOverlayWindowController

    private val layoutParams:
        WindowManager.LayoutParams

    private var isAttached = false

    private var windowAnimator:
        ValueAnimator? = null

    private var facingRight = true

    init {
        mascotView = MascotOverlayView(
            context = applicationContext,
            onDrag = ::moveBy,
            onTap = ::handleMascotTap
        )

        movementController =
            MascotMovementController(
                onFrame = ::handleRunFrame
            )

        quizWindowController =
            QuizOverlayWindowController(
                context = applicationContext,
                onAnswered =
                    ::handleQuizAnswer
            )

        animationController =
            MascotAnimationController(
                onStateChanged =
                    mascotView::setAnimationState,
                onClimbRequested =
                    ::animateClimb,
                onRunRequested =
                    ::startJourney
            )

        layoutParams =
            WindowManager.LayoutParams(
                dp(136),
                dp(180),
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
            quizWindowController.hide()
            movementController.cancel()
            animationController.react()
            return
        }

        val hiddenX = -dp(124)
        val peekX = -dp(80)

        layoutParams.x = hiddenX

        layoutParams.y = (
            applicationContext
                .resources
                .displayMetrics
                .heightPixels * 0.42f
            ).roundToInt()

        windowManager.addView(
            mascotView,
            layoutParams
        )

        isAttached = true
        facingRight = true

        mascotView.setRunProgress(
            progress = 0f,
            isFacingRight = true
        )

        mascotView.setAnimationState(
            MascotAnimationState.PEEKING
        )

        animateWindowX(
            fromX = hiddenX,
            toX = peekX,
            durationMillis = 600L
        )

        animationController
            .startEntrance()
    }

    fun hide() {
        windowAnimator?.cancel()
        windowAnimator = null

        movementController.cancel()
        animationController.hide()
        quizWindowController.hide()

        if (!isAttached) {
            return
        }

        runCatching {
            windowManager
                .removeViewImmediate(
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
            toX = dp(8),
            durationMillis = 850L
        )
    }

    private fun startJourney() {
        runToRightEdge()
    }

    private fun runToRightEdge() {
        if (!isAttached) {
            return
        }

        windowAnimator?.cancel()

        facingRight = true

        mascotView.setRunProgress(
            progress = 0f,
            isFacingRight = true
        )

        animationController
            .startRunning()

        val displayMetrics =
            applicationContext
                .resources
                .displayMetrics

        val destinationX =
            displayMetrics.widthPixels -
                layoutParams.width -
                dp(8)

        movementController.run(
            fromX = layoutParams.x,
            toX = destinationX,
            durationMillis = 2800L,
            onFinished =
                ::turnAndReturnToCenter
        )
    }

    private fun turnAndReturnToCenter() {
        if (!isAttached) {
            return
        }

        animationController.turn()

        mascotView.postDelayed(
            {
                if (!isAttached) {
                    return@postDelayed
                }

                facingRight = false

                mascotView.setRunProgress(
                    progress = 0f,
                    isFacingRight = false
                )

                animationController
                    .startRunning()

                val displayMetrics =
                    applicationContext
                        .resources
                        .displayMetrics

                val centerX =
                    (
                        displayMetrics.widthPixels -
                            layoutParams.width
                        ) / 2

                movementController.run(
                    fromX = layoutParams.x,
                    toX = centerX,
                    durationMillis = 2100L,
                    onFinished =
                        ::finishJourney
                )
            },
            300L
        )
    }

    private fun finishJourney() {
        if (!isAttached) {
            return
        }

        animationController
            .finishRunning()

        mascotView.postDelayed(
            {
                if (!isAttached) {
                    return@postDelayed
                }

                showQuestion()
            },
            500L
        )
    }

    private fun showQuestion() {
        animationController
            .showQuestion()

        val question =
            quizRepository.nextQuestion()

        quizWindowController.show(
            question = question,
            anchorCenterX =
                layoutParams.x +
                    layoutParams.width / 2,
            anchorTopY =
                layoutParams.y,
            anchorHeight =
                layoutParams.height
        )
    }

    private fun handleQuizAnswer(
        isCorrect: Boolean
    ) {
        animationController.answer(
            isCorrect
        )
    }

    private fun handleRunFrame(
        x: Int,
        progress: Float
    ) {
        if (!isAttached) {
            return
        }

        layoutParams.x = x

        mascotView.setRunProgress(
            progress = progress,
            isFacingRight = facingRight
        )

        updateLayout()
    }

    private fun handleMascotTap() {
        quizWindowController.hide()
        movementController.cancel()
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
        movementController.cancel()
        quizWindowController.hide()
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
                    -dp(45),
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
                duration =
                    durationMillis

                addUpdateListener {
                    animator ->

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
