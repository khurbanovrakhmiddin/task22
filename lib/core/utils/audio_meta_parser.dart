import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import '../../src/domain/entities/audio_entity.dart';

class MP3MetadataParser {
  static Future<AudioMetadataEntity> parseMetadata(
    String assetPath,
    String id,
  ) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      // Для отладки
      debugID3Frames(bytes);

      final metadata = await _parseID3v2(bytes);

      return AudioMetadataEntity(
        id: id,
        title: metadata['title'] ?? _getTitleFromPath(assetPath),
        artist: metadata['artist']??'',
        album: metadata['album'],
        assetPath: assetPath,
      );
    } catch (e) {
      print('Error parsing metadata for $assetPath: $e');
      return AudioMetadataEntity(
        id: id,
        title: _getTitleFromPath(assetPath),
        assetPath: assetPath,
      );
    }
  }

  static Future<Uint8List?> _extractAlbumArt(Uint8List bytes) async {
    try {
      int position = 10;

      while (position < bytes.length - 14) {
        final frameId = String.fromCharCodes(
          bytes.sublist(position, position + 4),
        );

        if (frameId == 'APIC') {
          print('Found APIC frame at position $position');
          position += 4;

          final frameSize = _syncSafeToInt(
            bytes.sublist(position, position + 4),
          );
          position += 4;
          position += 2; // flags

          if (frameSize <= 0 || position + frameSize > bytes.length) {
            print('Invalid frame size: $frameSize');
            return null;
          }

          final frameData = bytes.sublist(position, position + frameSize);
          final imageData = _parseAPICFrame(frameData);

          if (imageData != null) {
            print(
              'Successfully extracted album art: ${imageData.length} bytes',
            );
            return imageData;
          }
        }
        position++;
      }

      print('No APIC frame found');
      return null;
    } catch (e) {
      print('Error extracting album art: $e');
      return null;
    }
  }

  static Uint8List? _parseAPICFrame(Uint8List data) {
    try {
      int offset = 0;

      // Text encoding (1 byte)
      if (offset >= data.length) return null;
      final encoding = data[offset];
      offset++;

      // MIME type (null-terminated string)
      while (offset < data.length && data[offset] != 0) {
        offset++;
      }
      offset++; // skip null terminator

      // Picture type (1 byte)
      if (offset >= data.length) return null;
      final pictureType = data[offset];
      offset++;

      print('Picture type: $pictureType');

      // Description (null-terminated string)
      while (offset < data.length && data[offset] != 0) {
        offset++;
      }
      offset++; // skip null terminator

      // Remaining data is the image
      if (offset < data.length) {
        final imageData = data.sublist(offset);
        print('Extracted image data: ${imageData.length} bytes');

        // Проверяем сигнатуры форматов
        if (_isValidImage(imageData)) {
          return imageData;
        } else {
          print('Invalid image data format');
        }
      }
    } catch (e) {
      print('Error parsing APIC frame: $e');
    }

    return null;
  }

  static bool _isValidImage(Uint8List data) {
    if (data.length < 8) return false;

    // Проверяем JPEG
    if (data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
      print('JPEG image detected');
      return true;
    }

    // Проверяем PNG
    if (data[0] == 0x89 &&
        data[1] == 0x50 &&
        data[2] == 0x4E &&
        data[3] == 0x47) {
      print('PNG image detected');
      return true;
    }

    // Проверяем GIF
    if (data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46) {
      print('GIF image detected');
      return true;
    }

    print('Unknown image format');
    return false;
  }

  static Future<ui.Image> _bytesToImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  static void debugID3Frames(Uint8List bytes) {
    try {
      if (bytes.length < 10) return;

      final header = String.fromCharCodes(bytes.sublist(0, 3));
      if (header != 'ID3') return;

      final tagSize = _syncSafeToInt(bytes.sublist(6, 10));
      int position = 10;

      print('=== ID3 Tag Debug ===');
      print('Tag size: $tagSize bytes');

      while (position < bytes.length - 10 && position < tagSize + 10) {
        if (position + 10 >= bytes.length) break;

        final frameId = String.fromCharCodes(
          bytes.sublist(position, position + 4),
        );
        position += 4;

        if (position + 4 >= bytes.length) break;
        final frameSize = _syncSafeToInt(bytes.sublist(position, position + 4));
        position += 4;
        position += 2; // flags

        if (frameSize <= 0 || position + frameSize > bytes.length) break;

        final frameData = bytes.sublist(position, position + frameSize);

        print('Frame: $frameId, Size: $frameSize');

        if (frameData.isNotEmpty) {
          final rawText = String.fromCharCodes(frameData);
          print('Raw data: ${rawText.substring(0, min(50, rawText.length))}');

          final decodedText = _decodeTextFrame(frameData);
          if (decodedText.isNotEmpty) {
            print('Decoded: $decodedText');
          }
        }

        print('---');
        position += frameSize;
      }
    } catch (e) {
      print('Debug error: $e');
    }
  }

  static Future<Map<String, String>> _parseID3v2(Uint8List bytes) async {
    final metadata = <String, String>{};

    if (bytes.length < 10) return metadata;

    // Проверяем ID3v2 tag
    final header = String.fromCharCodes(bytes.sublist(0, 3));
    if (header != 'ID3') {
      return metadata;
    }

    try {
      final majorVersion = bytes[3];
      final minorVersion = bytes[4];

      print('ID3v2.$majorVersion.$minorVersion detected');

      final tagSize = _syncSafeToInt(bytes.sublist(6, 10));
      int position = 10;

      while (position < bytes.length - 10 && position < tagSize + 10) {
        if (position + 10 >= bytes.length) break;

        final frameId = String.fromCharCodes(
          bytes.sublist(position, position + 4),
        );

        // Проверяем валидность frame ID
        if (!_isValidFrameId(frameId)) {
          break;
        }

        position += 4;

        if (position + 4 >= bytes.length) break;

        int frameSize;
        if (majorVersion == 3) {
          // ID3v2.3 - 4 байта обычного размера
          frameSize = _bytesToInt32(bytes.sublist(position, position + 4));
        } else {
          // ID3v2.4 - sync-safe размер
          frameSize = _syncSafeToInt(bytes.sublist(position, position + 4));
        }

        position += 4;

        // Пропускаем флаги (2 байта)
        if (position + 2 >= bytes.length) break;
        position += 2;

        if (frameSize <= 0 || position + frameSize > bytes.length) {
          break;
        }

        final frameData = bytes.sublist(position, position + frameSize);

        // Парсим текстовые фреймы
        if (frameId.startsWith('T') && frameId != 'TXXX') {
          final text = _decodeTextFrame(frameData);
          if (text.isNotEmpty) {
            print('Found $frameId: $text');
            switch (frameId) {
              case 'TIT2':
                metadata['title'] = text;
                break;
              case 'TT2':
                metadata['title'] = text;
                break; // Альтернативный ID
              case 'TPE1':
                metadata['artist'] = text;
                break;
              case 'TP1':
                metadata['artist'] = text;
                break; // Альтернативный ID
              case 'TALB':
                metadata['album'] = text;
                break;
              case 'TAL':
                metadata['album'] = text;
                break; // Альтернативный ID
              case 'TYER':
                metadata['year'] = text;
                break;
              case 'TYE':
                metadata['year'] = text;
                break; // Альтернативный ID
              case 'TCON':
                metadata['genre'] = text;
                break;
              case 'TCO':
                metadata['genre'] = text;
                break; // Альтернативный ID
            }
          }
        }

        position += frameSize;
      }
    } catch (e) {
      print('Error parsing ID3v2 tag: $e');
    }

    return metadata;
  }

  static bool _isValidFrameId(String frameId) {
    // Проверяем, что frame ID состоит из букв и цифр
    return frameId.length == 4 &&
        frameId.codeUnits.every(
          (code) =>
              (code >= 65 && code <= 90) || // A-Z
              (code >= 48 && code <= 57), // 0-9
        );
  }

  static int _bytesToInt32(List<int> bytes) {
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }

  static String _decodeTextFrame(Uint8List data) {
    if (data.isEmpty) return '';

    try {
      final encoding = data[0];
      final textData = data.sublist(1);

      if (encoding == 0) {
        // ISO-8859-1 / Latin-1
        return String.fromCharCodes(textData);
      } else if (encoding == 1) {
        // UTF-16 with BOM
        return _decodeUtf16WithBOM(textData);
      } else if (encoding == 2) {
        // UTF-16BE without BOM
        return _decodeUtf16BE(textData);
      } else if (encoding == 3) {
        // UTF-8
        return String.fromCharCodes(textData);
      }

      // По умолчанию пытаемся как UTF-8
      return String.fromCharCodes(textData);
    } catch (e) {
      print('Error decoding text frame: $e');
      return '';
    }
  }

  static String _decodeUtf16WithBOM(Uint8List data) {
    try {
      if (data.length < 2) return '';

      // Проверяем BOM (Byte Order Mark)
      final bom = (data[0] << 8) | data[1];

      if (bom == 0xFEFF) {
        // Big Endian
        return _decodeUtf16BE(data.sublist(2));
      } else if (bom == 0xFFFE) {
        // Little Endian
        return _decodeUtf16LE(data.sublist(2));
      } else {
        // Нет BOM, пробуем оба варианта
        final resultBE = _decodeUtf16BE(data);
        if (resultBE.isNotEmpty) return resultBE;
        return _decodeUtf16LE(data);
      }
    } catch (e) {
      return _decodeUtf16Simple(data);
    }
  }

  static String _decodeUtf16BE(Uint8List data) {
    try {
      if (data.length % 2 != 0) return '';

      final codes = List<int>.generate(
        data.length ~/ 2,
        (i) => (data[i * 2] << 8) | data[i * 2 + 1],
      );

      return String.fromCharCodes(codes);
    } catch (e) {
      return '';
    }
  }

  static String _decodeUtf16LE(Uint8List data) {
    try {
      if (data.length % 2 != 0) return '';

      final codes = List<int>.generate(
        data.length ~/ 2,
        (i) => (data[i * 2 + 1] << 8) | data[i * 2],
      );

      return String.fromCharCodes(codes);
    } catch (e) {
      return '';
    }
  }

  // Простой декодер как запасной вариант
  static String _decodeUtf16Simple(Uint8List data) {
    try {
      // Удаляем возможные нулевые байты
      final cleanData = data.where((byte) => byte != 0).toList();
      return String.fromCharCodes(cleanData);
    } catch (e) {
      return '';
    }
  }

  static int _syncSafeToInt(List<int> bytes) {
    return (bytes[0] << 21) | (bytes[1] << 14) | (bytes[2] << 7) | bytes[3];
  }

  static String _getTitleFromPath(String path) {
    final fileName = path.split('/').last;
    return fileName.replaceAll('.mp3', '');
  }
}
