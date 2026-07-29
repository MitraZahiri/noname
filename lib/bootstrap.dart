import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/localization/locale_controller.dart';
import 'features/mascot/application/mascot_controller.dart';
import 'features/mascot/data/services/mascot_overlay_platform_service.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = LocaleController();

  final mascotController = MascotController(
    platformService: MascotOverlayPlatformService(),
  );

  runApp(
    NonameApp(
      localeController: localeController,
      mascotController: mascotController,
    ),
  );
}
