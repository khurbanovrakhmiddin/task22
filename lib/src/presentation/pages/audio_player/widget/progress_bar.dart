import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/parser.dart';
import '../bloc/audio_player_bloc.dart';

class ProgressBar extends StatefulWidget {
  const ProgressBar({super.key});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
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
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey,
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
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Text(
                      key: ValueKey(state.duration),
                      AppParser.timeFormatter(state.duration),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
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
