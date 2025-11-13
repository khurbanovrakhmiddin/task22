part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object> get props => [];
}

class LoadAudiosEvent extends AudioPlayerEvent {}
class ShuffleOnOFEvent extends AudioPlayerEvent {}
class ReloadLastAudiosEvent extends AudioPlayerEvent {}
class TrackIndexChangedEvent extends AudioPlayerEvent {
  final int index;

  const TrackIndexChangedEvent(this.index);

  @override
  List<Object> get props => [index];
}
class PlayAudioEvent extends AudioPlayerEvent {
  final int index;
  final bool reload;

  const PlayAudioEvent(this.index,[this.reload = false]);

  @override
  List<Object> get props => [index];
}

class PlayPauseAudioEvent extends AudioPlayerEvent {}
class ErrorStatusAudioEvent extends AudioPlayerEvent {}


class NextAudioEvent extends AudioPlayerEvent {}
class ReverseAudioEvent extends AudioPlayerEvent {}

class PreviousAudioEvent extends AudioPlayerEvent {}

class SeekAudioEvent extends AudioPlayerEvent {
  final Duration position;

  const SeekAudioEvent(this.position);

  @override
  List<Object> get props => [position];
}

class ResetErrorEvent extends AudioPlayerEvent {}
class PlayerStopEvent extends AudioPlayerEvent {}

// Internal events
class PlayerStateUpdatedEvent extends AudioPlayerEvent {
  final PlayerStatus status;

  const PlayerStateUpdatedEvent(this.status);

  @override
  List<Object> get props => [status];
}

class PositionUpdatedEvent extends AudioPlayerEvent {
  final Duration position;
  final Duration duration;

  const PositionUpdatedEvent(this.position, this.duration);

  @override
  List<Object> get props => [position, duration];
}

class PlayerErrorEvent extends AudioPlayerEvent {
  final String errorMessage;

  const PlayerErrorEvent(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}