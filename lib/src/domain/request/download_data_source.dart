import 'dart:async';
import 'dart:io';

abstract class DownloadLocalDataSource {
  Future<void> copyAssetToLocal(String assetPath, String fileName, String audioId);
  Stream<Map<String, double>> get progressStream;
  Future<bool> fileExists(String fileName);
  Future<void> deleteFile(String fileName);
  Future<String> getFilePath(String fileName);
  bool isAssetPath(String path);
  Future<List<String>> getDownloadedFiles();
  Future<FileStat?> getFileInfo(String fileName);
  Future<int?> getFileSize(String fileName);
}