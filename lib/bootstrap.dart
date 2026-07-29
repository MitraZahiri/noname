import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/localization/locale_controller.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();

  runApp(
    NonameApp(
      localeController: localeController,
    ),
  );
}