 import 'package:equatable/equatable.dart';

class AudioSessionModel extends Equatable {
  final String audioId;
  final String audioPath;
  final String title;
  final String? artist;
  final String? album;
  final String? artUri;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final DateTime lastPlayed;

  const AudioSessionModel({
    required this.audioId,
    required this.audioPath,
    required this.title,
    this.artist,
    this.album,
    this.artUri,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.lastPlayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'audioId': audioId,
      'audioPath': audioPath,
      'title': title,
      'artist': artist,
      'album': album,
      'artUri': artUri,
      'position': position.inMilliseconds,
      'duration': duration.inMilliseconds,
      'isPlaying': isPlaying,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  factory AudioSessionModel.fromJson(Map<String, dynamic> json) {
    return AudioSessionModel(
      audioId: json['audioId'],
      audioPath: json['audioPath'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      artUri: json['artUri'],
      position: Duration(milliseconds: json['position']),
      duration: Duration(milliseconds: json['duration']),
      isPlaying: json['isPlaying'],
      lastPlayed: DateTime.parse(json['lastPlayed']),
    );
  }

  AudioSessionModel copyWith({
    String? audioId,
    String? audioPath,
    String? title,
    String? artist,
    String? album,
    String? artUri,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    DateTime? lastPlayed,
  }) {
    return AudioSessionModel(
      audioId: audioId ?? this.audioId,
      audioPath: audioPath ?? this.audioPath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artUri: artUri ?? this.artUri,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  @override
  List<Object?> get props => [
    audioId,
    audioPath,
    title,
    artist,
    album,
    artUri,
    position,
    duration,
    isPlaying,
    lastPlayed,
  ];
}