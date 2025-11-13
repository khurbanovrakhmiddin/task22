import 'package:flutter/services.dart';
import '../../../../core/utils/audio_meta_parser.dart';
import '../../../domain/entities/audio_entity.dart';
import '../../../domain/request/audio_remote_data_source.dart';

class AudioAssetsDataSource implements AudioRemoteDataSource {
  @override
  Future<List<AudioMetadataEntity>> fetchAudios() async {
    try {
      return loadAudioAssetsWithMetadata();
    } catch (_) {

    }
    return [
      const AudioMetadataEntity(
        id: '1',
        title: 'Там Ревели Горы',
        assetPath: 'assets/audio/MiyaGi & Andy Panda - Там Ревели Горы.mp3',
        artist: 'MiyaGi & Andy Panda',
      ),
      const AudioMetadataEntity(
        id: '2',
        title: 'Captain',
        assetPath: 'assets/audio/Miyagi - Captain.mp3',
        artist: 'Miyagi',
      ),
      const AudioMetadataEntity(
        id: '3',
        title: 'Song 3',
        assetPath:
            'https://cdn.bitmovin.com/content/assets/art-of-motion-dash-hls-progressive/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa-audio-only.m3u8',
        artUri:
            'https://cdn.bitmovin.com/content/assets/art-of-motion-dash-hls-progressive/poster.jpg',
        artist: 'Artist 3',
      ),
    ];
  }

  Future<List<AudioMetadataEntity>> loadAudioAssetsWithMetadata() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final allAssets = manifest.listAssets();
    final mp3Files = allAssets
        .where(
          (asset) =>
              asset.startsWith('assets/audio/') && asset.endsWith('.mp3'),
        )
        .toList();

    final List<AudioMetadataEntity> audioList = [];

    for (int i = 0; i < mp3Files.length; i++) {
      final assetPath = mp3Files[i];
      final metadata = await MP3MetadataParser.parseMetadata(
        assetPath,
        i.toString(),
      );
      audioList.add(metadata);
    }

    return audioList;
  }
}
