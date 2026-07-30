import 'package:flutter/material.dart';
import 'package:noname/core/localization/locale_controller.dart';
import 'package:noname/features/mascot/application/mascot_controller.dart';
import 'package:noname/l10n/generated/app_localizations.dart';
import 'package:noname/features/quiz/application/quiz_controller.dart';
import 'package:noname/features/mascot/application/mascot_quiz_coordinator.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.localeController,
    required this.mascotController,
    required this.quizController,
    required this.mascotQuizCoordinator,
    super.key,
  });

  final LocaleController localeController;
  final MascotController mascotController;
  final QuizController quizController;
  final MascotQuizCoordinator mascotQuizCoordinator;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.mascotController.refreshState();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.mascotController.refreshState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.appName)),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.mascotController,
          builder: (context, _) {
            final controller = widget.mascotController;
            final permissionGranted = controller.hasOverlayPermission;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  localizations.homeTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.homeSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                _PermissionCard(
                  isBusy: controller.isBusy,
                  isGranted: permissionGranted,
                  title: localizations.overlayPermissionTitle,
                  grantedText: localizations.overlayPermissionGranted,
                  requiredText: localizations.overlayPermissionRequired,
                  description: localizations.overlayPermissionDescription,
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed:
                      controller.isBusy
                          ? null
                          : !permissionGranted
                          ? () {
                            _requestOverlayPermission(context);
                          }
                          : controller.isRunning
                          ? () async {
                            await controller.stopMascot();
                          }
                          : () async {
                            final localeCode =
                                Localizations.localeOf(context).languageCode;

                            await widget.mascotQuizCoordinator.startMascot(
                              localeCode: localeCode,
                            );
                          },
                  icon: Icon(
                    !permissionGranted
                        ? Icons.security_rounded
                        : controller.isRunning
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    !permissionGranted
                        ? localizations.grantOverlayPermission
                        : controller.isRunning
                        ? localizations.stopMascot
                        : localizations.startMascot,
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed:
                      permissionGranted &&
                              controller.isRunning &&
                              !controller.isBusy
                          ? () async {
                            await controller.showMascotNow();
                          }
                          : null,
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(localizations.showMascotNow),
                ),

                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage!,
                    style: TextStyle(color: colors.error),
                  ),
                ],

                const SizedBox(height: 32),

                Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<AppLocalePreference>(
                  value: widget.localeController.preference,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: AppLocalePreference.system,
                      child: Text(localizations.languageSystem),
                    ),
                    DropdownMenuItem(
                      value: AppLocalePreference.english,
                      child: Text(localizations.languageEnglish),
                    ),
                    DropdownMenuItem(
                      value: AppLocalePreference.turkish,
                      child: Text(localizations.languageTurkish),
                    ),
                  ],
                  onChanged: (preference) {
                    if (preference != null) {
                      widget.localeController.changeLocale(preference);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _requestOverlayPermission(BuildContext context) async {
    await widget.mascotController.requestOverlayPermission();

    if (!context.mounted) {
      return;
    }

    if (widget.mascotController.errorMessage != null) {
      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(localizations.permissionError)));
    }
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.isBusy,
    required this.isGranted,
    required this.title,
    required this.grantedText,
    required this.requiredText,
    required this.description,
  });

  final bool isBusy;
  final bool isGranted;
  final String title;
  final String grantedText;
  final String requiredText;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor:
                  isGranted ? colors.primaryContainer : colors.errorContainer,
              child:
                  isBusy
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Icon(
                        isGranted
                            ? Icons.check_rounded
                            : Icons.warning_amber_rounded,
                        color:
                            isGranted
                                ? colors.onPrimaryContainer
                                : colors.onErrorContainer,
                      ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    isGranted ? grantedText : requiredText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
