package com.meetra.noname.overlay.animation

import android.os.Handler
import android.os.Looper

class MascotAnimationController(
    private val onStateChanged: (
        MascotAnimationState
    ) -> Unit,
    private val onClimbRequested: () -> Unit,
    private val onRunRequested: () -> Unit
) {

    private val handler =
        Handler(
            Looper.getMainLooper()
        )

    private val scheduledActions =
        mutableListOf<Runnable>()

    fun startEntrance() {
        cancel()

        changeState(
            MascotAnimationState.PEEKING
        )

        schedule(650L) {
            changeState(
                MascotAnimationState
                    .LOOKING_LEFT
            )
        }

        schedule(1250L) {
            changeState(
                MascotAnimationState
                    .LOOKING_RIGHT
            )
        }

        schedule(1850L) {
            changeState(
                MascotAnimationState.CLIMBING
            )

            onClimbRequested()
        }

        schedule(2850L) {
            changeState(
                MascotAnimationState.STANDING
            )
        }

        schedule(3350L) {
            startRunning()
            onRunRequested()
        }
    }

    fun startRunning() {
        changeState(
            MascotAnimationState.RUNNING
        )
    }

    fun turn() {
        changeState(
            MascotAnimationState.TURNING
        )
    }

    fun finishRunning() {
        changeState(
            MascotAnimationState.IDLE
        )
    }

    fun showQuestion() {
        cancel()

        changeState(
            MascotAnimationState.ASKING
        )
    }

    fun answer(
        isCorrect: Boolean
    ) {
        cancel()

        changeState(
            if (isCorrect) {
                MascotAnimationState
                    .ANSWER_CORRECT
            } else {
                MascotAnimationState
                    .ANSWER_WRONG
            }
        )

        schedule(1100L) {
            changeState(
                MascotAnimationState.IDLE
            )
        }
    }

    fun react() {
        cancel()

        changeState(
            MascotAnimationState.REACTING
        )

        schedule(500L) {
            changeState(
                MascotAnimationState.IDLE
            )
        }
    }

    fun showIdle() {
        cancel()

        changeState(
            MascotAnimationState.IDLE
        )
    }

    fun hide() {
        cancel()

        changeState(
            MascotAnimationState.HIDDEN
        )
    }

    fun cancel() {
        scheduledActions
            .forEach { action ->
                handler.removeCallbacks(
                    action
                )
            }

        scheduledActions.clear()
    }

    private fun changeState(
        state: MascotAnimationState
    ) {
        onStateChanged(state)
    }

    private fun schedule(
        delayMillis: Long,
        action: () -> Unit
    ) {
        lateinit var runnable:
            Runnable

        runnable = Runnable {
            scheduledActions.remove(
                runnable
            )

            action()
        }

        scheduledActions.add(
            runnable
        )

        handler.postDelayed(
            runnable,
            delayMillis
        )
    }
}
