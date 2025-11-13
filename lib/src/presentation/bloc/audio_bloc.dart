import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/audio_entity.dart';
import '../../domain/request/download_data_source.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final DownloadLocalDataSource downloadDataSource;
  final Map<String, StreamSubscription> _progressSubscriptions = {};

  AudioBloc(this.downloadDataSource) : super(AudioState.initial()) {
    on<InitializeAudioEvent>(_onInitializeAudio);
    on<SearchAudioEvent>(_onSearchAudio);
    on<ClearSearchEvent>(_onClearSearch);
    on<DownloadAudioEvent>(_onDownloadAudio);
    on<DeleteAudioEvent>(_onDeleteAudio);
    on<UpdateDownloadProgressEvent>(_onUpdateDownloadProgress);
    on<ClearErrorEvent>(_onClearError);
  }

  Future<void> _onInitializeAudio(
      InitializeAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(state.copyWith(
      allAudio: event.initialAudioList,
      filteredAudio: event.initialAudioList,
    ));
  }

  Future<void> _onSearchAudio(
      SearchAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    if (event.query.isEmpty) {
      emit(state.clearSearch());
    } else {
      final filteredAudio = state.allAudio.where((audio) {
        final query = event.query.toLowerCase();
        return audio.title.toLowerCase().contains(query) ||
            audio.artist.toLowerCase().contains(query);
      }).toList();

      emit(state.copyWith(
        filteredAudio: filteredAudio,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onClearSearch(
      ClearSearchEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(state.clearSearch());
  }

  Future<void> _onClearError(
      ClearErrorEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(state.clearError());
  }

  Future<void> _onDownloadAudio(
      DownloadAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    // Обновляем состояние на загрузку
    emit(state.copyWith(isLoading: true));

    // Отменяем предыдущую подписку
    _progressSubscriptions[event.audio.id]?.cancel();

    // Создаем новую подписку на прогресс
    final progressSubscription = downloadDataSource.progressStream
        .map((progressMap) => progressMap[event.audio.id] ?? 0.0)
        .where((progress) => progress >= 0.0)
        .listen((progress) {
      print("--------${progress}");
      add(UpdateDownloadProgressEvent(event.audio.id, progress));
    });

    _progressSubscriptions[event.audio.id] = progressSubscription;

    try {
      final fileName = '${event.audio.id}.mp3';
      await downloadDataSource.copyAssetToLocal(
        event.audio.assetPath,
        fileName,
        event.audio.id,
      );
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print(e);
      _progressSubscriptions[event.audio.id]?.cancel();
      _progressSubscriptions.remove(event.audio.id);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка загрузки: $e',
      ));
    }
  }

  Future<void> _onDeleteAudio(
      DeleteAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    try {
      final fileName = '${event.audio.id}.mp3';
      await downloadDataSource.deleteFile(fileName);
      emit(state.removeDownloadProgress(event.audio.id));

      _progressSubscriptions[event.audio.id]?.cancel();
      _progressSubscriptions.remove(event.audio.id);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Ошибка удаления: $e',
      ));
    }
  }

  Future<void> _onUpdateDownloadProgress(
      UpdateDownloadProgressEvent event,
      Emitter<AudioState> emit,
      ) async {
    final updatedState = state.updateDownloadProgress(
      event.audioId,
      event.progress,
    );

    print("--------${event.progress}");
    emit(updatedState);

    if (event.progress == 1.0) {
      _progressSubscriptions[event.audioId]?.cancel();
      _progressSubscriptions.remove(event.audioId);
    }
  }

  @override
  Future<void> close() {
    for (final subscription in _progressSubscriptions.values) {
      subscription.cancel();
    }
    _progressSubscriptions.clear();
    return super.close();
  }
}