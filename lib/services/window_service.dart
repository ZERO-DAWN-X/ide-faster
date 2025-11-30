import 'package:flutter/services.dart';

class WindowService {
  static const MethodChannel _channel = MethodChannel('nxive_ide_optimizer/window');

  static Future<void> minimize() async {
    try {
      await _channel.invokeMethod('minimize');
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> maximize() async {
    try {
      await _channel.invokeMethod('maximize');
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> close() async {
    try {
      await _channel.invokeMethod('close');
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> startDrag() async {
    try {
      await _channel.invokeMethod('startDrag');
    } catch (e) {
      // Handle error silently
    }
  }
}

