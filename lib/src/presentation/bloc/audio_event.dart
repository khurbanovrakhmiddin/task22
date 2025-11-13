part of 'audio_bloc.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object> get props => [];
}

class InitializeAudioEvent extends AudioEvent {
  final List<AudioMetadataEntity> initialAudioList;
  const InitializeAudioEvent(this.initialAudioList);
  @override List<Object> get props => [initialAudioList];
}

class SearchAudioEvent extends AudioEvent {
  final String query;
  const SearchAudioEvent(this.query);
  @override List<Object> get props => [query];
}

class DownloadAudioEvent extends AudioEvent {
  final AudioMetadataEntity audio;
  const DownloadAudioEvent(this.audio);
  @override List<Object> get props => [audio];
}

class DeleteAudioEvent extends AudioEvent {
  final AudioMetadataEntity audio;
  const DeleteAudioEvent(this.audio);
  @override List<Object> get props => [audio];
}

class UpdateDownloadProgressEvent extends AudioEvent {
  final String audioId;
  final double progress;
  const UpdateDownloadProgressEvent(this.audioId, this.progress);
  @override List<Object> get props => [audioId, progress];
}

class ClearSearchEvent extends AudioEvent {}
class ClearErrorEvent extends AudioEvent {}