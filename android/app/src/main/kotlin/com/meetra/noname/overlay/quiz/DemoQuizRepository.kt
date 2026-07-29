package com.meetra.noname.overlay.quiz

import java.util.Locale

class DemoQuizRepository {

    fun nextQuestion(): QuizQuestion {
        return if (
            Locale.getDefault().language == "tr"
        ) {
            QuizQuestion(
                id = "solar_system_largest_planet_tr",
                prompt = "Güneş sistemindeki en büyük gezegen hangisidir?",
                options = listOf(
                    "Dünya",
                    "Jüpiter",
                    "Mars"
                ),
                correctIndex = 1
            )
        } else {
            QuizQuestion(
                id = "solar_system_largest_planet_en",
                prompt = "Which is the largest planet in the Solar System?",
                options = listOf(
                    "Earth",
                    "Jupiter",
                    "Mars"
                ),
                correctIndex = 1
            )
        }
    }
}
