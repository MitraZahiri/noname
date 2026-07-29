import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/services/mascot_overlay_platform_service.dart';

class MascotController extends ChangeNotifier {
  MascotController({required MascotOverlayPlatformService platformService})
    : _platformService = platformService;

  final MascotOverlayPlatformService _platformService;

  bool _isBusy = false;
  bool _hasOverlayPermission = false;
  bool _isRunning = false;
  String? _errorMessage;

  bool get isBusy => _isBusy;

  bool get hasOverlayPermission => _hasOverlayPermission;

  bool get isRunning => _isRunning;

  bool get isPlatformSupported => _platformService.isSupported;

  String? get errorMessage => _errorMessage;

  Future<void> refreshState() async {
    await _execute(() async {
      _hasOverlayPermission = await _platformService.hasPermission();

      _isRunning = await _platformService.isMascotRunning();
    });
  }

  Future<void> requestOverlayPermission() async {
    await _execute(() async {
      await _platformService.requestPermission();
    });
  }

  Future<void> startMascot() async {
    await _execute(() async {
      if (!_hasOverlayPermission) {
        return;
      }

      _isRunning = await _platformService.startMascot();
    });
  }

  Future<void> stopMascot() async {
    await _execute(() async {
      await _platformService.stopMascot();
      _isRunning = false;
    });
  }

  Future<void> showMascotNow() async {
    await _execute(() async {
      _isRunning = await _platformService.showMascot();
    });
  }

  Future<void> _execute(Future<void> Function() operation) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await operation();
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? error.code;
    } on MissingPluginException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
