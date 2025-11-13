// data/datasource/download_local_data_source_impl.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/request/download_data_source.dart';

class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  final StreamController<Map<String, double>> _progressController =
  StreamController<Map<String, double>>.broadcast();
  final Map<String, double> _progressMap = {};

  @override
  Stream<Map<String, double>> get progressStream => _progressController.stream;

  @override
  Future<void> copyAssetToLocal(String assetPath, String fileName, String audioId) async {
    try {
      _updateProgress(audioId, 0.1);

      // Проверяем разрешения и т.д.
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('Разрешение на доступ к хранилищу не предоставлено');
      }      await Future.delayed(Duration(milliseconds: 300));


      if (await fileExists(fileName)) {
        _updateProgress(audioId, 1.0);
        return;
      }
      await Future.delayed(Duration(milliseconds: 300));

      _updateProgress(audioId, 0.3);
      await Future.delayed(Duration(milliseconds: 300));

      final byteData = await rootBundle.load(assetPath);
      _updateProgress(audioId, 0.5);
      await Future.delayed(Duration(milliseconds: 300));

      final filePath = await _getLocalFilePath(fileName);
      final file = File(filePath);

      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      _updateProgress(audioId, 0.7);
      await Future.delayed(Duration(milliseconds: 300));

      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));
      _updateProgress(audioId, 0.9);

      if (await file.exists()) {
        _updateProgress(audioId, 1.0);
        await Future.delayed(Duration(seconds: 2));
        _updateProgress(audioId, -1.0);
      } else {
        throw Exception('Файл не был создан');
      }

    } catch (e) {
      _updateProgress(audioId, 0.0);
      rethrow;
    }
  }

  void _updateProgress(String audioId, double progress) {
    _progressMap[audioId] = progress;
    _progressController.add(Map<String, double>.from(_progressMap));
  }

  @override
  Future<bool> fileExists(String fileName) async {
    try {
      final filePath = await _getLocalFilePath(fileName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteFile(String fileName) async {
    final filePath = await _getLocalFilePath(fileName);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<String> getFilePath(String fileName) async {
    return await _getLocalFilePath(fileName);
  }

  @override
  bool isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  Future<String> _getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<bool> _checkAndRequestPermissions() async {
    // Ваша логика проверки разрешений
    return true;
  }

  // Остальные методы...
  @override
  Future<List<String>> getDownloadedFiles() async {
    // implementation
    return [];
  }

  @override
  Future<FileStat?> getFileInfo(String fileName) async {
    // implementation
    return null;
  }

  @override
  Future<int?> getFileSize(String fileName) async {
    // implementation
    return null;
  }

  void dispose() {
    _progressController.close();
  }
}