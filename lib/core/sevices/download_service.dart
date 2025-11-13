import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  final StreamController<Map<String, double>> _progressController =
  StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream => _progressController.stream;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> _getLocalFilePath(String fileName) async {
    final path = await _localPath;
    return '$path/$fileName';
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Для Android 13+ (API 33+) используем управление медиа файлами
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Запрашиваем разрешение на управление внешним хранилищем
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        return true;
      }

      // Если manageExternalStorage не дали, пробуем storage
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    // Для iOS всегда возвращаем true (там другие разрешения)
    return true;
  }

  Future<bool> _checkAndRequestPermissions() async {
    try {
      // Проверяем и запрашиваем разрешения
      final hasPermission = await _requestStoragePermission();

      if (!hasPermission) {
        // Если разрешения не даны, открываем настройки
        final shouldOpenSettings = await _showPermissionDialog();
        if (shouldOpenSettings) {
          await openAppSettings();
        }
        return false;
      }

      return true;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  Future<bool> _showPermissionDialog() async {
    // Здесь можно показать диалог с объяснением почему нужно разрешение
    // Пока просто возвращаем true чтобы открыть настройки
    return true;
  }

  Future<void> copyAssetToLocal(String assetPath, String fileName, String audioId) async {
    try {
      // Проверяем разрешения перед началом копирования
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('Разрешение на доступ к хранилищу не предоставлено');
      }

      // Проверяем существует ли файл уже
      if (await fileExists(fileName)) {
        _progressController.add({audioId: 1.0});
        return;
      }

      // Читаем asset файл
      final byteData = await rootBundle.load(assetPath);

      // Создаем файл в локальном хранилище
      final filePath = await _getLocalFilePath(fileName);
      final file = File(filePath);

      // Создаем директорию если не существует
      final directory = Directory(filePath).parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Записываем данные
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));

      // Уведомляем о завершении
      _progressController.add({audioId: 1.0});

      print('File copied successfully: $filePath');
    } catch (e) {
      print('Error copying asset: $e');
      throw Exception('Не удалось скопировать файл: $e');
    }
  }

  Future<bool> fileExists(String fileName) async {
    try {
      final filePath = await _getLocalFilePath(fileName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        throw Exception('Разрешение на доступ к хранилищу не предоставлено');
      }

      final filePath = await _getLocalFilePath(fileName);
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $filePath');
      }
    } catch (e) {
      print('Error deleting file: $e');
      throw Exception('Не удалось удалить файл: $e');
    }
  }

  Future<String> getFilePath(String fileName) async {
    try {
      return await _getLocalFilePath(fileName);
    } catch (e) {
      print('Error getting file path: $e');
      throw Exception('Не удалось получить путь к файлу: $e');
    }
  }

  Future<List<String>> getDownloadedFiles() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();
      return files
          .where((entity) => entity is File && entity.path.endsWith('.mp3'))
          .map((entity) => (entity as File).path)
          .toList();
    } catch (e) {
      print('Error getting downloaded files: $e');
      return [];
    }
  }

  bool isAssetPath(String path) {
    return path.startsWith('assets/');
  }

  // Метод для получения информации о файле
  Future<FileStat?> getFileInfo(String fileName) async {
    try {
      final filePath = await _getLocalFilePath(fileName);
      final file = File(filePath);
      if (await file.exists()) {
        return await file.stat();
      }
      return null;
    } catch (e) {
      print('Error getting file info: $e');
      return null;
    }
  }

  // Метод для получения размера файла
  Future<int?> getFileSize(String fileName) async {
    try {
      final fileInfo = await getFileInfo(fileName);
      return fileInfo?.size;
    } catch (e) {
      print('Error getting file size: $e');
      return null;
    }
  }

  void dispose() {
    _progressController.close();
  }
}