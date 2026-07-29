import 'package:flutter/material.dart';

enum AppLocalePreference {
  system,
  english,
  turkish,
}

class LocaleController extends ChangeNotifier {
  AppLocalePreference _preference = AppLocalePreference.system;

  AppLocalePreference get preference => _preference;

  Locale? get locale {
    switch (_preference) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.english:
        return const Locale('en');
      case AppLocalePreference.turkish:
        return const Locale('tr');
    }
  }

  void changeLocale(AppLocalePreference preference) {
    if (_preference == preference) {
      return;
    }

    _preference = preference;
    notifyListeners();
  }
}