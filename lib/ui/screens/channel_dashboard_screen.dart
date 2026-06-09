import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/playlist.dart';
import '../../providers/playlist_provider.dart';

class ChannelDashboardScreen extends ConsumerWidget {
  final Playlist playlist;
  const ChannelDashboardScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChan = ref.watch(channelsProvider(playlist.url));
    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: asyncChan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading streams: $e')),
        data: (chans) => ListView.builder(
          itemCount: chans.length,
          itemBuilder: (context, i) => ListTile(
            leading: const Icon(Icons.play_arrow),
            title: Text(chans[i].name),
            subtitle: Text(chans[i].groupTitle),
            onTap: () => context.push('/player', extra: chans[i]),
          ),
        ),
      ),
    );
  }
}
