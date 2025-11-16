// ignore_for_file: unused_import, deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:starmusicshare/providers/app_provider.dart';
import 'package:starmusicshare/widgets/audio_player_widget.dart';

class ResultScreen extends StatelessWidget {
  final String audioPath;
  final String songTitle;
  final String? thumbnailUrl;

  const ResultScreen({
    super.key,
    required this.audioPath,
    required this.songTitle,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Complete'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  thumbnailUrl!,
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.music_note,
                      size: 100,
                      color: Colors.white24,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 180,
                      width: 180,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Text(
              songTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            AudioPlayerWidget(audioPath: audioPath),
            const Spacer(),
            _buildShareButton(
              context: context,
              icon: Icons.send,
              label: 'Send to WhatsApp',
              onPressed: () {
                Share.shareXFiles(
                  [XFile(audioPath)],
                  text: 'Shared from StarMusicShare',
                );
              },
            ),
            const SizedBox(height: 16),
            _buildShareButton(
              context: context,
              icon: Icons.video_call,
              label: 'Set WhatsApp Status',
              onPressed: () async {
                // Show a loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Dialog(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 20),
                            Text("Creating video..."),
                          ],
                        ),
                      ),
                    );
                  },
                );

                final videoPath = await appProvider.generateVideoForStatus();
                Navigator.of(context).pop(); // Close the dialog

                if (videoPath != null) {
                  Share.shareXFiles([
                    XFile(videoPath),
                  ], text: 'Status from StarMusicShare');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Failed to create video. Please try again.',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildShareButton(
              context: context,
              icon: Icons.save_alt,
              label: 'Save or Share',
              onPressed: () {
                // This opens the native share sheet, allowing the user to save to device
                // or share with any other app.
                Share.shareXFiles([XFile(audioPath)]);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
