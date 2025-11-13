

 import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';
import 'package:tak22_audio/src/data/model/audio_session_model.dart';

import '../../../domain/request/audio_local_data_source.dart';

class AudioLocalDataSourceImpl implements AudioLocalDataSource {
  static const String _sessionKey = 'current_audio_session';
  static const String _playlistKey = 'audio_playlist';
  final   SharedPreferences prefs;
  const AudioLocalDataSourceImpl(this.prefs);

  @override
  Future<void> saveCurrentAudioSession(AudioSessionModel session) async {
     await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
   }

  @override
  Future<AudioSessionModel?> loadCurrentAudioSession() async {
    try {
       final sessionJson = prefs.getString(_sessionKey);

      if (sessionJson == null) return null;

      final sessionData = jsonDecode(sessionJson);
      final session = AudioSessionModel.fromJson(sessionData);

       final now = DateTime.now();
      final difference = now.difference(session.lastPlayed);
      if (difference.inHours > 24) {
        await clearCurrentAudioSession();
        return null;
      }

       return session;
    } catch (e) {
       return null;
    }
  }

  @override
  Future<void> clearCurrentAudioSession() async {
     await prefs.remove(_sessionKey);
   }

  @override
  Future<void> savePlaylist(List<AudioMetadataEntity> playlist) async {
     final playlistJson = jsonEncode(
      playlist.map((audio) => _audioToJson(audio)).toList(),
    );
    await prefs.setString(_playlistKey, playlistJson);
   }

  @override
  Future<List<AudioMetadataEntity>> loadPlaylist() async {
    try {
       final playlistJson = prefs.getString(_playlistKey);

      if (playlistJson == null) return [];

      final playlistData = jsonDecode(playlistJson) as List;
      final playlist = playlistData
          .map((json) => _audioFromJson(json))
          .toList();

       return playlist;
    } catch (e) {
       return [];
    }
  }

  @override
  Future<void> exportSession(AudioSessionModel session) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/audio_session_backup.json');

      final exportData = {
        'session': session.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(exportData));
     } catch (_) {
     }
  }

  @override
  Future<AudioSessionModel?> importSession() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/audio_session_backup.json');

      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final importData = jsonDecode(content);

      final session = AudioSessionModel.fromJson(importData['session']);
  
      return session;
    } catch (e) {
       return null;
    }
  }

   Map<String, dynamic> _audioToJson(AudioMetadataEntity audio) {
    return {
      'id': audio.id,
      'title': audio.title,
      'artist': audio.artist,
      'album': audio.album,
      'artUri': audio.artUri,
      'assetPath': audio.assetPath,
      'duration': audio.duration,
      'year': audio.year,
      'genre': audio.genre,
    };
  }

  AudioMetadataEntity _audioFromJson(Map<String, dynamic> json) {
    return AudioMetadataEntity(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      artUri: json['artUri'],
      assetPath: json['assetPath'],
      duration: json['duration'],
      year: json['year'],
      genre: json['genre'],
    );
  }
}
