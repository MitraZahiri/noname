import 'package:flutter/material.dart';
import 'package:noname/l10n/generated/app_localizations.dart';

import '../core/localization/locale_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/mascot/application/mascot_controller.dart';
import '../features/mascot/application/mascot_quiz_coordinator.dart';
import '../features/quiz/application/quiz_controller.dart';
import 'package:noname/features/companion/application/companion_controller.dart';

class NonameApp extends StatelessWidget {
  const NonameApp({
    required this.localeController,
    required this.mascotController,
    required this.quizController,
    required this.mascotQuizCoordinator,
    required this.companionController,
    super.key,
  });

  final LocaleController localeController;
  final MascotController mascotController;
  final QuizController quizController;
  final MascotQuizCoordinator mascotQuizCoordinator;
  final CompanionController companionController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) {
            return AppLocalizations.of(context)!.appName;
          },
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          locale: localeController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(
            localeController: localeController,
            mascotController: mascotController,
            quizController: quizController,
            mascotQuizCoordinator: mascotQuizCoordinator,
            companionController: companionController,
          ),
        );
      },
    );
  }
}
