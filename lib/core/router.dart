import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/playlist.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/channel_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/channels',
        builder: (context, state) => ChannelDashboardScreen(playlist: state.extra as Playlist),
      ),
    ],
  );
});
