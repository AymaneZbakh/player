import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:iptv_player/data/models/channel.dart';
import 'package:iptv_player/data/models/playlist.dart';
import 'package:iptv_player/data/parsers/m3u_parser.dart';
import 'package:iptv_player/data/repositories/playlist_repository.dart';

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

// UI State Hooks
final activeModuleProvider = StateProvider<MediaType>((ref) => MediaType.live);
final activeCategoryProvider = StateProvider<String?>((ref) => null);
final searchFilterProvider = StateProvider<String>((ref) => '');
final selectedChannelProvider = StateProvider<Channel?>((ref) => null);

// In-Memory Stream Cache
final rawChannelsProvider = StateProvider<List<Channel>>((ref) => []);

// Core Playlist Fetcher Pipeline
final channelsFetchProvider = FutureProvider.family<List<Channel>, String>((ref, url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final parsed = M3UParser().parseString(response.body);
    ref.read(rawChannelsProvider.notifier).state = parsed;
    return parsed;
  }
  throw Exception('Failed to fetch M3U playlist content streams.');
});

// Triple-Filter Computation Filter
final processedChannelsProvider = Provider<List<Channel>>((ref) {
  final allChannels = ref.watch(rawChannelsProvider);
  final module = ref.watch(activeModuleProvider);
  final category = ref.watch(activeCategoryProvider);
  final query = ref.watch(searchFilterProvider).toLowerCase();

  return allChannels.where((channel) {
    final matchesModule = channel.type == module;
    final matchesCategory = category == null || channel.groupTitle == category;
    final matchesQuery = query.isEmpty || channel.name.toLowerCase().contains(query);
    return matchesModule && matchesCategory && matchesQuery;
  }).toList();
});
