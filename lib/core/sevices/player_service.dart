import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';

enum PlayerStatus { stop, play, pause, error }

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() {
    return _instance;
  }

  AudioPlayerService._internal() {
    _setupPlayerListeners();
  }

  Function(int)? _onIndexChanged;

  void setOnIndexChanged(Function(int) callback) {
    _onIndexChanged = callback;
  }

  void _setupPlayerListeners() {
    _player.playerStateStream.listen((state) {
      print('PlayerState: ${state.playing}, ${state.processingState}');
    });

    _player.durationStream.listen((duration) {
      _lastDuration = duration;
    });

    // Слушаем изменение текущего индекса (автопереключение)
    _player.currentIndexStream.listen((int? index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        print('Track automatically changed to index: $index');
        // Уведомляем только если есть колбэк
        _onIndexChanged?.call(index);
      }
    });

    _player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.idle &&
          _player.playbackEvent.errorMessage != null) {
        print('Player error: ${_player.playbackEvent.errorMessage}');
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  List<AudioMetadataEntity> _playlist = [];
  int _currentIndex = 0;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  int? get current => _player.currentIndex;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  Duration? get currentDuration => _lastDuration;

  Duration? _lastDuration;

  Future<void> setupAudioSession() async {
    try {
      final session = await AudioSession.instance;

      await session.configure(AudioSessionConfiguration.music());
    } catch (e) {
      print('Audio session setup error: $e');
    }
  }

  Future<void> shuffle(bool value) async {
    try {
      await _player.setShuffleModeEnabled(value);
    } catch (e) {
      print('Audio session setup error: $e');
    }
  }

  // Новый метод для установки плейлиста
  Future<void> setPlaylist(
    List<AudioMetadataEntity> playlist, {
    int startIndex = 0,
  }) async {
    _playlist = playlist;
    _currentIndex = startIndex;

    if (playlist.isNotEmpty) {
      final audioSources = playlist
          .map((audio) => _createAudioSource(audio))
          .toList();

      await _player.setAudioSources(audioSources, initialIndex: startIndex);
    }
  }

  AudioSource _createAudioSource(AudioMetadataEntity audio) {
    final mediaItem = MediaItem(
      id: audio.id,
      title: audio.title,
      artist: audio.artist ?? 'Unknown Artist',
      album: audio.album ?? 'Unknown Album',
      artUri:  null,

      //Vremenno
     // artUri: audio.artUri != null ? Uri.parse(audio.artUri!) : null,
      duration: Duration.zero,
    );

    if (audio.assetPath.startsWith('http')) {
      return AudioSource.uri(Uri.parse(audio.assetPath), tag: mediaItem);
    } else if (File(audio.assetPath).existsSync()) {
      return AudioSource.uri(Uri.file(audio.assetPath), tag: mediaItem);
    } else {
      return AudioSource.asset(audio.assetPath, tag: mediaItem);
    }
  }

  Future<bool> playAudio(int audio, List<AudioMetadataEntity> sources) async {
    try {
      await Future.wait([
        _player.setAudioSources(
          sources.map((e) => _createAudioSource(e)).toList(),
          initialIndex: audio,
        ),
        setupAudioSession(),
        _player.play(),
      ]);

      return true;
    } catch (e) {
      print('Play audio error: $e');
      rethrow;
    }
  }

  Future<bool> reloadLastAudio(
    int audio,
    List<AudioMetadataEntity> sources,
    int? position,
  ) async {
    try {
      await Future.wait([
        _player.setAudioSources(
          sources.map((e) => _createAudioSource(e)).toList(),
          initialIndex: audio,
          initialPosition: Duration(seconds: position??0)
        ),
        setupAudioSession(),
         _player.play(),
      ]);

      return true;
    } catch (e) {
      print('Play audio error: $e');
      rethrow;
    }
  }

  // Методы для навигации по плейлисту
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    }
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await playAtIndex(_currentIndex);
    } else {
      // Достигнут конец плейлиста
      await stop();
    }
  }

  Future<void> seekToNext() async => await _player.seekToNext();

  Future<void> seekToPrev() async => await _player.seekToPrevious();

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    final currentPosition = _player.position;

    // Если трек играет больше 3 секунд, перезапускаем текущий
    if (currentPosition > Duration(seconds: 3)) {
      await seek(Duration.zero);
    } else if (_currentIndex > 0) {
      // Иначе переходим к предыдущему треку
      _currentIndex--;
      await playAtIndex(_currentIndex);
    } else {
      // Находимся в начале плейлиста - перезапускаем текущий
      await seek(Duration.zero);
    }
  }

  // Геттеры для текущего состояния
  AudioMetadataEntity? get currentAudio {
    if (_playlist.isEmpty || _currentIndex >= _playlist.length) return null;
    return _playlist[_currentIndex];
  }

  int get currentIndex => _currentIndex;

  int get playlistLength => _playlist.length;

  bool get hasNext => _currentIndex < _playlist.length - 1;

  bool get hasPrevious => _currentIndex > 0;

  Future<void> pause() async => _player.pause();

  Future<void> resume() async => _player.play();

  Future<void> stop() async => _player.stop();

  Future<void> seek(Duration position) async => _player.seek(position);

  Future<void> dispose() async => _player.dispose();
}
