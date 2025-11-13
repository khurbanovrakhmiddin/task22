import '../entities/audio_entity.dart';
import '../repository/audio_repository.dart';

class GetAudiosUseCase {
  final AudioRepository repository;

  GetAudiosUseCase(this.repository);

  Future<List<AudioMetadataEntity>> call() async {
    return await repository.getAudios();
  }
}