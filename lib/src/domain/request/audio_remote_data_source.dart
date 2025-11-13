
import '../entities/audio_entity.dart';

abstract class AudioRemoteDataSource {
  Future<List<AudioMetadataEntity>> fetchAudios();
}