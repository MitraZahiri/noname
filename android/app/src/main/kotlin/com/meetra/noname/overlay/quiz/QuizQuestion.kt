package com.meetra.noname.overlay.quiz

data class QuizQuestion(
    val id: String,
    val localeCode: String,
    val prompt: String,
    val options: List<String>,
    val correctIndex: Int,
    val explanation: String
) {

    init {
        require(options.size == 3) {
            "A quiz question must contain exactly three options."
        }

        require(correctIndex in options.indices) {
            "The correct answer index must point to an available option."
        }
    }

    companion object {

        fun fromPlatformMap(
            arguments: Any?
        ): QuizQuestion {
            val map =
                arguments as? Map<*, *>
                    ?: throw IllegalArgumentException(
                        "Question payload must be a map."
                    )

            val id =
                map["id"] as? String
                    ?: throw IllegalArgumentException(
                        "Question id is missing."
                    )

            val localeCode =
                map["localeCode"] as? String
                    ?: "en"

            val prompt =
                map["prompt"] as? String
                    ?: throw IllegalArgumentException(
                        "Question prompt is missing."
                    )

            val rawOptions =
                map["options"] as? List<*>
                    ?: throw IllegalArgumentException(
                        "Question options are missing."
                    )

            val options =
                rawOptions.map { option ->
                    option as? String
                        ?: throw IllegalArgumentException(
                            "Every option must be text."
                        )
                }

            val correctIndex =
                (map["correctIndex"] as? Number)
                    ?.toInt()
                    ?: throw IllegalArgumentException(
                        "Question correctIndex is missing."
                    )

            val explanation =
                map["explanation"] as? String
                    ?: ""

            return QuizQuestion(
                id = id,
                localeCode = localeCode,
                prompt = prompt,
                options = options,
                correctIndex = correctIndex,
                explanation = explanation
            )
        }
    }
}
