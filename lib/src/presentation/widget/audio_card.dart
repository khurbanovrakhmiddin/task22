import 'package:flutter/material.dart';
import 'package:tak22_audio/core/utils/app_image.dart';
import 'package:tak22_audio/core/utils/parser.dart';
import 'package:tak22_audio/src/domain/entities/audio_entity.dart';

class AudioCard extends StatelessWidget {
  final AudioMetadataEntity audio;
  final bool isLoadingCurrent;
  final bool isCurrent;
  final Widget icon;
  final void Function() onTap;

  const AudioCard({
    super.key,
    required this.audio,
    required this.isLoadingCurrent,
    required this.isCurrent,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        splashColor: Colors.green,
        onTap: onTap,
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: double.infinity,
                  color: isCurrent ? Colors.white : Colors.grey[600],
                  child: AppImage(
                    image: audio.artUri,
                    errorWidget: Icon(
                      Icons.music_note,
                      size: 42,
                      color: isCurrent ? Colors.deepPurple : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 26),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        audio.title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,

                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Flexible(
                      child: Text(
                        audio.artist ?? 'Неизвестный исполнитель',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    //II Variant
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      color: isCurrent ? Colors.blue[50] : null,
      child: ListTile(
        onTap: onTap,
        leading: isLoadingCurrent
            ? Container(
                width: 40,
                height: 40,
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : CircleAvatar(
                backgroundColor: isCurrent ? Colors.blue : Colors.grey[300],
                child: AppImage(
                  image: audio.artUri,
                  errorWidget: Icon(
                    Icons.music_note,
                    color: isCurrent ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
        title: Text(
          audio.title,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          audio.artist ?? 'Неизвестный исполнитель',
          style: TextStyle(
            color: isCurrent ? Colors.blue[700] : Colors.grey[600],
          ),
        ),
        trailing: isLoadingCurrent
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon,
      ),
    );
  }
}
