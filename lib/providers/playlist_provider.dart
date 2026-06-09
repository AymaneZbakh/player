import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/channel.dart';
import '../data/models/playlist.dart';
import '../data/parsers/m3u_parser.dart';
import '../data/repositories/playlist_repository.dart';

final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, List<Playlist>>((ref) {
  return PlaylistsNotifier(ref.watch(playlistRepositoryProvider));
});

class PlaylistsNotifier extends StateNotifier<List<Playlist>> {
  final PlaylistRepository _repo;
  PlaylistsNotifier(this._repo) : super(_repo.loadAll());

  Future<void> add(Playlist playlist) async {
    await _repo.save(playlist);
    state = _repo.loadAll();
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    state = _repo.loadAll();
  }
}

final channelsProvider = FutureProvider.family<List<Channel>, String>((ref, url) async {
  return M3UParser().fetchAndParse(url);
});
