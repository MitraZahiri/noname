import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/services/mascot_overlay_platform_service.dart';

class MascotController extends ChangeNotifier {
  MascotController({required MascotOverlayPlatformService platformService})
    : _platformService = platformService;

  final MascotOverlayPlatformService _platformService;

  bool _isBusy = false;
  bool _hasOverlayPermission = false;
  String? _errorMessage;

  bool get isBusy => _isBusy;

  bool get hasOverlayPermission => _hasOverlayPermission;

  bool get isPlatformSupported => _platformService.isSupported;

  String? get errorMessage => _errorMessage;

  Future<void> refreshPermission() async {
    _setBusy(true);
    _errorMessage = null;

    try {
      _hasOverlayPermission = await _platformService.hasPermission();
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? error.code;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> requestOverlayPermission() async {
    _setBusy(true);
    _errorMessage = null;

    try {
      await _platformService.requestPermission();
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? error.code;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
