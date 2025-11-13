import 'package:tak22_audio/src/domain/entities/audio_entity.dart';
import 'package:tak22_audio/src/data/model/audio_session_model.dart';

import '../../domain/repository/audio_local_repository.dart';
import '../../domain/request/audio_local_data_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioLocalDataSource localDataSource;

  AudioRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveCurrentSession({
    required AudioMetadataEntity audio,
    required Duration position,
    required Duration duration,
    required bool isPlaying,
  }) async {
    final session = AudioSessionModel(
      audioId: audio.id,
      audioPath: audio.assetPath,
      title: audio.title,
      artist: audio.artist,
      album: audio.album,
      artUri: audio.artUri,
      position: position.inSeconds,
      duration: duration.inSeconds,
      isPlaying: isPlaying,
      lastPlayed: DateTime.now(),
    );

    await localDataSource.saveCurrentAudioSession(session);
  }

  @override
  Future<AudioSessionModel?> loadCurrentSession() {
    return localDataSource.loadCurrentAudioSession();
  }

  @override
  Future<void> clearCurrentSession() {
    return localDataSource.clearCurrentAudioSession();
  }

  @override
  Future<void> savePlaylist(List<AudioMetadataEntity> playlist) {
    return localDataSource.savePlaylist(playlist);
  }

  @override
  Future<List<AudioMetadataEntity>> loadPlaylist() {
    return localDataSource.loadPlaylist();
  }

  @override
  Future<void> exportSession(AudioSessionModel session) {
    return localDataSource.exportSession(session);
  }

  @override
  Future<AudioSessionModel?> importSession() {
    return localDataSource.importSession();
  }
}
