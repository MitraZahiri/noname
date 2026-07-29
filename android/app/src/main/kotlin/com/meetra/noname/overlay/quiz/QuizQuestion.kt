package com.meetra.noname.overlay.quiz

data class QuizQuestion(
    val id: String,
    val prompt: String,
    val options: List<String>,
    val correctIndex: Int
) {
    init {
        require(options.size == 3) {
            "A quiz question must contain exactly three options."
        }

        require(correctIndex in options.indices) {
            "The correct answer index must point to an available option."
        }
    }
}
