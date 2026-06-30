class TextReaderService {
  static bool get isSupported => false;

  static Future<void> configure() async {}

  static Future<int> speak(String text) async => 0;

  static Future<void> stop() async {}
}
