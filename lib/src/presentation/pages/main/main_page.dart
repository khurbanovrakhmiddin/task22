import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tak22_audio/core/utils/parser.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/player_page.dart';
import 'package:tak22_audio/src/presentation/pages/main/widget/audio_card.dart';
import 'package:tak22_audio/src/presentation/pages/main/widget/download_button.dart';
import '../../../domain/entities/audio_entity.dart';
import '../../bloc/audio_bloc.dart';
import '../audio_player/bloc/audio_player_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Ошибка: $errorMessage')),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Слушаем AudioPlayerBloc для ошибок воспроизведения
        BlocListener<AudioPlayerBloc, AudioPlayerState>(
          listener: (context, state) {
            if (state.hasError &&
                state.errorMessage != null &&
                state.errorMessage != '') {
              _showErrorSnackBar(state.errorMessage!);
              context.read<AudioPlayerBloc>().add(ErrorStatusAudioEvent());
            }
          },
        ),
        // Слушаем AudioBloc для ошибок загрузки
        BlocListener<AudioBloc, AudioState>(
          listener: (context, state) {
            if (state is AudioReady && state.errorMessage != null) {
              _showErrorSnackBar(state.errorMessage!);
              // Очищаем ошибку после показа
              context.read<AudioBloc>().add(
                InitializeAudioEvent(state.allAudio),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tak22 Audio'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Кнопка очистки поиска
            BlocBuilder<AudioBloc, AudioState>(
              builder: (context, state) {
                if (state is AudioReady && state.isSearching) {
                  return IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<AudioBloc>().add(ClearSearchEvent());
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: _buildPlayerControls(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: [
            // Поисковая строка
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск по названию или исполнителю...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
        onChanged: (query) {
          context.read<AudioBloc>().add(SearchAudioEvent(query));
        },
      ),
    );
  }

  Widget _buildPlayerControls() {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final bloc = context.read<AudioPlayerBloc>();

        if (state.lastAudio != null && state.currentAudio == null) {
          return ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            label: Text(
              "Reload last song...",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              bloc.add(ReloadLastAudiosEvent());
            },
            icon: Icon(Icons.update),
          );
        }

        if (state.currentAudio == null ||
            state.playerStatus == PlayerStatus.initial ||
            state.audioFiles.isEmpty) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerPage(audio: state.currentAudio!),
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Текущий трек
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.music_note, color: Colors.grey[600]),
                  ),
                  title: Text(
                    state.currentAudio?.title ?? 'Нет названия',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    state.currentAudio?.artist ?? 'Неизвестный исполнитель',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      bloc.add(PlayerStopEvent());
                    },
                  ),
                ),

                // Прогресс бар
                if (state.duration.inSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: LinearProgressIndicator(
                      value:
                          state.position.inSeconds / state.duration.inSeconds,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppParser.timeFormatter(state.position),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Spacer(),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 200),
                      child: Text(
                        key: ValueKey(state.duration),
                        AppParser.timeFormatter(state.duration),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Контролы воспроизведения
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: state.audioFiles.length > 1
                          ? () {
                              bloc.add(PreviousAudioEvent());
                            }
                          : null,
                      color: state.audioFiles.length > 1
                          ? Colors.blue
                          : Colors.grey,
                    ),

                    // Кнопка play/pause с загрузкой
                    if (state.isLoading &&
                        state.playerStatus == PlayerStatus.play)
                      Container(
                        width: 48,
                        height: 48,
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          state.playerStatus == PlayerStatus.play
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 48,
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          bloc.add(PlayPauseAudioEvent());
                        },
                      ),

                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: state.audioFiles.length > 1
                          ? () {
                              bloc.add(NextAudioEvent());
                            }
                          : null,
                      color: state.audioFiles.length > 1
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final playerBloc = context.read<AudioPlayerBloc>();

        return BlocBuilder<AudioBloc, AudioState>(
          builder: (context, audioState) {
            final audioBloc = context.read<AudioBloc>();

            // Инициализируем AudioBloc когда загружены аудио
            if (playerState.fetchStatus == FetchStatus.success &&
                audioState is AudioInitial) {
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

            // Получаем список аудио для отображения
            List<AudioMetadataEntity> displayAudio = [];
            if (audioState is AudioReady) {
              displayAudio = audioState.audioList;
            } else if (playerState.fetchStatus == FetchStatus.success) {
              displayAudio = playerState.audioFiles;
            }

            // Состояние успеха но пустой список
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
                      if (!isCurrent) {
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
