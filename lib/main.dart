// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starmusicshare/providers/app_provider.dart';
import 'package:starmusicshare/screens/share_receiver_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StarMusicShare',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepPurpleAccent,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurpleAccent,
            brightness: Brightness.dark,
            background: const Color(0xFF121212),
          ),
          useMaterial3: true,
        ),
        home: const ShareReceiverScreen(),
      ),
    );
  }
}
