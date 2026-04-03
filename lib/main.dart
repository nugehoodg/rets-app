import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cassette.dart';
import 'models/track.dart';
import 'models/theme_settings.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(CassetteAdapter());
  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(ThemeSettingsAdapter());

  // Pre-open the theme_settings box for synchronous access in providers
  await Hive.openBox<ThemeSettings>('theme_settings');

  runApp(const ProviderScope(child: ArchivistApp()));
}

class ArchivistApp extends StatelessWidget {
  const ArchivistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rets',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
