import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class VideoGenerator {
  Future<String?> createVideo(
    String imageAssetName,
    String audioPath,
    String outputPath,
  ) async {
    try {
      // We need to get the image from assets and write it to a temporary file
      // because FFmpeg works with file paths.
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/bg.jpg';
      
      final byteData = await rootBundle.load(imageAssetName);
      final buffer = byteData.buffer.asUint8List();
      await File(imagePath).writeAsBytes(buffer);

      // FFmpeg command to loop a static image with audio
      final command =
          '-r 1 -loop 1 -i "$imagePath" -i "$audioPath" -c:v libx264 -preset ultrafast -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        // You can log the error for debugging
        // final logs = await session.getAllLogsAsString();
        // print(logs);
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
