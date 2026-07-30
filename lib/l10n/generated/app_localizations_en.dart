// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NoName';

  @override
  String get homeTitle => 'Your screen has a new inhabitant';

  @override
  String get homeSubtitle =>
      'Your mascot appears while you use other applications and brings quick knowledge challenges.';

  @override
  String get mascotStatus => 'Mascot status';

  @override
  String get mascotStopped => 'Stopped';

  @override
  String get mascotRunning => 'Running';

  @override
  String get startMascot => 'Start mascot';

  @override
  String get stopMascot => 'Stop mascot';

  @override
  String get showMascotNow => 'Show now';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get developmentNotice =>
      'The screen overlay connection will be added in the next development step.';

  @override
  String get overlayPermissionTitle => 'Display over other apps';

  @override
  String get overlayPermissionGranted => 'Permission granted';

  @override
  String get overlayPermissionRequired => 'Permission required';

  @override
  String get overlayPermissionDescription =>
      'Allow NoName to appear over other applications.';

  @override
  String get grantOverlayPermission => 'Grant overlay permission';

  @override
  String get permissionError =>
      'The permission operation could not be completed.';
}
