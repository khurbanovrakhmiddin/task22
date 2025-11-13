import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/widget/player_buttons.dart';
import 'package:tak22_audio/src/presentation/pages/main/widget/download_button.dart';

import '../../../../core/utils/app_image.dart';

class PlayerPage extends StatefulWidget {
  final AudioMetadataEntity audio;

  const PlayerPage({super.key, required this.audio});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Text(state.currentAudio?.title ?? "Unknown");
          },
        ),
        actions: [DownloadButton(audio: widget.audio)],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                builder: (context, state) {
                  return AppImage(
                    width: 300,
                    fit: BoxFit.fill,
                    image: state.currentAudio?.artUri,
                  );
                },
              ),
            ),
            Spacer(),
            PlayerControls(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
