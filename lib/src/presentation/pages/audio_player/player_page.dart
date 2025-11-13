import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/bloc/audio_player_bloc.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/widget/controls_button.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/widget/progress_bar.dart';
import 'package:tak22_audio/src/presentation/pages/audio_player/widget/shuffle_button.dart';
import 'package:tak22_audio/src/presentation/widget/download_button.dart';

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
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
        title: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            return Text(
              state.currentAudio?.artist ?? "Unknown",
              style: TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
                buildWhen: (prev, cur) => prev.currentIndex != cur.currentIndex,
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
            Padding(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      const SizedBox(width: 16),
                      BlocBuilder<AudioPlayerBloc,AudioPlayerState>(
                          buildWhen: (prev, cur) => prev.currentIndex != cur.currentIndex,
                          builder: (context,state){
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.currentAudio?.title??'',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                state.currentAudio?.artist??'',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      DownloadButton(audio: widget.audio, size: 24),
                    ],
                  ),

                  const SizedBox(height: 8),
                  ProgressBar(),
                  const SizedBox(height: 16),
                  ControlButtons(leading: Reverse(), trailing: Shuffle()),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
