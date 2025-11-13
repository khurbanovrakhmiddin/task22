import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/audio_entity.dart';
import '../../../bloc/audio_bloc.dart';
import '../../audio_player/bloc/audio_player_bloc.dart';
import '../../audio_player/player_page.dart';
import '../../../widget/audio_card.dart';
import '../../../widget/download_button.dart';

class MainBody extends StatelessWidget {
  const MainBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final playerBloc = context.read<AudioPlayerBloc>();

        return BlocBuilder<AudioBloc, AudioState>(
          builder: (context, audioState) {
            final audioBloc = context.read<AudioBloc>();

            // Инициализируем AudioBloc когда загружены аудио
            if (playerState.fetchStatus == FetchStatus.success &&
                audioState.allAudio.isEmpty) {
              // Проверяем что аудио еще не инициализированы
              WidgetsBinding.instance.addPostFrameCallback((_) {
                audioBloc.add(InitializeAudioEvent(playerState.audioFiles));
              });
            }
            // Состояние загрузки AudioPlayerBloc
            if (playerState.fetchStatus == FetchStatus.loading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Загрузка аудио...'),
                  ],
                ),
              );
            }

            // Состояние ошибки AudioPlayerBloc
            if (playerState.fetchStatus == FetchStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        playerState.errorMessage ?? 'Неизвестная ошибка',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        playerBloc.add(LoadAudiosEvent());
                      },
                      child: Text('Попробовать снова'),
                    ),
                  ],
                ),
              );
            }

            List<AudioMetadataEntity> displayAudio = [];
            if (audioState.allAudio.isNotEmpty) {
              displayAudio = audioState.audioList;
            } else if (playerState.fetchStatus == FetchStatus.success) {
              displayAudio = playerState.audioFiles;
            }

            if (playerState.fetchStatus == FetchStatus.success &&
                displayAudio.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Нет доступных аудио',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Добавьте аудио файлы в приложение',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // Успешная загрузка с данными
            if (playerState.fetchStatus == FetchStatus.success) {
              return ListView.builder(
                padding: EdgeInsets.all(16).copyWith(bottom: 300),
                itemCount: displayAudio.length,
                itemBuilder: (context, index) {
                  final audioEntity = displayAudio[index];
                  final isCurrent = playerState.currentAudio == audioEntity;
                  final isLoadingCurrent = isCurrent && playerState.isLoading;

                  return AudioCard(
                    audio: audioEntity,
                    isCurrent: isCurrent,
                    isLoadingCurrent: isLoadingCurrent,
                    onTap: () {
                      print(
                        "playerState.lastAudio?.id == audioEntity.id${playerState.lastAudio?.id == audioEntity.id}",
                      );

                      if (playerState.lastAudio?.id == audioEntity.id &&
                          playerState.playerStatus == PlayerStatus.initial) {
                        playerBloc.add(ReloadLastAudiosEvent());
                      } else if (!isCurrent) {
                        playerBloc.add(PlayAudioEvent(index));
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerPage(audio: audioEntity),
                        ),
                      );
                    },
                    // Добавляем кнопку загрузки
                    icon: DownloadButton(audio: audioEntity),
                  );
                },
              );
            }

            // Начальное состояние
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tak22 Audio',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Нажмите для загрузки аудио',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      playerBloc.add(LoadAudiosEvent());
                    },
                    child: Text('Загрузить аудио'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
