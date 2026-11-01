import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();

  AudioService._internal();

  final AudioPlayer player = AudioPlayer();

  // Normal audio
  Future<void> playAudio(String fileName) async {
    await player.stop();
    await player.setReleaseMode(ReleaseMode.stop);
    await player.play(AssetSource('audio/$fileName'));
  }

  // Loop audio for cleaning
  Future<void> playLoop(String fileName) async {
    await player.stop();
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(AssetSource('audio/$fileName'));
  }

  Future<void> stopAudio() async {
    await player.stop();
    await player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }
}

