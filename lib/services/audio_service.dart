import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();

  AudioService._internal();

  final AudioPlayer player = AudioPlayer();

  Future<void> playAudio(String fileName) async {
    await player.stop();
    await player.play(AssetSource('audio/$fileName'));
  }

  Future<void> stopAudio() async {
    await player.stop();
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  Future<void> dispose() async {
    await player.dispose();
  }
}
