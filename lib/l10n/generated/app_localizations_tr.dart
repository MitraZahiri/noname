// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'NoName';

  @override
  String get homeTitle => 'Ekranının artık yeni bir sakini var';

  @override
  String get homeSubtitle => 'Maskotun diğer uygulamaları kullanırken ortaya çıkar ve kısa bilgi soruları getirir.';

  @override
  String get mascotStatus => 'Maskot durumu';

  @override
  String get mascotStopped => 'Durduruldu';

  @override
  String get mascotRunning => 'Çalışıyor';

  @override
  String get startMascot => 'Maskotu başlat';

  @override
  String get stopMascot => 'Maskotu durdur';

  @override
  String get showMascotNow => 'Şimdi göster';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get developmentNotice => 'Ekran üstü karakter bağlantısı sonraki geliştirme adımında eklenecek.';
}
