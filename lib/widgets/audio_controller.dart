import 'package:just_audio/just_audio.dart';

class AudioController {
  static final AudioController _instance = AudioController._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();

  factory AudioController() {
    return _instance;
  }

  AudioController._internal();

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> play(String url) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }

    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
    }
  }
}
