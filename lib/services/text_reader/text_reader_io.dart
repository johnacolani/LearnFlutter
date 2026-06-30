import 'dart:io';

class TextReaderService {
  static Process? _process;

  static bool get isSupported =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static Future<void> configure() async {}

  static Future<int> speak(String text) async {
    await stop();
    if (text.trim().isEmpty || !isSupported) return 0;

    if (Platform.isWindows) return _speakWindows(text);
    if (Platform.isMacOS) return _speakMacOS(text);
    return _speakLinux(text);
  }

  static Future<void> stop() async {
    final process = _process;
    _process = null;
    process?.kill();
  }

  static Future<int> _speakWindows(String text) async {
    final scriptFile = await _windowsSpeechScript();
    _process = await Process.start(
      'powershell.exe',
      [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-WindowStyle',
        'Hidden',
        '-File',
        scriptFile.path,
        text,
      ],
      runInShell: false,
    );
    return _waitForSpeech();
  }

  static Future<File> _windowsSpeechScript() async {
    final file =
        File('${Directory.systemTemp.path}\\flutter_question_speak.ps1');
    if (!await file.exists()) {
      await file.writeAsString(r'''
param([string]$Text)
Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.Rate = -2
$synth.Volume = 100
$synth.Speak($Text)
$synth.Dispose()
''');
    }
    return file;
  }

  static Future<int> _speakMacOS(String text) async {
    _process = await Process.start('say', ['-r', '160', text]);
    return _waitForSpeech();
  }

  static Future<int> _speakLinux(String text) async {
    _process = await Process.start('spd-say', ['-r', '-25', text]);
    return _waitForSpeech();
  }

  static Future<int> _waitForSpeech() async {
    final process = _process;
    if (process == null) return 0;
    final exitCode = await process.exitCode;
    if (identical(_process, process)) _process = null;
    return exitCode == 0 ? 1 : 0;
  }
}
