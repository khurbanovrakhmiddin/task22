// audio_session_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';

import '../../src/data/model/audio_session_model.dart';

class AudioSessionService {
  static const String _sessionKey = 'current_audio_session';
  static const String _playlistKey = 'audio_playlist';

  // Сохранить текущий трек
  Future<void> saveCurrentAudio({
    required AudioMetadataEntity audio,
    required Duration position,
    required Duration duration,
    required bool isPlaying,
  }) async {
    final session = AudioSessionModel(
      audioId: audio.id,
      audioPath: audio.assetPath,
      title: audio.title,
      artist: audio.artist,
      album: audio.album,
      artUri: audio.artUri,
      position: position,
      duration: duration,
      isPlaying: isPlaying,
      lastPlayed: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));

    print('💾 Сохранен трек: ${audio.title}, позиция: ${position.inSeconds}с');
  }

  // Загрузить сохраненный трек
  Future<AudioSessionModel?> loadCurrentAudio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);

      if (sessionJson == null) return null;

      final sessionData = jsonDecode(sessionJson);
      final session = AudioSessionModel.fromJson(sessionData);

      // Проверяем не устарели ли данные (больше 24 часов)
      final now = DateTime.now();
      final difference = now.difference(session.lastPlayed);
      if (difference.inHours > 24) {
        await clearCurrentAudio();
        return null;
      }

      print('📂 Загружен сохраненный трек: ${session.title}');
      return session;
    } catch (e) {
      print('❌ Ошибка загрузки сохраненного трека: $e');
      return null;
    }
  }

  // Очистить сохраненный трек
  Future<void> clearCurrentAudio() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    print('🧹 Очищен сохраненный трек');
  }

  // Сохранить плейлист
  Future<void> savePlaylist(List<AudioMetadataEntity> playlist) async {
    await _save(playlist);
    print('💾 Сохранен плейлист: ${playlist.length} треков');
  }

  Future<void> _save(List<AudioMetadataEntity> playlist)async{
    final prefs = await SharedPreferences.getInstance();
    final playlistJson = jsonEncode(playlist.map((audio) => _audioToJson(audio)).toList());
    await prefs.setString(_playlistKey, playlistJson);
  }
  // Загрузить плейлист
  Future<List<AudioMetadataEntity>> loadPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistJson = prefs.getString(_playlistKey);

      if (playlistJson == null) return [];

      final playlistData = jsonDecode(playlistJson) as List;
      final playlist = playlistData.map((json) => _audioFromJson(json)).toList();

      print('📂 Загружен плейлист: ${playlist.length} треков');
      return playlist;
    } catch (e) {
      print('❌ Ошибка загрузки плейлиста: $e');
      return [];
    }
  }

  // Экспорт сессии в файл
  Future<void> exportSession(AudioSessionModel session) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/audio_session_backup.json');

      final exportData = {
        'session': session.toJson(),
        'exportedAt': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(exportData));
      print('📤 Сессия экспортирована: ${file.path}');
    } catch (e) {
      print('❌ Ошибка экспорта сессии: $e');
    }
  }

  // Импорт сессии из файла
  Future<AudioSessionModel?> importSession() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/audio_session_backup.json');

      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final importData = jsonDecode(content);

      final session = AudioSessionModel.fromJson(importData['session']);
      print('📥 Сессия импортирована: ${session.title}');

      return session;
    } catch (e) {
      print('❌ Ошибка импорта сессии: $e');
      return null;
    }
  }

  // Вспомогательные методы для конвертации
  Map<String, dynamic> _audioToJson(AudioMetadataEntity audio) {
    return {
      'id': audio.id,
      'title': audio.title,
      'artist': audio.artist,
      'album': audio.album,
      'artUri': audio.artUri,
      'assetPath': audio.assetPath,
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
    );
  }
}