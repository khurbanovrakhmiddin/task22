import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audio_entity.dart';
import '../bloc/audio_bloc.dart';

class DownloadButton extends StatelessWidget {
  final AudioMetadataEntity audio;
  final double size;

  const DownloadButton({super.key, required this.audio, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) =>
          previous.downloadProgress[audio.id] !=
          current.downloadProgress[audio.id],
      builder: (context, state) {
        final progress = state.downloadProgress[audio.id] ?? 0.0;
        final isDownloaded = progress == 1.0;
        final isLoading = state.isLoading || progress > 0.0 && progress < 1.0;
        if (isLoading) {
          return _buildProgress(progress);
        }

        return Visibility(
          visible: !isLoading,
          replacement: _buildProgress(progress),
          child: IconButton(
            icon: Icon(
              isDownloaded ? Icons.download_done : Icons.download,
              size: size,
              color: isDownloaded ? const Color(0xff3b45ef) : Colors.white,
            ),
            onPressed: () => _onPressed(context, isDownloaded),
            tooltip: isDownloaded ? 'Удалить' : 'Скачать',
          ),
        );
      },
    );
  }

  Widget _buildProgress(double progress) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        color: const Color(0xff3b45ef),
        value: progress,
        strokeWidth: 2,
      ),
    );
  }

  void _onPressed(BuildContext context, bool isDownloaded) {
    if (isDownloaded) {
      context.read<AudioBloc>().add(DeleteAudioEvent(audio));
    } else {
      context.read<AudioBloc>().add(DownloadAudioEvent(audio));
    }
  }
}
