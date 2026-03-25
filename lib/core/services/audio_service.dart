import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static const List<({String file, String label})> sounds = [
    (file: 'beep.wav', label: 'Beep'),
    (file: 'bell.wav', label: 'Bell'),
    (file: 'chime.wav', label: 'Chime'),
    (file: 'timer_complete.wav', label: 'Complete'),
    (file: 'bell_ringing.wav', label: 'Bell Ringing'),
  ];

  static String labelFor(String file) {
    return sounds
        .firstWhere((s) => s.file == file,
            orElse: () => (file: file, label: file))
        .label;
  }

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String soundFile, {double volume = 1.0}) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$soundFile'), volume: volume);
    } catch (e) {
      debugPrint('AudioService: failed to play $soundFile: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
