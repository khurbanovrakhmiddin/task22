

import '../../data/model/audio_session_model.dart';
import '../entities/audio_entity.dart';

abstract class AudioLocalDataSource {
  Future<void> saveCurrentAudioSession(AudioSessionModel session);

  Future<AudioSessionModel?> loadCurrentAudioSession();

  Future<void> clearCurrentAudioSession();

  Future<void> savePlaylist(List<AudioMetadataEntity> playlist);

  Future<List<AudioMetadataEntity>> loadPlaylist();

  Future<void> exportSession(AudioSessionModel session);

  Future<AudioSessionModel?> importSession();
}
