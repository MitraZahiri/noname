import 'package:flutter/material.dart';
import 'package:noname/core/localization/locale_controller.dart';
import 'package:noname/l10n/generated/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.localeController,
    super.key,
  });

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appName),
      ),
      body: SafeArea(
        child: ListView(
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colors.secondaryContainer,
                      child: Icon(
                        Icons.sentiment_very_satisfied_rounded,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.mascotStatus,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.mascotStopped,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                _showDevelopmentMessage(context);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(localizations.startMascot),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _showDevelopmentMessage(context);
              },
              icon: const Icon(Icons.visibility_rounded),
              label: Text(localizations.showMascotNow),
            ),
            const SizedBox(height: 32),
            Text(
              localizations.language,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppLocalePreference>(
              value: localeController.preference,
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
                  localeController.changeLocale(preference);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDevelopmentMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(localizations.developmentNotice),
        ),
      );
  }
}