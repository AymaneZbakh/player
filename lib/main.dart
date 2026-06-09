import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'data/repositories/playlist_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IPTVPlayerApp(),
    ),
  );
}

class IPTVPlayerApp extends ConsumerWidget {
  const IPTVPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Desktop Stream Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
