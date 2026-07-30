package com.meetra.noname.overlay

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.PixelFormat
import android.view.Gravity
import android.view.WindowManager
import com.meetra.noname.overlay.animation.MascotAnimationController
import com.meetra.noname.overlay.animation.MascotAnimationState
import com.meetra.noname.overlay.animation.MascotMovementController
import com.meetra.noname.overlay.quiz.ContinueQuizOverlayWindowController
import com.meetra.noname.overlay.quiz.QuizOverlayWindowController
import com.meetra.noname.overlay.quiz.QuizQuestion
import kotlin.math.roundToInt

class OverlayWindowController(
    context: Context,
    private val onQuizAnswered: (
        questionId: String,
        selectedIndex: Int,
        isCorrect: Boolean
    ) -> Unit,
    private val onNextQuestionRequested:
        () -> Unit,
    private val onDismissRequested:
        () -> Unit
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

    private val quizWindowController:
        QuizOverlayWindowController

    private val continueWindowController:
        ContinueQuizOverlayWindowController

    private val layoutParams:
        WindowManager.LayoutParams

    private var activeQuestion:
        QuizQuestion? = null

    private var isAttached =
        false

    private var awaitingDecision =
        false

    private var waitingForNextQuestion =
        false

    private var windowAnimator:
        ValueAnimator? = null

    private var facingRight =
        true

    init {
        mascotView =
            MascotOverlayView(
                context =
                    applicationContext,
                onDrag = ::moveBy,
                onTap =
                    ::handleMascotTap
            )

        movementController =
            MascotMovementController(
                onFrame =
                    ::handleRunFrame
            )

        quizWindowController =
            QuizOverlayWindowController(
                context =
                    applicationContext,
                onAnswered =
                    ::handleQuizAnswer
            )

        continueWindowController =
            ContinueQuizOverlayWindowController(
                context =
                    applicationContext,
                onYesSelected =
                    ::handleContinueYes,
                onNoSelected =
                    ::handleContinueNo
            )

        animationController =
            MascotAnimationController(
                onStateChanged =
                    mascotView::
                        setAnimationState,
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
                    Gravity.TOP or
                        Gravity.START
            }
    }

    fun setQuestion(
        question: QuizQuestion
    ) {
        activeQuestion = question

        if (
            waitingForNextQuestion &&
            isAttached
        ) {
            waitingForNextQuestion = false

            continueWindowController.hide()

            mascotView.postDelayed(
                {
                    if (isAttached) {
                        showQuestion()
                    }
                },
                180L
            )
        }
    }

    fun show() {
        if (isAttached) {
            windowAnimator?.cancel()
            movementController.cancel()

            if (awaitingDecision) {
                showContinueQuestion()
            } else {
                showQuestion()
            }

            return
        }

        val hiddenX =
            -dp(124)

        val peekX =
            -dp(80)

        layoutParams.x =
            hiddenX

        layoutParams.y = (
            applicationContext
                .resources
                .displayMetrics
                .heightPixels * 0.52f
            ).roundToInt()

        windowManager.addView(
            mascotView,
            layoutParams
        )

        isAttached = true
        facingRight = true
        awaitingDecision = false
        waitingForNextQuestion = false

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
        quizWindowController.hide()
        continueWindowController.hide()

        awaitingDecision = false
        waitingForNextQuestion = false

        animationController.hide()

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

        val screenWidth =
            applicationContext
                .resources
                .displayMetrics
                .widthPixels

        val destinationX =
            screenWidth -
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

                val screenWidth =
                    applicationContext
                        .resources
                        .displayMetrics
                        .widthPixels

                val centerX =
                    (
                        screenWidth -
                            layoutParams.width
                        ) / 2

                movementController.run(
                    fromX =
                        layoutParams.x,
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
                if (isAttached) {
                    showQuestion()
                }
            },
            450L
        )
    }

    private fun showQuestion() {
        if (!isAttached) {
            return
        }

        val question =
            activeQuestion ?: run {
                animationController
                    .showIdle()

                return
            }

        awaitingDecision = false

        continueWindowController.hide()

        animationController
            .showQuestion()

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
        questionId: String,
        selectedIndex: Int,
        isCorrect: Boolean
    ) {
        awaitingDecision = true
        waitingForNextQuestion = false

        animationController.answer(
            isCorrect
        )

        onQuizAnswered(
            questionId,
            selectedIndex,
            isCorrect
        )

        mascotView.postDelayed(
            {
                if (
                    isAttached &&
                    awaitingDecision
                ) {
                    showContinueQuestion()
                }
            },
            320L
        )
    }

    private fun showContinueQuestion() {
        if (!isAttached) {
            return
        }

        val question =
            activeQuestion ?: return

        animationController
            .showIdle()

        continueWindowController.show(
            localeCode =
                question.localeCode,
            anchorCenterX =
                layoutParams.x +
                    layoutParams.width / 2,
            anchorTopY =
                layoutParams.y,
            anchorHeight =
                layoutParams.height
        )
    }

    private fun handleContinueYes() {
        if (!awaitingDecision) {
            return
        }

        awaitingDecision = false
        waitingForNextQuestion = true

        continueWindowController.hide()

        animationController.react()

        onNextQuestionRequested()

        mascotView.postDelayed(
            {
                if (
                    isAttached &&
                    waitingForNextQuestion
                ) {
                    waitingForNextQuestion =
                        false

                    awaitingDecision = true

                    showContinueQuestion()
                }
            },
            2500L
        )
    }

    private fun handleContinueNo() {
        awaitingDecision = false
        waitingForNextQuestion = false

        quizWindowController.hide()
        continueWindowController.hide()
        movementController.cancel()
        windowAnimator?.cancel()

        mascotView
            .animate()
            .cancel()

        mascotView.animate()
            .alpha(0f)
            .scaleX(0.05f)
            .scaleY(0.05f)
            .rotation(180f)
            .translationY(
                -dp(45).toFloat()
            )
            .setDuration(460L)
            .withEndAction {
                onDismissRequested()
            }
            .start()
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
            isFacingRight =
                facingRight
        )

        updateLayout()
    }

    private fun handleMascotTap() {
        windowAnimator?.cancel()
        movementController.cancel()
        quizWindowController.hide()

        when {
            waitingForNextQuestion -> {
                return
            }

            awaitingDecision -> {
                showContinueQuestion()
            }

            else -> {
                showQuestion()
            }
        }
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
        continueWindowController.hide()

        animationController
            .showIdle()

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
                        animator
                            .animatedValue
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
            windowManager
                .updateViewLayout(
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
