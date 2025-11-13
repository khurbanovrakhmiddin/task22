import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

class AudioMetadataEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? artUri;
  final String assetPath;
  final int? duration; // длительность в миллисекундах
  final int? year;
  final double downloadProgress;
  final String? genre;
  final ui.Image? image;
  final Uint8List? albumArt; // бинарные данные обложки

  AudioMetadataEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artUri,
    String? assetPath,
    int? duration,
    int? year,
    double? downloadProgress,
    String? genre,
    ui.Image? image,
    Uint8List? albumArt,
  }) {
    return AudioMetadataEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artUri: artUri ?? this.artUri,
      assetPath: assetPath ?? this.assetPath,
      duration: duration ?? this.duration,
      year: year ?? this.year,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      genre: genre ?? this.genre,
      image: image ?? this.image,
      albumArt: albumArt ?? this.albumArt,
    );
  }
  const AudioMetadataEntity({
    required this.id,
    required this.title,
    required this.assetPath,
    this.artist ='',
    this.album,
    this.image,
    this.downloadProgress =0,
    this.artUri,
    this.duration,
    this.year,
    this.genre,
    this.albumArt,
  });


  @override
  List<Object?> get props => [
    id,
    title,
    assetPath,
    artist,
    album,
    image,
    artUri,
    downloadProgress,
    duration,
    year,
    genre,
    albumArt,
  ];
}