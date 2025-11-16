import 'package:dio/dio.dart';

class Downloader {
  final Dio _dio = Dio();

  Future<String?> downloadFile(
    String url,
    String savePath,
    Function(double) onReceiveProgress,
  ) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onReceiveProgress(received / total);
          }
        },
      );
      return savePath;
    } catch (e) {
      rethrow;
    }
  }
}
