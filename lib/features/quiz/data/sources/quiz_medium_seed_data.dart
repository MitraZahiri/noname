import '../../domain/entities/quiz_category.dart';
import '../../domain/entities/quiz_difficulty.dart';
import '../../domain/entities/quiz_question.dart';

abstract final class QuizMediumSeedData {
  static final List<QuizQuestion> questions = <QuizQuestion>[
    ..._bilingualPair(
      id: 'largest_country_area',
      category: QuizCategory.geography,
      enPrompt: 'Which country has the largest land area?',
      enOptions: ['Canada', 'Russia', 'China'],
      enCorrectIndex: 1,
      enExplanation:
          'Russia is the largest country in the world by total area.',
      trPrompt: 'Yüz ölçümü bakımından dünyanın en büyük ülkesi hangisidir?',
      trOptions: ['Kanada', 'Rusya', 'Çin'],
      trCorrectIndex: 1,
      trExplanation:
          'Rusya, toplam yüz ölçümü bakımından dünyanın en büyük ülkesidir.',
    ),
    ..._bilingualPair(
      id: 'magna_carta_year',
      category: QuizCategory.history,
      enPrompt: 'In which year was Magna Carta sealed?',
      enOptions: ['1066', '1215', '1492'],
      enCorrectIndex: 1,
      enExplanation: 'Magna Carta was sealed in England in 1215.',
      trPrompt: 'Magna Carta hangi yıl imzalanmıştır?',
      trOptions: ['1066', '1215', '1492'],
      trCorrectIndex: 1,
      trExplanation: 'Magna Carta, İngiltere’de 1215 yılında imzalanmıştır.',
    ),
    ..._bilingualPair(
      id: 'chemical_symbol_na',
      category: QuizCategory.science,
      enPrompt: 'Which element has the chemical symbol Na?',
      enOptions: ['Nitrogen', 'Sodium', 'Neon'],
      enCorrectIndex: 1,
      enExplanation: 'Na is the chemical symbol for sodium.',
      trPrompt: 'Na kimyasal sembolü hangi elemente aittir?',
      trOptions: ['Azot', 'Sodyum', 'Neon'],
      trCorrectIndex: 1,
      trExplanation: 'Na, sodyum elementinin kimyasal sembolüdür.',
    ),
    ..._bilingualPair(
      id: 'true_flight_mammal',
      category: QuizCategory.animals,
      enPrompt: 'Which mammal is capable of true sustained flight?',
      enOptions: ['Flying squirrel', 'Bat', 'Sugar glider'],
      enCorrectIndex: 1,
      enExplanation:
          'Bats are the only mammals capable of true sustained flight.',
      trPrompt: 'Gerçek ve sürekli uçuş yapabilen memeli hangisidir?',
      trOptions: ['Uçan sincap', 'Yarasa', 'Şeker planörü'],
      trCorrectIndex: 1,
      trExplanation:
          'Yarasalar, gerçek ve sürekli uçuş yapabilen tek memeli grubudur.',
    ),
    ..._bilingualPair(
      id: 'the_scream_artist',
      category: QuizCategory.culture,
      enPrompt: 'Who painted The Scream?',
      enOptions: ['Claude Monet', 'Edvard Munch', 'Salvador Dalí'],
      enCorrectIndex: 1,
      enExplanation: 'The Scream was created by Norwegian artist Edvard Munch.',
      trPrompt: 'Çığlık adlı eseri hangi ressam yapmıştır?',
      trOptions: ['Claude Monet', 'Edvard Munch', 'Salvador Dalí'],
      trCorrectIndex: 1,
      trExplanation:
          'Çığlık adlı eser Norveçli ressam Edvard Munch tarafından yapılmıştır.',
    ),
    ..._bilingualPair(
      id: 'http_meaning',
      category: QuizCategory.technology,
      enPrompt: 'What does HTTP stand for?',
      enOptions: [
        'Hypertext Transfer Protocol',
        'High Transfer Text Program',
        'Hyperlink Transmission Process',
      ],
      enCorrectIndex: 0,
      enExplanation: 'HTTP stands for Hypertext Transfer Protocol.',
      trPrompt: 'HTTP kısaltmasının açılımı nedir?',
      trOptions: [
        'Hypertext Transfer Protocol',
        'High Transfer Text Program',
        'Hyperlink Transmission Process',
      ],
      trCorrectIndex: 0,
      trExplanation:
          'HTTP, Hypertext Transfer Protocol ifadesinin kısaltmasıdır.',
    ),
  ];
}

List<QuizQuestion> _bilingualPair({
  required String id,
  required QuizCategory category,
  required String enPrompt,
  required List<String> enOptions,
  required int enCorrectIndex,
  required String enExplanation,
  required String trPrompt,
  required List<String> trOptions,
  required int trCorrectIndex,
  required String trExplanation,
}) {
  return <QuizQuestion>[
    QuizQuestion(
      id: '${id}_medium_en',
      localeCode: 'en',
      prompt: enPrompt,
      options: enOptions,
      correctIndex: enCorrectIndex,
      category: category,
      difficulty: QuizDifficulty.medium,
      explanation: enExplanation,
    ),
    QuizQuestion(
      id: '${id}_medium_tr',
      localeCode: 'tr',
      prompt: trPrompt,
      options: trOptions,
      correctIndex: trCorrectIndex,
      category: category,
      difficulty: QuizDifficulty.medium,
      explanation: trExplanation,
    ),
  ];
}
