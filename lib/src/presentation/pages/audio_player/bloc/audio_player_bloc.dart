import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tak22_audio/core/sevices/audio_session_service.dart';
import 'package:tak22_audio/src/domain/usecases/get_audio_usecase.dart';
import 'package:tak22_audio/src/presentation/bloc/audio_bloc.dart';
import '../../../../../core/container/di/injector_impl.dart';
import '../../../../../core/sevices/player_service.dart';
import '../../../../domain/entities/audio_entity.dart';

part 'audio_player_event.dart';

part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final GetAudiosUseCase getAudioListUseCase;
  final AudioPlayerService _audioService;
  final AudioSessionService _sessionService;

  Duration? _currentDuration;

  AudioPlayerBloc(
    this.getAudioListUseCase,
    this._audioService,
    this._sessionService,
  ) : super(const AudioPlayerState()) {
    on<LoadAudiosEvent>(_onLoad);
    on<ShuffleOnOFEvent>(_onShuffleTap);
    on<PlayAudioEvent>(_onPlay);
    on<PlayPauseAudioEvent>(_onPause);
    on<ErrorStatusAudioEvent>(_onShowed);
    on<NextAudioEvent>(_onNext);
    on<PreviousAudioEvent>(_onPrevious);
    on<SeekAudioEvent>(_onSeek);
    on<ResetErrorEvent>(_onResetError);
    on<PlayerStateUpdatedEvent>(_onPlayerStateUpdated);
    on<PositionUpdatedEvent>(_onPositionUpdated);
    on<PlayerErrorEvent>(_onPlayerError);
    on<PlayerStopEvent>(_onStop);
    on<ReverseAudioEvent>(_onReverse);
    on<ReloadLastAudiosEvent>(_onReload);
    on<TrackIndexChangedEvent>(_onTrackIndexChanged);

    _setupServiceListeners();
  }

  // Сохраняем сессию при изменении состояния
  void _saveCurrentSession() {
    if (state.currentAudio != null) {
      _sessionService.saveCurrentAudio(
        audio: state.currentAudio!,
        position: state.position,
        duration: state.duration,
        isPlaying: state.playerStatus == PlayerStatus.play,
      );
    }
  }

  // Вызывайте этот метод при изменениях:
  Future<void> _onPositionUpdated(
    PositionUpdatedEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(position: event.position, duration: event.duration));
    _saveCurrentSession();
  }

  Future<void> _onShuffleTap(
    ShuffleOnOFEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _audioService.shuffle(!state.shuffle);
    emit(state.copyWith(shuffle: !state.shuffle));
    _saveCurrentSession();
  }

  void _setupServiceListeners() {
    // Слушаем состояние плеера из сервиса
    _audioService.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;

      final processingState = playerState.processingState;

      print('PlayerState: $isPlaying, $processingState');

      if (processingState == ProcessingState.ready && isPlaying) {
        add(PlayerStateUpdatedEvent(PlayerStatus.play));
      } else if (processingState == ProcessingState.ready && !isPlaying) {
        add(PlayerStateUpdatedEvent(PlayerStatus.pause));
      } else if (processingState == ProcessingState.completed) {
        add(NextAudioEvent());
      } else if (processingState == ProcessingState.idle) {
        add(PlayerStateUpdatedEvent(PlayerStatus.stop));
      }
    });

    // Слушаем позицию
    _audioService.positionStream.listen((position) {
      final duration = _audioService.currentDuration ?? Duration.zero;
      add(PositionUpdatedEvent(position, duration));
    });
    _audioService.setOnIndexChanged((newIndex) {
      // Добавляем событие когда трек автоматически меняется
      add(TrackIndexChangedEvent(newIndex));
    });
    // Слушаем длительность
    _audioService.durationStream.listen((duration) {
      if (duration != null) {
        _currentDuration = duration;
        // Обновляем состояние с новой длительностью
        if (state.position != Duration.zero) {
          add(PositionUpdatedEvent(state.position, duration));
        }
      }
    });

    // Слушаем ошибки
    _audioService.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.idle &&
          event.errorMessage != null) {
        add(PlayerErrorEvent(event.errorMessage ?? 'Unknown error'));
      }
    });
  }

  Future<void> _onTrackIndexChanged(
    TrackIndexChangedEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state.playerStatus == PlayerStatus.play) {
      final newTrack = state.audioFiles[event.index];

      emit(state.copyWith(currentAudio: newTrack, currentIndex: event.index));
    }
  }

  Future<void> _onLoad(
    LoadAudiosEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(fetchStatus: FetchStatus.loading));
    try {
      final savedSession = await _sessionService.loadCurrentAudio();

      final audios = await getAudioListUseCase();

      if (savedSession != null) {
        // Восстанавливаем состояние из сохраненной сессии

        print("savedSession.position${savedSession.position}");
        emit(
          state.copyWith(
            fetchStatus: FetchStatus.success,
            audioFiles: audios,
            currentIndex: 0,
            lastAudio: AudioMetadataEntity(
              id: savedSession.audioId,
              title: savedSession.title,
              artist: savedSession.artist ?? '',
              duration: savedSession.position,
              album: savedSession.album,
              artUri: savedSession.artUri,
              assetPath: savedSession.audioPath,
            ),
            position: Duration(seconds: savedSession.position ?? 0),
            duration: Duration(seconds: savedSession.duration ?? 0),
            playerStatus: savedSession.isPlaying
                ? PlayerStatus.play
                : PlayerStatus.pause,
          ),
        );
      } else {
        emit(
          state.copyWith(
            fetchStatus: FetchStatus.success,
            audioFiles: audios,
            currentIndex: 0,
          ),
        );
      }

      di.get<AudioBloc>().add(InitializeAudioEvent(audios));
    } catch (e) {
      emit(
        state.copyWith(
          fetchStatus: FetchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPlay(
    PlayAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final audioFiles = state.audioFiles;
    if (audioFiles.isEmpty || event.index >= audioFiles.length) return;

    final current = audioFiles[event.index];

    // Если уже играет этот же трек - пауза
    if (state.currentIndex == event.index &&
        state.playerStatus == PlayerStatus.play) {
      await _audioService.pause();
      return;
    }

    emit(
      state.copyWith(
        currentIndex: event.index,
        currentAudio: current,
        isLoading: true,
        errorMessage: null,
      ),
    );

    try {
      if (event.reload) {
        final result = await _audioService.reloadLastAudio(
          event.index,
          state.audioFiles,
          state.lastAudio?.duration,
        );
        await _sessionService.clearCurrentAudio();
        emit(
          state.copyWith(playerStatus: PlayerStatus.play, isLoading: !result),
        );
      } else {
        final result = await _audioService.playAudio(
          event.index,
          state.audioFiles,
        );
        emit(
          state.copyWith(playerStatus: PlayerStatus.play, isLoading: !result),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          playerStatus: PlayerStatus.error,
          errorMessage: e.toString(),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onPause(
    PlayPauseAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (state.playerStatus == PlayerStatus.play) {
        await _audioService.pause();
        emit(state.copyWith(playerStatus: PlayerStatus.pause));
      } else if (state.playerStatus == PlayerStatus.pause) {
        await _audioService.resume();
        emit(state.copyWith(playerStatus: PlayerStatus.play));
      }
    } catch (e) {
      emit(
        state.copyWith(
          playerStatus: PlayerStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onNext(
    NextAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (state.audioFiles.length - 1 == state.currentIndex && state.reverse) {
      add(PlayAudioEvent(0));
    } else {
      await _audioService.seekToNext();
    }
    // final nextIndex = (state.currentIndex + 1) % state.audioFiles.length;
    // add(PlayAudioEvent(nextIndex));
  }

  Future<void> _onShowed(
    ErrorStatusAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(errorMessage: ''));
  }

  Future<void> _onPrevious(
    PreviousAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _audioService.seekToPrev();
    // final prevIndex =
    //     (state.currentIndex - 1 + state.audioFiles.length) %
    //     state.audioFiles.length;
    // add(PlayAudioEvent(prevIndex));
  }

  Future<void> _onSeek(
    SeekAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioService.seek(event.position);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onReverse(
    ReverseAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(reverse: !state.reverse));
  }

  Future<void> _onResetError(
    ResetErrorEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(
      state.copyWith(
        errorMessage: null,
        playerStatus: state.playerStatus == PlayerStatus.error
            ? PlayerStatus.stop
            : state.playerStatus,
      ),
    );
  }

  Future<void> _onPlayerStateUpdated(
    PlayerStateUpdatedEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(playerStatus: event.status, isLoading: false));
  }

  Future<void> _onStop(
    PlayerStopEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final isLastAudioMode =
        state.currentAudio == null && state.lastAudio != null;

    await _audioService.stop();
    if(isLastAudioMode){
      await _sessionService.clearCurrentAudio();
      emit(
        state.copyWith(
          playerStatus: PlayerStatus.stop,
          currentIndex: -1,
          currentAudio: null,
        ),
      );
    }else{
      emit(
        state.copyWith(
          playerStatus: PlayerStatus.stop,
          currentIndex: -1,
          currentAudio: null,
        ),
      );
    }



  }

  Future<void> _onReload(
    ReloadLastAudiosEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final index = state.audioFiles.indexWhere(
      (e) => e.id == state.lastAudio?.id,
    );
    if (index != -1) {
      add(PlayAudioEvent(index, true));
    }
  }

  Future<void> _onPlayerError(
    PlayerErrorEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(
      state.copyWith(
        playerStatus: PlayerStatus.error,
        errorMessage: event.errorMessage,
      ),
    );
  }

  @override
  Future<void> close() {
    _audioService.dispose();
    return super.close();
  }
}
