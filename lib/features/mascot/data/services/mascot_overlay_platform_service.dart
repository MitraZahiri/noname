import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MascotOverlayPlatformService {
  static const MethodChannel _channel = MethodChannel('noname/overlay');

  bool get isSupported {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  Future<bool> hasPermission() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
  }

  Future<void> requestPermission() async {
    if (!isSupported) {
      return;
    }

    await _channel.invokeMethod<void>('requestOverlayPermission');
  }

  Future<bool> startMascot() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('startMascotOverlay') ?? false;
  }

  Future<bool> stopMascot() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('stopMascotOverlay') ?? false;
  }

  Future<bool> showMascot() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('showMascotOverlay') ?? false;
  }

  Future<bool> isMascotRunning() async {
    if (!isSupported) {
      return false;
    }

    return await _channel.invokeMethod<bool>('isMascotOverlayRunning') ?? false;
  }
}
