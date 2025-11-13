// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tak22_audio/core/sevices/audio_session_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';
import 'package:tak22_audio/src/data/model/audio_session_model.dart';

void main() async {
  late AudioSessionService audioSessionService;
  late AudioMetadataEntity testAudio;
  late AudioSessionModel testSession;

  setUp(() async {
     SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    audioSessionService = AudioSessionService(prefs);

    testAudio = AudioMetadataEntity(
      id: 'test_audio_1',
      title: 'Test Audio',
      artist: 'Test Artist',
      album: 'Test Album',
      artUri: 'https://example.com/art.jpg',
      assetPath: '/path/to/audio.mp3',
    );

    testSession = AudioSessionModel(
      audioId: testAudio.id,
      audioPath: testAudio.assetPath,
      title: testAudio.title,
      artist: testAudio.artist,
      album: testAudio.album,
      artUri: testAudio.artUri,
      position: 120,
      duration: 300,
      isPlaying: true,
      lastPlayed: DateTime.now(),
    );
  });

  group('AudioSessionService Tests', () {
    test('Сохранить и загрузить текущий трек', () async {
      // Сохраняем трек
      await audioSessionService.saveCurrentAudio(
        audio: testAudio,
        position: Duration(seconds: 120),
        duration: Duration(seconds: 300),
        isPlaying: true,
      );

      // Загружаем трек
      final loadedSession = await audioSessionService.loadCurrentAudio();

      expect(loadedSession, isNotNull);
      expect(loadedSession!.audioId, equals(testAudio.id));
      expect(loadedSession.title, equals(testAudio.title));
      expect(loadedSession.position, equals(120));
      expect(loadedSession.isPlaying, isTrue);
    });

    test('Загрузить несуществующий трек возвращает null', () async {
      final loadedSession = await audioSessionService.loadCurrentAudio();
      expect(loadedSession, isNull);
    });

    test('Очистить сохраненный трек', () async {
      // Сначала сохраняем
      await audioSessionService.saveCurrentAudio(
        audio: testAudio,
        position: Duration.zero,
        duration: Duration(seconds: 300),
        isPlaying: false,
      );

      // Затем очищаем
      await audioSessionService.clearCurrentAudio();

      // Проверяем, что трек удален
      final loadedSession = await audioSessionService.loadCurrentAudio();
      expect(loadedSession, isNull);
    });

    test('Загрузить пустой плейлист возвращает пустой список', () async {
      final loadedPlaylist = await audioSessionService.loadPlaylist();
      expect(loadedPlaylist, isEmpty);
    });

    test('Сохранение плейлиста с пустым списком', () async {
      await audioSessionService.savePlaylist([]);
      final loadedPlaylist = await audioSessionService.loadPlaylist();
      expect(loadedPlaylist, isEmpty);
    });

    test('Сохранение плейлиста с одним элементом', () async {
      await audioSessionService.savePlaylist([testAudio]);
      final loadedPlaylist = await audioSessionService.loadPlaylist();
      expect(loadedPlaylist.length, equals(1));
      expect(loadedPlaylist.first.id, equals(testAudio.id));
    });
  });

  group('Edge Cases', () {
    test('Сохранение аудио с null значениями', () async {
      final audioWithNulls = AudioMetadataEntity(
        id: 'test_audio_null',
        title: 'Test Audio',
        artist: '',
        album: null,
        artUri: null,
        assetPath: '/path/to/audio.mp3',
      );

      await audioSessionService.saveCurrentAudio(
        audio: audioWithNulls,
        position: Duration.zero,
        duration: Duration(seconds: 300),
        isPlaying: false,
      );

      final loadedSession = await audioSessionService.loadCurrentAudio();
      expect(loadedSession, isNotNull);
      expect(loadedSession!.artist, '');
      expect(loadedSession.album, isNull);
      expect(loadedSession.artUri, isNull);
    });

    test('Сохранение с нулевой позицией', () async {
      await audioSessionService.saveCurrentAudio(
        audio: testAudio,
        position: Duration.zero,
        duration: Duration(seconds: 300),
        isPlaying: true,
      );

      final loadedSession = await audioSessionService.loadCurrentAudio();
      expect(loadedSession!.position, equals(0));
    });

    test('Сохранение с максимальной длительностью', () async {
      await audioSessionService.saveCurrentAudio(
        audio: testAudio,
        position: Duration(seconds: 100),
        duration: Duration(hours: 2),
        isPlaying: false,
      );

      final loadedSession = await audioSessionService.loadCurrentAudio();
      expect(loadedSession!.duration, equals(2));
    });
  });
}
