import 'package:tak22_audio/src/domain/entities/audio_entity.dart';
import 'package:tak22_audio/src/data/model/audio_session_model.dart';

abstract class AudioRepository {
  Future<void> saveCurrentSession({
    required AudioMetadataEntity audio,
    required Duration position,
    required Duration duration,
    required bool isPlaying,
  });

  Future<AudioSessionModel?> loadCurrentSession();

  Future<void> clearCurrentSession();

  Future<void> savePlaylist(List<AudioMetadataEntity> playlist);

  Future<List<AudioMetadataEntity>> loadPlaylist();

  Future<void> exportSession(AudioSessionModel session);

  Future<AudioSessionModel?> importSession();
}
