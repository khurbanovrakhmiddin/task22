import 'dart:async';

import '../../../core/sevices/download_service.dart';
import '../../domain/entities/audio_entity.dart';
import '../../domain/repository/audio_repository.dart';
import '../../domain/request/audio_remote_data_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource dataSource;
  final DownloadService downloadService;

  AudioRepositoryImpl(this.dataSource, this.downloadService);

  @override
  Future<List<AudioMetadataEntity>> getAudios() async {
    return await dataSource.fetchAudios();
  }

  final Map<String, StreamController<double>> _progressControllers = {};

  @override
  Future<void> downloadAudio(AudioMetadataEntity audio) async {
    final fileName = '${audio.id}.mp3';

    final isDownloaded = await downloadService.fileExists(fileName);
    if (isDownloaded) {
      _progressControllers[audio.id]?.add(1.0);
      return;
    }

    final controller = StreamController<double>();
    _progressControllers[audio.id] = controller;

    try {
      if (downloadService.isAssetPath(audio.assetPath)) {
        await downloadService.copyAssetToLocal(
          audio.assetPath,
          fileName,
          audio.id,
        );
      } else {
        throw Exception('Only asset downloads are supported');
      }
    } catch (e) {
      controller.addError(e);
      rethrow;
    }
  }

  @override
  Stream<double> getDownloadProgress(String audioId) {
    if (!_progressControllers.containsKey(audioId)) {
      _progressControllers[audioId] = StreamController<double>.broadcast();
    }
    return _progressControllers[audioId]!.stream;
  }

  @override
  Future<void> deleteDownloadedAudio(AudioMetadataEntity audio) async {
    final fileName = '${audio.id}.mp3';
    await downloadService.deleteFile(fileName);

    _progressControllers[audio.id]?.close();
    _progressControllers.remove(audio.id);
  }

  @override
  Future<String?> getLocalAudioPath(AudioMetadataEntity audio) async {
    final fileName = '${audio.id}.mp3';
    final exists = await downloadService.fileExists(fileName);
    if (exists) {
      return await downloadService.getFilePath(fileName);
    }
    return null;
  }

  @override
  Future<String> getAudioPath(AudioMetadataEntity audio) async {
    final localPath = await getLocalAudioPath(audio);
    return localPath ?? audio.assetPath;
  }

  @override
  Future<bool> isAudioDownloaded(AudioMetadataEntity audio) async {
    final fileName = '${audio.id}.mp3';
    return await downloadService.fileExists(fileName);
  }

  void updateProgress(String audioId, double progress) {
    _progressControllers[audioId]?.add(progress);
  }

  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }
}
