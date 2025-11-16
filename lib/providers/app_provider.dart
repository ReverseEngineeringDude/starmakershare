import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starmusicshare/services/downloader.dart';
import 'package:starmusicshare/models/extracted_media.dart';
import 'package:starmusicshare/services/starmaker_extractor.dart';
import 'package:starmusicshare/services/video_generator.dart';

enum AppState { idle, processing, success, error }

class AppProvider extends ChangeNotifier {
  AppState _state = AppState.idle;
  String _statusMessage = 'Waiting for shared content...';
  String? _errorMessage;
  double _downloadProgress = 0.0;
  String? _audioFilePath;
  String? _songTitle;
  String? _thumbnailUrl;

  AppState get state => _state;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  double get downloadProgress => _downloadProgress;
  String? get audioFilePath => _audioFilePath;
  String? get songTitle => _songTitle;
  String? get thumbnailUrl => _thumbnailUrl;

  final Downloader _downloader = Downloader();
  final VideoGenerator _videoGenerator = VideoGenerator();

  Future<void> processSharedUrl(String url) async {
    try {
      _state = AppState.processing;
      _statusMessage = 'Inspecting URL...';
      _downloadProgress = 0.0;
      _thumbnailUrl = null;
      notifyListeners();

      final starmakerUrl = _extractUrl(url);
      if (starmakerUrl == null) {
        throw Exception('This does not seem to be a valid StarMaker URL.');
      }

      _statusMessage = 'Extracting media source...';
      notifyListeners();

      final media = StarmakerExtractor.extractMedia(starmakerUrl);
      if (media == null) {
        throw Exception('Could not find a media source in the URL. Please ensure it is a recorded song link.');
      }
      _thumbnailUrl = media.thumbnailUrl;

      _songTitle = _extractTitle(url) ?? 'Unknown Song';
      _statusMessage = 'Downloading: $_songTitle';
      notifyListeners();

      final dir = await getApplicationDocumentsDirectory();
      // Use a more specific file extension based on the URL
      final fileExtension = media.audioUrl.endsWith('.mp4') ? 'mp4' : 'mp3';
      final fileName = '${_songTitle!.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.$fileExtension';
      final savePath = '${dir.path}/$fileName';

      _audioFilePath = await _downloader.downloadFile(media.audioUrl, savePath, (progress) {
        _downloadProgress = progress;
        notifyListeners();
      });

      _state = AppState.success;
      _statusMessage = 'Download complete!';
      notifyListeners();
    } catch (e) {
      _state = AppState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<String?> generateVideoForStatus() async {
    if (_audioFilePath == null) return null;

    _state = AppState.processing;
    _statusMessage = 'Creating video for status...';
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final videoPath = '${dir.path}/status_video.mp4';
      
      // Check if video already exists
      if(await File(videoPath).exists()) {
        await File(videoPath).delete();
      }

      final generatedPath = await _videoGenerator.createVideo(
        'assets/bg.jpg',
        _audioFilePath!,
        videoPath,
      );

      if (generatedPath != null) {
        _statusMessage = 'Video created!';
        _state = AppState.success;
        notifyListeners();
        return generatedPath;
      } else {
        throw Exception('Failed to generate video.');
      }
    } catch (e) {
      _state = AppState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  String? _extractUrl(String text) {
    final urlRegExp = RegExp(r'https?://[^\s]+');
    final match = urlRegExp.firstMatch(text);
    return match?.group(0);
  }

  String? _extractTitle(String text) {
    // Extract title between '#' symbols
    final titleRegExp = RegExp(r'#([^#]+)#');
    final match = titleRegExp.firstMatch(text);
    if (match != null && match.groupCount > 0) {
      return match.group(1);
    }

    // Fallback to a simple extraction if regex fails
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines[0];
    }
    return null;
  }

  void reset() {
    _state = AppState.idle;
    _statusMessage = 'Waiting for shared content...';
    _errorMessage = null;
    _downloadProgress = 0.0;
    _audioFilePath = null;
    _songTitle = null;
    _thumbnailUrl = null;
    notifyListeners();
  }
}