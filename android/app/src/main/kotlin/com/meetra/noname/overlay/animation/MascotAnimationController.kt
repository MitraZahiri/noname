package com.meetra.noname.overlay.animation

import android.os.Handler
import android.os.Looper

class MascotAnimationController(
    private val onStateChanged: (
        MascotAnimationState
    ) -> Unit,
    private val onClimbRequested: () -> Unit
) {

    private val handler = Handler(
        Looper.getMainLooper()
    )

    private val scheduledActions =
        mutableListOf<Runnable>()

    fun startEntrance() {
        cancel()

        changeState(
            MascotAnimationState.PEEKING
        )

        schedule(
            delayMillis = 650L
        ) {
            changeState(
                MascotAnimationState.LOOKING_LEFT
            )
        }

        schedule(
            delayMillis = 1250L
        ) {
            changeState(
                MascotAnimationState.LOOKING_RIGHT
            )
        }

        schedule(
            delayMillis = 1850L
        ) {
            changeState(
                MascotAnimationState.CLIMBING
            )

            onClimbRequested()
        }

        schedule(
            delayMillis = 2850L
        ) {
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

        schedule(
            delayMillis = 500L
        ) {
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
        scheduledActions.forEach { action ->
            handler.removeCallbacks(action)
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
        val runnable = Runnable {
            action()
        }

        scheduledActions.add(runnable)

        handler.postDelayed(
            runnable,
            delayMillis
        )
    }
}
