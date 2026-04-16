import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad/ad_manager.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.initialize();
  AdManager.preloadInterstitial();
  runApp(const ProviderScope(child: HokatsuScoreApp()));
}

class HokatsuScoreApp extends StatefulWidget {
  const HokatsuScoreApp({super.key});

  @override
  State<HokatsuScoreApp> createState() => _HokatsuScoreAppState();
}

class _HokatsuScoreAppState extends State<HokatsuScoreApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdManager.resetSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ホカツスコア',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00BCD4),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
