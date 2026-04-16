import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: HokatsuScoreApp()));
}

class HokatsuScoreApp extends StatelessWidget {
  const HokatsuScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ホカツスコア',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00BCD4), // Okinawan turquoise
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('ホカツスコア')),
      ),
    );
  }
}
