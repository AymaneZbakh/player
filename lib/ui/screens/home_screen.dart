import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/playlist_provider.dart';
import '../widgets/add_playlist_dialog.dart';
import '../widgets/disclaimer_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final p = await SharedPreferences.getInstance();
      if (!(p.getBool('seen') ?? false)) {
        if (!mounted) return;
        await showDialog(context: context, builder: (_) => const DisclaimerDialog());
        await p.setBool('seen', true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(playlistsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Stream Player'),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings'))],
      ),
      body: lists.isEmpty
          ? const Center(child: Text('No Playlists Added Yet. Click Add Below.'))
          : ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.live_tv),
                title: Text(lists[i].name),
                subtitle: Text(lists[i].url, maxLines: 1),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => ref.read(playlistsProvider.notifier).remove(lists[i].id)),
                onTap: () => context.push('/channels', extra: lists[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => showDialog(context: context, builder: (_) => const AddPlaylistDialog()), child: const Icon(Icons.add)),
    );
  }
}
