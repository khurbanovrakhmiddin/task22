import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';

class Shuffle extends StatelessWidget {
  const Shuffle({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<AudioPlayerBloc>().add(ShuffleOnOFEvent());
      },
      icon: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        buildWhen: (prev, cur) => prev.shuffle != cur.shuffle,

        builder: (context, state) {
          return Icon(
            Icons.shuffle,
            color: state.shuffle ?  const Color(0xff3b45ef) : Colors.white,
          );
        },
      ),
    );
  }
}

class Reverse extends StatelessWidget {
  const Reverse({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<AudioPlayerBloc>().add(ReverseAudioEvent());
      },
      icon: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        buildWhen: (prev, cur) => prev.reverse != cur.reverse,

        builder: (context, state) {
          return Icon(
             state.reverse ? Icons.repeat_one : Icons.repeat_outlined,
            color: state.reverse ? const Color(0xff3b45ef) : Colors.white,
          );
        },
      ),
    );
  }
}
