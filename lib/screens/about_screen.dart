import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      // Could not launch the URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Developer'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://avatars.githubusercontent.com/u/70425782?v=4',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Praveen MT',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Developer & Tech Enthusiast',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: theme.cardColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'I build optimized systems that blend innovation with precision. Passionate about AI, cybersecurity, and future tech—always exploring the edge between code and creativity.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Connect with me',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0,
              children: [
                _buildSocialButton(
                  icon: FontAwesomeIcons.github,
                  url: 'https://github.com/ReverseEngineeringDude',
                ),
                _buildSocialButton(
                  icon: FontAwesomeIcons.twitter,
                  url: 'https://twitter.com/Redbytesec',
                ),
                _buildSocialButton(
                  icon: FontAwesomeIcons.linkedin,
                  url: 'https://linkedin.com/in/Redbytesec',
                ),
                _buildSocialButton(
                  icon: FontAwesomeIcons.youtube,
                  url: 'https://youtube.com/ReverseEngineeringDude',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required String url}) {
    return IconButton(
      icon: FaIcon(icon),
      iconSize: 28,
      onPressed: () => _launchUrl(url),
    );
  }
}
