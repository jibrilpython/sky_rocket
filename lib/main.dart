import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/game_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style system bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1A1A2E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Pre-cache Google Fonts before any rendering occurs.
  // This prevents garbled text from partial font loading.
  await GoogleFonts.pendingFonts([
    GoogleFonts.pressStart2p(),
    GoogleFonts.nunito(),
  ]);

  // Configure global audio context so multiple AudioPlayers
  // don't fight for audio focus (bg music + SFX simultaneously).
  AudioPlayer.global.setAudioContext(AudioContext(
    android: AudioContextAndroid(
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  ));

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const SkyRocketApp(),
    ),
  );
}

class SkyRocketApp extends ConsumerWidget {
  const SkyRocketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sky Rocket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
