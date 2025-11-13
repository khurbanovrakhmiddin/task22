import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/audio_entity.dart';
import '../../domain/repository/audio_repository.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository audioRepository;
  final Map<String, StreamSubscription> _progressSubscriptions = {};

  AudioBloc(this.audioRepository) : super(AudioInitial()) {
    on<InitializeAudioEvent>(_onInitializeAudio);
    on<SearchAudioEvent>(_onSearchAudio);
    on<ClearSearchEvent>(_onClearSearch);
    on<DownloadAudioEvent>(_onDownloadAudio);
    on<DeleteAudioEvent>(_onDeleteAudio);
    on<UpdateDownloadProgressEvent>(_onUpdateDownloadProgress);
  }

  Future<void> _onInitializeAudio(
      InitializeAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    emit(AudioReady(
      allAudio: event.initialAudioList,
      filteredAudio: event.initialAudioList,
    ));
  }

  Future<void> _onSearchAudio(
      SearchAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    final currentState = state;
    if (currentState is AudioReady) {
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredAudio: currentState.allAudio,
          searchQuery: '',
        ));
      } else {
        final filteredAudio = currentState.allAudio.where((audio) {
          final query = event.query.toLowerCase();
          return audio.title.toLowerCase().contains(query) ||
              audio.artist.toLowerCase().contains(query);
        }).toList();
        emit(currentState.copyWith(
          filteredAudio: filteredAudio,
          searchQuery: event.query,
        ));
      }
    }
  }

  Future<void> _onClearSearch(
      ClearSearchEvent event,
      Emitter<AudioState> emit,
      ) async {
    final currentState = state;
    if (currentState is AudioReady) {
      emit(currentState.copyWith(
        filteredAudio: currentState.allAudio,
        searchQuery: '',
      ));
    }
  }

  Future<void> _onDownloadAudio(
      DownloadAudioEvent event,
      Emitter<AudioState> emit,
      ) async {


    if (state is AudioReady) {
      final currentState = state as AudioReady;

      // Обновляем состояние на загрузку
      emit(currentState.copyWith(isLoading: true));

      // Отменяем предыдущую подписку
      _progressSubscriptions[event.audio.id]?.cancel();

      // Создаем новую подписку на прогресс
      final progressSubscription = audioRepository
          .getDownloadProgress(event.audio.id)
          .listen((progress) {
        add(UpdateDownloadProgressEvent(event.audio.id, progress));
      });

      _progressSubscriptions[event.audio.id] = progressSubscription;

      try {
        await audioRepository.downloadAudio(event.audio);
        emit(currentState.copyWith(isLoading: false));
      } catch (e) {
        _progressSubscriptions[event.audio.id]?.cancel();
        _progressSubscriptions.remove(event.audio.id);
        emit(currentState.copyWith(
          isLoading: false,
          errorMessage: 'Ошибка загрузки: $e',
        ));
      }
    }
  }

  Future<void> _onDeleteAudio(
      DeleteAudioEvent event,
      Emitter<AudioState> emit,
      ) async {
    if (state is AudioReady) {
      final currentState = state as AudioReady;

      try {
        await audioRepository.deleteDownloadedAudio(event.audio);

        final updatedState = currentState.removeDownloadProgress(event.audio.id);
        emit(updatedState);

        _progressSubscriptions[event.audio.id]?.cancel();
        _progressSubscriptions.remove(event.audio.id);
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка удаления: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateDownloadProgress(
      UpdateDownloadProgressEvent event,
      Emitter<AudioState> emit,
      ) async {
    if (state is AudioReady) {
      final currentState = state as AudioReady;
      final updatedState = currentState.updateDownloadProgress(
        event.audioId,
        event.progress,
      );

      emit(updatedState);

      if (event.progress == 1.0) {
        _progressSubscriptions[event.audioId]?.cancel();
        _progressSubscriptions.remove(event.audioId);
      }
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