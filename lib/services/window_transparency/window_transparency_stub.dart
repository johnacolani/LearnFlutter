class WindowTransparencyService {
  static bool get isSupported => false;

  static Future<void> initialize() async {}

  static Future<void> setStickerMode({
    required bool enabled,
    required double opacity,
    bool hideTitleBar = false,
    bool clickThrough = false,
  }) async {}

  static Future<void> setOpacity(double opacity) async {}
  static Future<void> setAlwaysOnTop(bool enabled) async {}
  static Future<void> setTitleBarHidden(bool hidden) async {}
  static Future<void> setClickThrough(bool enabled) async {}
}
