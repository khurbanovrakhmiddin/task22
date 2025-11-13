
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';

abstract class AudioRepository {
  Future<List<AudioMetadataEntity>> getAudios();
  Future<void> downloadAudio(AudioMetadataEntity audio);
  Future<void> deleteDownloadedAudio(AudioMetadataEntity audio);
  Stream<double> getDownloadProgress(String audioId);
  Future<String?> getLocalAudioPath(AudioMetadataEntity audio);
  Future<String> getAudioPath(AudioMetadataEntity audio);

   Future<bool> isAudioDownloaded(AudioMetadataEntity audio);
}