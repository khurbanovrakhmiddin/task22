import 'package:tak22_audio/src/domain/entities/audio_entity.dart';

abstract class AudioRepository {
  Future<List<AudioMetadataEntity>> getAudios();

  Future<List<AudioMetadataEntity>> refreshAudios();
  Future<bool> hasLocalData();
}
