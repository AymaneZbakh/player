import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/playlist.dart';
import '../../providers/playlist_provider.dart';

class AddPlaylistDialog extends ConsumerStatefulWidget {
  const AddPlaylistDialog({super.key});
  @override
  ConsumerState<AddPlaylistDialog> createState() => _AddPlaylistDialogState();
}

class _AddPlaylistDialogState extends ConsumerState<AddPlaylistDialog> {
  final _name = TextEditingController();
  final _url = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add IPTV Playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Playlist Name')),
          TextField(controller: _url, decoration: const InputDecoration(labelText: 'M3U Link URL')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            if (_name.text.isEmpty || _url.text.isEmpty) return;
            final pl = Playlist(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _name.text, url: _url.text, addedAt: DateTime.now());
            await ref.read(playlistsProvider.notifier).add(pl);
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
