part of 'audio_bloc.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object> get props => [];
}

class AudioInitial extends AudioState {}

class AudioReady extends AudioState {
  final List<AudioMetadataEntity> allAudio;
  final List<AudioMetadataEntity> filteredAudio;
  final String searchQuery;
  final Map<String, double> downloadProgress;
  final bool isLoading;
  final String? errorMessage;

  const AudioReady({
    required this.allAudio,
    this.filteredAudio = const [],
    this.searchQuery = '',
    this.downloadProgress = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  List<AudioMetadataEntity> get audioList {
    final audioToShow = filteredAudio.isNotEmpty ? filteredAudio : allAudio;

    return audioToShow.map((audio) {
      final progress = downloadProgress[audio.id];
      return progress != null ? audio.copyWith(downloadProgress: progress) : audio;
    }).toList();
  }

  List<AudioMetadataEntity> get downloadedAudio {
    return allAudio.where((audio) {
      final progress = downloadProgress[audio.id];
      return progress != null && progress == 1.0;
    }).toList();
  }

  bool get hasDownloads => downloadedAudio.isNotEmpty;
  bool get isSearching => searchQuery.isNotEmpty;

  AudioReady copyWith({
    List<AudioMetadataEntity>? allAudio,
    List<AudioMetadataEntity>? filteredAudio,
    String? searchQuery,
    Map<String, double>? downloadProgress,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AudioReady(
      allAudio: allAudio ?? this.allAudio,
      filteredAudio: filteredAudio ?? this.filteredAudio,
      searchQuery: searchQuery ?? this.searchQuery,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AudioReady updateDownloadProgress(String audioId, double progress) {
    final updatedProgress = Map<String, double>.from(downloadProgress);
    updatedProgress[audioId] = progress;
    return copyWith(downloadProgress: updatedProgress);
  }

  AudioReady removeDownloadProgress(String audioId) {
    final updatedProgress = Map<String, double>.from(downloadProgress);
    updatedProgress.remove(audioId);
    return copyWith(downloadProgress: updatedProgress);
  }

  @override
  List<Object> get props => [
    allAudio,
    filteredAudio,
    searchQuery,
    downloadProgress,
    isLoading,
    errorMessage ?? '',
  ];
}