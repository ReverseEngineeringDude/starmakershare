import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:share_handler/share_handler.dart';
import 'package:starmusicshare/providers/app_provider.dart';
import 'package:starmusicshare/screens/about_screen.dart';
import 'package:starmusicshare/screens/result_screen.dart';

class ShareReceiverScreen extends StatefulWidget {
  const ShareReceiverScreen({super.key});

  @override
  State<ShareReceiverScreen> createState() => _ShareReceiverScreenState();
}

class _ShareReceiverScreenState extends State<ShareReceiverScreen> {
  StreamSubscription? _shareSubscription;

  @override
  void initState() {
    super.initState();
    _initShareHandler();
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initShareHandler() async {
    final handler = ShareHandler.instance;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Handle media that is shared with the app at launch
    final initialMedia = await handler.getInitialSharedMedia();
    if (initialMedia != null) {
      _handleSharedMedia(initialMedia, appProvider);
    }

    // Listen to media shared with the app while it's running
    _shareSubscription = handler.sharedMediaStream.listen((SharedMedia media) {
      _handleSharedMedia(media, appProvider);
    });
  }

  void _handleSharedMedia(SharedMedia media, AppProvider provider) {
    if (media.content != null) {
      provider.processSharedUrl(media.content!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StarMusicShare'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          // Navigate when processing is successful
          if (provider.state == AppState.success &&
              provider.audioFilePath != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    audioPath: provider.audioFilePath!,
                    songTitle: provider.songTitle!,
                    thumbnailUrl: provider.thumbnailUrl,
                  ),
                ),
              ).then((_) => provider.reset());
            });
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildBody(context, provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppProvider provider) {
    switch (provider.state) {
      case AppState.processing:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitWave(color: Colors.deepPurpleAccent, size: 50.0),
            const SizedBox(height: 30),
            Text(
              provider.statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (provider.downloadProgress > 0) ...[
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: provider.downloadProgress,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.deepPurpleAccent,
                ),
              ),
            ],
          ],
        );
      case AppState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'An Error Occurred',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              provider.errorMessage ?? 'Unknown error.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => provider.reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        );
      case AppState.idle:
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.share, size: 100, color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            Text(
              'Share a StarMaker Song',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Open the StarMaker app.\n\n'
              '2. Find a recorded song you like.\n\n'
              '3. Tap the "Share" button.\n\n'
              '4. Choose "StarMusicShare" from the list.',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],
        );
    }
  }
}
