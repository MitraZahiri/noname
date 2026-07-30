import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/localization/locale_controller.dart';
import 'features/mascot/application/mascot_controller.dart';
import 'features/mascot/application/mascot_quiz_coordinator.dart';
import 'features/mascot/data/services/mascot_overlay_platform_service.dart';
import 'features/quiz/application/quiz_controller.dart';
import 'features/quiz/data/repositories/local_quiz_repository.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();

  final quizController = QuizController(repository: LocalQuizRepository());

  final platformService = MascotOverlayPlatformService();

  final mascotController = MascotController(platformService: platformService);

  final mascotQuizCoordinator = MascotQuizCoordinator(
    quizController: quizController,
    mascotController: mascotController,
    platformService: platformService,
  );

  mascotQuizCoordinator.initialize();

  runApp(
    NonameApp(
      localeController: localeController,
      mascotController: mascotController,
      quizController: quizController,
      mascotQuizCoordinator: mascotQuizCoordinator,
    ),
  );
}
