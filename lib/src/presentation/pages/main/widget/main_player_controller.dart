import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/parser.dart';
import '../../../../domain/entities/audio_entity.dart';
import '../../audio_player/bloc/audio_player_bloc.dart';
import '../../audio_player/player_page.dart';

class BuildMainPlayerController extends StatelessWidget {
  const BuildMainPlayerController({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final bloc = context.read<AudioPlayerBloc>();

        final AudioMetadataEntity? audioToShow =
            state.currentAudio ?? state.lastAudio;

        final shouldHidePlayer =
            audioToShow == null ||
            (state.playerStatus == PlayerStatus.initial &&
                state.lastAudio == null) ||
            state.audioFiles.isEmpty;

        if (shouldHidePlayer) {
          return const SizedBox.shrink();
        }
        final isLastAudioMode =
            state.currentAudio == null && state.lastAudio != null;

        return GestureDetector(
          onTap: () => isLastAudioMode
              ? null
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerPage(audio: audioToShow),
                  ),
                ),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrackInfo(audioToShow, bloc, state),

                if (state.duration.inSeconds > 0) _buildProgressBar(state),

                _buildTimeDisplay(state),

                const SizedBox(height: 8),

                _buildPlayerControls(state, bloc, audioToShow),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackInfo(
    AudioMetadataEntity audio,
    AudioPlayerBloc bloc,
    AudioPlayerState state,
  ) {
    final isLastAudioMode =
        state.currentAudio == null && state.lastAudio != null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: Image.asset(audio.artUri!,fit: BoxFit.contain,),
      ),
      title: Text(
        audio.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            audio.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          ),
          if (isLastAudioMode)
            Text(
              'Last audio...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          bloc.add(PlayerStopEvent());
        },
      ),
    );
  }

  Widget _buildProgressBar(AudioPlayerState state) {
    final progressValue = state.duration.inSeconds > 0
        ? state.position.inSeconds / state.duration.inSeconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildTimeDisplay(AudioPlayerState state) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppParser.timeFormatter(state.position),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                key: ValueKey(state.duration),
                AppParser.timeFormatter(state.duration),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerControls(
    AudioPlayerState state,
    AudioPlayerBloc bloc,
    AudioMetadataEntity audio,
  ) {
    final hasMultipleTracks = state.audioFiles.length > 1;
    final isLastAudioMode =
        state.currentAudio == null && state.lastAudio != null;
    final isLoading =
        state.isLoading && state.playerStatus == PlayerStatus.play;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: (hasMultipleTracks && !isLastAudioMode)
              ? () => bloc.add(PreviousAudioEvent())
              : null,
          color: (hasMultipleTracks && !isLastAudioMode)
              ? Colors.white
              : Colors.grey,
        ),

        _buildMainControlButton(state, bloc, isLoading, isLastAudioMode),

        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (hasMultipleTracks && !isLastAudioMode)
              ? () => bloc.add(NextAudioEvent())
              : null,
          color: (hasMultipleTracks && !isLastAudioMode)
              ? Colors.white
              : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildMainControlButton(
    AudioPlayerState state,
    AudioPlayerBloc bloc,
    bool isLoading,
    bool isLastAudioMode,
  ) {
    if (isLoading) {
      return Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(strokeWidth: 3),
      );
    }

    if (isLastAudioMode) {
      return IconButton(
        icon: const Icon(Icons.replay_circle_filled, size: 48),
        color: Colors.white,
        onPressed: () {
          bloc.add(ReloadLastAudiosEvent());
        },
      );
    }

    return IconButton(
      icon: Icon(
        state.playerStatus == PlayerStatus.play
            ? Icons.pause_circle_filled
            : Icons.play_circle_filled,
        size: 56,
      ),
      color: const Color(0xff3B45EF),
      onPressed: () {
        bloc.add(PlayPauseAudioEvent());
      },
    );
  }
}
