import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowTransparencyService {
  static bool get isSupported =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static Future<void> initialize() async {
    if (!isSupported) return;
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        title: 'Flutter Interview Prep',
        backgroundColor: Color(0xFF0F1117),
        titleBarStyle: TitleBarStyle.normal,
        size: Size(1120, 780),
        minimumSize: Size(360, 520),
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  static Future<void> setStickerMode({
    required bool enabled,
    required double opacity,
    bool hideTitleBar = false,
    bool clickThrough = false,
  }) async {
    if (!isSupported) return;
    await windowManager.setOpacity(enabled ? opacity : 1.0);
    await windowManager.setAlwaysOnTop(enabled);
    await setTitleBarHidden(enabled && hideTitleBar);
    await setClickThrough(enabled && clickThrough);
  }

  static Future<void> setOpacity(double opacity) async {
    if (!isSupported) return;
    await windowManager.setOpacity(opacity);
  }

  static Future<void> setAlwaysOnTop(bool enabled) async {
    if (!isSupported) return;
    await windowManager.setAlwaysOnTop(enabled);
  }

  static Future<void> setTitleBarHidden(bool hidden) async {
    if (!isSupported) return;
    if (Platform.isWindows) {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      return;
    }
    await windowManager
        .setTitleBarStyle(hidden ? TitleBarStyle.hidden : TitleBarStyle.normal);
  }

  static Future<void> setClickThrough(bool enabled) async {
    if (!isSupported) return;
    // Allows the app to behave like a visual sticker overlay. Moving the mouse
    // over the window can pass events to the app behind it on supported desktop platforms.
    await windowManager.setIgnoreMouseEvents(enabled, forward: true);
  }
}
