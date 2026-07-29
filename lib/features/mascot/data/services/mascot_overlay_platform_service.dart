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
}
