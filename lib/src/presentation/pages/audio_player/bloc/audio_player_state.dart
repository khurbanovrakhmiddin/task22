 part of 'audio_player_bloc.dart';

enum FetchStatus { initial, loading, success, failure }
enum PlayerStatus { initial, play, pause, stop, error }

class AudioPlayerState extends Equatable {
  final FetchStatus fetchStatus;
  final PlayerStatus playerStatus;
  final List<AudioMetadataEntity> audioFiles;
  final int currentIndex;
  final AudioMetadataEntity? currentAudio;
  final AudioMetadataEntity? lastAudio;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final bool isLoading;
  final bool shuffle;
  final bool reverse;

  const AudioPlayerState({
    this.fetchStatus = FetchStatus.initial,
    this.playerStatus = PlayerStatus.initial,
    this.audioFiles = const [],
    this.currentIndex = -1,
    this.currentAudio,
    this.lastAudio,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.isLoading = false,
    this.shuffle = false,
    this.reverse = false,
  });

  bool get hasError => errorMessage != null;
  bool get canPlay => audioFiles.isNotEmpty && !isLoading && !hasError;

  @override
  List<Object?> get props => [
    fetchStatus,
    playerStatus,
    audioFiles,
    reverse,
    shuffle,
    currentIndex,
    currentAudio,
    lastAudio,
    position,
    duration,
    errorMessage,
    isLoading,
  ];

  AudioPlayerState copyWith({
    FetchStatus? fetchStatus,
    PlayerStatus? playerStatus,
    List<AudioMetadataEntity>? audioFiles,
    int? currentIndex,
    AudioMetadataEntity? currentAudio,
    AudioMetadataEntity? lastAudio,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool? isLoading,
    bool? reverse,
    bool? shuffle,
  }) {
    return AudioPlayerState(
      fetchStatus: fetchStatus ?? this.fetchStatus,
      playerStatus: playerStatus ?? this.playerStatus,
      audioFiles: audioFiles ?? this.audioFiles,
      currentIndex: currentIndex ?? this.currentIndex,
      lastAudio:currentIndex == -1? null:lastAudio ?? this.lastAudio,
      currentAudio:currentIndex == -1? currentAudio:currentAudio??this.currentAudio,
      position: position ?? this.position,
      reverse: reverse ?? this.reverse,
      shuffle: shuffle ?? this.shuffle,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}