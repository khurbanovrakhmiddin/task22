import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_player_bloc.dart';

class ControlButtons extends StatelessWidget {
  final Widget leading;
  final Widget trailing;


  const ControlButtons({super.key,   this.leading = const SizedBox.shrink(),   this.trailing =   const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      buildWhen: (previous, current) {
        return previous.playerStatus != current.playerStatus ||
            previous.currentAudio != current.currentAudio;
      },
      builder: (context, state) {
        final bool hasPrevious = state.currentIndex != 0;
        final bool hasNext =
            state.currentIndex < state.audioFiles.length - 1 || state.reverse;
        final bool isPlaying = state.playerStatus == PlayerStatus.play;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            // Кнопка Previous
             IconButton(
              icon: const Icon(Icons.skip_previous, size: 36),
              onPressed: hasPrevious
                  ? () => context.read<AudioPlayerBloc>().add(
                      PreviousAudioEvent(),
                    )
                  : null,
              color: hasPrevious ? Colors.grey : Colors.white,
            ),
            const SizedBox(width: 4),

            // Кнопка Play/Pause
            IconButton(
              splashRadius: 2,
              icon: AnimatedScale(
                scale: 1.4,
                duration: Durations.short3,
                child: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 72,
                ),
              ),
              onPressed: state.currentAudio != null
                  ? () => context.read<AudioPlayerBloc>().add(
                      PlayPauseAudioEvent(),
                    )
                  : null,
              color: state.currentAudio != null
                  ? Color(0xff3B45EF)
                  : Colors.grey[800],
            ),
            const SizedBox(width: 4),

            // Кнопка Next
            IconButton(
              icon: const Icon(Icons.skip_next, size: 36),
              onPressed: hasNext
                  ? () => context.read<AudioPlayerBloc>().add(NextAudioEvent())
                  : null,
              color: hasNext ? Colors.white : Colors.grey,
            ),
            trailing
          ],
        );
      },
    );
  }
}
