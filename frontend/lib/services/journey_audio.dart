import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// The few playback operations a journey needs; tests provide a fake.
abstract class JourneyAudio {
  Stream<void> get completed;
  bool get playing;
  Object? get item;
  Future<void> playUrl(String url);
  Future<void> playFile(String path, {String? mimeType});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seekBy(Duration delta);
  Future<void> setRate(double rate);
  Future<void> dispose();
}

class AudioPlayersJourneyAudio implements JourneyAudio {
  AudioPlayersJourneyAudio() {
    _subscription = _player.onPlayerComplete.listen((_) {
      _playing = false;
      _completed.add(null);
    });
  }

  final _player = AudioPlayer();
  final _completed = StreamController<void>.broadcast();
  late final StreamSubscription<void> _subscription;
  bool _playing = false;
  double _rate = 1.0;

  @override
  Stream<void> get completed => _completed.stream;
  @override
  bool get playing => _playing;
  @override
  Object? get item => _player.source;

  Future<void> _start(Source source) async {
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setPlaybackRate(_rate);
    await _player.play(source);
    _playing = true;
  }

  @override
  Future<void> playUrl(String url) => _start(UrlSource(url));
  @override
  Future<void> playFile(String path, {String? mimeType}) =>
      _start(DeviceFileSource(path, mimeType: mimeType));
  @override
  Future<void> pause() async {
    await _player.pause();
    _playing = false;
  }

  @override
  Future<void> resume() async {
    await _player.resume();
    _playing = true;
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _playing = false;
  }

  @override
  Future<void> seekBy(Duration delta) async {
    final position = await _player.getCurrentPosition() ?? Duration.zero;
    final duration = await _player.getDuration();
    var target = position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (duration != null && target > duration) target = duration;
    await _player.seek(target);
  }

  @override
  Future<void> setRate(double rate) async {
    _rate = rate;
    await _player.setPlaybackRate(rate);
  }

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _completed.close();
    await _player.dispose();
  }
}
