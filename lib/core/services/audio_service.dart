import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static const List<({String file, String label})> sounds = [
    (file: 'beep.wav', label: 'Beep'),
    (file: 'bell.wav', label: 'Bell'),
    (file: 'chime.wav', label: 'Chime'),
  ];

  static String labelFor(String file) {
    return sounds
        .firstWhere((s) => s.file == file,
            orElse: () => (file: file, label: file))
        .label;
  }

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String soundFile) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$soundFile'));
    } catch (e) {
      debugPrint('AudioService: failed to play $soundFile: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
