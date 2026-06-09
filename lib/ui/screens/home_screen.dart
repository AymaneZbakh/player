import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/playlist_provider.dart';
import '../widgets/add_playlist_dialog.dart';
import '../widgets/disclaimer_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _showDisclaimerIfFirstLaunch();
  }

  Future<void> _showDisclaimerIfFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('disclaimer_seen') ?? false;
    if (!seen && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const DisclaimerDialog(),
      );
      await prefs.setBool('disclaimer_seen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlists = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Player Zero', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: playlists.isEmpty 
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.live_tv, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('No container links added yet.', style: TextStyle(color: Colors.white54)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final pl = playlists[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.playlist_play, color: Color(0xFF3B82F6)),
                    title: Text(pl.name),
                    subtitle: Text(pl.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => ref.read(playlistsProvider.notifier).remove(pl.id),
                    ),
                    onTap: () => context.push('/channels', extra: pl),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () => showDialog(context: context, builder: (_) => const AddPlaylistDialog()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add IPTV Playlist', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
