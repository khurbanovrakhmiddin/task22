// audio_state.dart
part of 'audio_bloc.dart';

class AudioState extends Equatable {
  final List<AudioMetadataEntity> allAudio;
  final List<AudioMetadataEntity> filteredAudio;
  final String searchQuery;
  final Map<String, double> downloadProgress;
  final bool isLoading;
  final String? errorMessage;

  const AudioState({
    this.allAudio = const [],
    this.filteredAudio = const [],
    this.searchQuery = '',
    this.downloadProgress = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  factory AudioState.initial() => const AudioState();

  List<AudioMetadataEntity> get audioList {
    final audioToShow = filteredAudio.isNotEmpty ? filteredAudio : allAudio;
    return audioToShow;
  }

  List<AudioMetadataEntity> get downloadedAudio {
    return allAudio.where((audio) {
      final progress = downloadProgress[audio.id];
      return progress != null && progress == 1.0;
    }).toList();
  }

  bool get hasDownloads => downloadedAudio.isNotEmpty;
  bool get isSearching => searchQuery.isNotEmpty;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  AudioState copyWith({
    List<AudioMetadataEntity>? allAudio,
    List<AudioMetadataEntity>? filteredAudio,
    String? searchQuery,
    Map<String, double>? downloadProgress,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AudioState(
      allAudio: allAudio ?? this.allAudio,
      filteredAudio: filteredAudio ?? this.filteredAudio,
      searchQuery: searchQuery ?? this.searchQuery,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  AudioState updateDownloadProgress(String audioId, double progress) {
    final updatedProgress = Map<String, double>.from(downloadProgress);
    updatedProgress[audioId] = progress;
    return copyWith(downloadProgress: updatedProgress);
  }

  AudioState removeDownloadProgress(String audioId) {
    final updatedProgress = Map<String, double>.from(downloadProgress);
    updatedProgress.remove(audioId);
    return copyWith(downloadProgress: updatedProgress);
  }

  AudioState clearError() {
    return copyWith(errorMessage: null);
  }

  AudioState clearSearch() {
    return copyWith(
      filteredAudio: allAudio,
      searchQuery: '',
    );
  }

  @override
  List<Object?> get props => [
    allAudio,
    filteredAudio,
    searchQuery,
    downloadProgress,
    isLoading,
    errorMessage,
  ];
}