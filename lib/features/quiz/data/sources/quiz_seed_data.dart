import '../../domain/entities/quiz_category.dart';
import '../../domain/entities/quiz_difficulty.dart';
import '../../domain/entities/quiz_question.dart';

abstract final class QuizSeedData {
  static final List<QuizQuestion> questions = <QuizQuestion>[
    QuizQuestion(
      id: 'largest_planet_en',
      localeCode: 'en',
      prompt: 'Which is the largest planet in the Solar System?',
      options: ['Earth', 'Jupiter', 'Mars'],
      correctIndex: 1,
      category: QuizCategory.science,
      difficulty: QuizDifficulty.easy,
      explanation: 'Jupiter is the largest planet in the Solar System.',
    ),
    QuizQuestion(
      id: 'largest_planet_tr',
      localeCode: 'tr',
      prompt: 'Güneş sistemindeki en büyük gezegen hangisidir?',
      options: ['Dünya', 'Jüpiter', 'Mars'],
      correctIndex: 1,
      category: QuizCategory.science,
      difficulty: QuizDifficulty.easy,
      explanation: 'Jüpiter, Güneş sistemindeki en büyük gezegendir.',
    ),
    QuizQuestion(
      id: 'capital_australia_en',
      localeCode: 'en',
      prompt: 'What is the capital of Australia?',
      options: ['Sydney', 'Canberra', 'Melbourne'],
      correctIndex: 1,
      category: QuizCategory.geography,
      difficulty: QuizDifficulty.easy,
      explanation: 'Canberra is the capital of Australia.',
    ),
    QuizQuestion(
      id: 'capital_australia_tr',
      localeCode: 'tr',
      prompt: 'Avustralya’nın başkenti hangisidir?',
      options: ['Sidney', 'Canberra', 'Melbourne'],
      correctIndex: 1,
      category: QuizCategory.geography,
      difficulty: QuizDifficulty.easy,
      explanation: 'Avustralya’nın başkenti Canberra’dır.',
    ),
    QuizQuestion(
      id: 'largest_animal_en',
      localeCode: 'en',
      prompt: 'What is the largest animal alive today?',
      options: ['African elephant', 'Blue whale', 'Giraffe'],
      correctIndex: 1,
      category: QuizCategory.animals,
      difficulty: QuizDifficulty.easy,
      explanation: 'The blue whale is the largest known living animal.',
    ),
    QuizQuestion(
      id: 'largest_animal_tr',
      localeCode: 'tr',
      prompt: 'Günümüzde yaşayan en büyük hayvan hangisidir?',
      options: ['Afrika fili', 'Mavi balina', 'Zürafa'],
      correctIndex: 1,
      category: QuizCategory.animals,
      difficulty: QuizDifficulty.easy,
      explanation: 'Mavi balina, bilinen en büyük yaşayan hayvandır.',
    ),
  ];
}
