import 'package:starmusicshare/models/extracted_media.dart';
import 'package:uri/uri.dart';

class StarmakerExtractor {
  static ExtractedMedia? extractMedia(String url) {
    try {
      final uri = Uri.parse(url);
      final recordingId = uri.queryParameters['recordingId'];

      if (recordingId != null && recordingId.isNotEmpty) {
        final audioUrl =
            'https://static.smintro.com/production/uploading/recordings/$recordingId/master.mp4';
        final thumbnailUrl =
            'https://static.smintro.com/production/uploading/recordings/$recordingId/master.jpg';
        
        return ExtractedMedia(audioUrl: audioUrl, thumbnailUrl: thumbnailUrl);
      }
      return null;
    } catch (e) {
      // Log the error for debugging purposes
      print('Error extracting media: $e');
      return null;
    }
  }
}
