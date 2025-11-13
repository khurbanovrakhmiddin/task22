import 'dart:async';

import 'package:tak22_audio/src/domain/request/audio_local_data_source.dart';
import '../../domain/entities/audio_entity.dart';
import '../../domain/repository/audio_repository.dart';
import '../../domain/request/audio_remote_data_source.dart';
import '../model/audio_session_model.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource dataSource;
  final AudioLocalDataSource localSource;

  AudioRepositoryImpl(this.dataSource, this.localSource);

  @override
  Future<List<AudioMetadataEntity>> getAudios() async {
    try {
      final hasLocal = await hasLocalData();

      if (hasLocal) {
        final localAudios = await localSource.loadPlaylist();
        if (localAudios.isNotEmpty) {
          //Random Image
          return localAudios.map((e) => e.copyWith(artUri: getImage())).toList();
        }
      }

      final remoteAudios = await dataSource.fetchAudios();

      await localSource.savePlaylist(remoteAudios);

      return remoteAudios;
    } catch (e) {
      final localAudios = await localSource.loadPlaylist();
      if (localAudios.isNotEmpty) {
        return localAudios.map((e) => e.copyWith(artUri: getImage())).toList();
      }

      rethrow;
    }
  }

  @override
  Future<List<AudioMetadataEntity>> refreshAudios() async {
    try {
      print('🔄 Принудительное обновление аудио');
      final remoteAudios = await dataSource.fetchAudios();

      // Сохраняем новые данные
      await localSource.savePlaylist(remoteAudios);

      return remoteAudios;
    } catch (e) {
      print('❌ Ошибка при обновлении аудио: $e');

      // В случае ошибки возвращаем локальные данные
      final localAudios = await localSource.loadPlaylist();
      return localAudios;
    }
  }

  @override
  Future<bool> hasLocalData() async {
    final localAudios = await localSource.loadPlaylist();
    return localAudios.isNotEmpty;
  }
}
