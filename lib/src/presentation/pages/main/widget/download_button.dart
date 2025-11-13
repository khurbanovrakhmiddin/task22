import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/audio_entity.dart';
import '../../../bloc/audio_bloc.dart';

class DownloadButton extends StatelessWidget {
  final AudioMetadataEntity audio;
  final double size;
  final Color downloadColor;
  final Color downloadedColor;
  final Color progressColor;

  const DownloadButton({
    super.key,
    required this.audio,
    this.size = 24,
    this.downloadColor = Colors.blue,
    this.downloadedColor = Colors.green,
    this.progressColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      buildWhen: (previous, current) => _shouldRebuild(previous, current, audio.id),
      builder: (context, state) {
        return _buildButtonContent(context, state);
      },
    );
  }

  bool _shouldRebuild(AudioState previous, AudioState current, String audioId) {
    if (previous is AudioReady && current is AudioReady) {
      final prevProgress = previous.downloadProgress[audioId];
      final currProgress = current.downloadProgress[audioId];
      return prevProgress != currProgress;
    }
    return previous.runtimeType != current.runtimeType;
  }

  Widget _buildButtonContent(BuildContext context, AudioState state) {
    if (state is! AudioReady) {
      return _buildDownloadIcon(context, audio, null);
    }

    final progress = state.downloadProgress[audio.id];
    final isDownloaded = progress == 1.0;
    final isLoading = progress != null && progress > 0.0 && progress < 1.0;

    if (isLoading) {
      return _buildProgressIndicator(progress!);
    } else if (isDownloaded) {
      return _buildDownloadedIcon(context, audio);
    } else {
      return _buildDownloadIcon(context, audio, progress);
    }
  }

  Widget _buildProgressIndicator(double progress) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: Colors.grey[300],
          ),
          Text(
            '${(progress * 100).toInt()}',
            style: TextStyle(
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
              color: progressColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedIcon(BuildContext context, AudioMetadataEntity audio) {
    return IconButton(
      icon: Icon(
        Icons.download_done,
        size: size,
      ),
      color: downloadedColor,
      onPressed: () {
        context.read<AudioBloc>().add(DeleteAudioEvent(audio));
      },
      tooltip: 'Удалить загруженный файл',
    );
  }

  Widget _buildDownloadIcon(
      BuildContext context,
      AudioMetadataEntity audio,
      double? progress,
      ) {
    return IconButton(
      icon: Icon(
        Icons.download,
        size: size,
      ),
      color: downloadColor,
      onPressed: () {
        context.read<AudioBloc>().add(DownloadAudioEvent(audio));
      },
      tooltip: progress == null
          ? 'Скачать для офлайн-доступа'
          : 'Продолжить загрузку (${(progress * 100).toInt()}%)',
    );
  }
}