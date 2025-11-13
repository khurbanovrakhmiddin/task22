import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';

import '../../../../../core/utils/parser.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          _Shuffle(),
          const SizedBox(height: 8),
          _ProgressBar(),
          const SizedBox(height: 16),
          // Кнопки управления с отдельным BlocBuilder
          _ControlButtons(),
        ],
      ),
    );
  }


}


class _Shuffle extends StatelessWidget {
  const _Shuffle();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () {
          context.read<AudioPlayerBloc>().add(ShuffleOnOFEvent());
        },
        icon: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          buildWhen: (prev, cur) => prev.shuffle != cur.shuffle,

          builder: (context, state) {
            return Icon(
              Icons.shuffle,
              color: state.shuffle ? Colors.green : null,
            );
          },
        ),
      ),
    );
  }
}

class _ProgressBar extends StatefulWidget {
  @override
  State<_ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<_ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Duration _currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        return previous.position != current.position ||
            previous.duration != current.duration ||
            previous.currentAudio?.id != current.currentAudio?.id;
      },
      builder: (context, state) {
        final position = state.position;

        // Плавное обновление duration
        if (state.duration != Duration.zero &&
            state.duration != _currentDuration) {
          _currentDuration = state.duration;
        }

        final progress = _currentDuration.inMilliseconds > 0
            ? position.inMilliseconds / _currentDuration.inMilliseconds
            : 0.0;

        return Column(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    // Не вызываем сразу
                  },
                  onChangeEnd: (value) {
                    final newPosition = _currentDuration * value;
                    context.read<AudioPlayerBloc>().add(
                      SeekAudioEvent(newPosition),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppParser.timeFormatter(position),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Text(
                      key: ValueKey(state.duration),
                      AppParser.timeFormatter(state.duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ControlButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        // Перестраиваем только когда меняется состояние воспроизведения
        return previous.playerStatus != current.playerStatus ||
            previous.currentAudio != current.currentAudio;
      },
      builder: (context, state) {
        final bool hasPrevious = state.currentIndex != 0;
        final bool hasNext = state.currentIndex < state.audioFiles.length;
        final bool isPlaying = state.playerStatus == PlayerStatus.play;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка Previous
            IconButton(
              icon: const Icon(Icons.skip_previous, size: 32),
              onPressed: hasPrevious
                  ? () => context.read<AudioPlayerBloc>().add(
                      PreviousAudioEvent(),
                    )
                  : null,
              color: hasPrevious ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 16),

            // Кнопка Play/Pause
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 48,
              ),
              onPressed: state.currentAudio != null
                  ? () => context.read<AudioPlayerBloc>().add(
                      PlayPauseAudioEvent(),
                    )
                  : null,
              color: state.currentAudio != null ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 16),

            // Кнопка Next
            IconButton(
              icon: const Icon(Icons.skip_next, size: 32),
              onPressed: hasNext
                  ? () => context.read<AudioPlayerBloc>().add(NextAudioEvent())
                  : null,
              color: hasNext ? Colors.blue : Colors.grey,
            ),
          ],
        );
      },
    );
  }
}
