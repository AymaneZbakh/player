import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/channel.dart';
import '../data/models/playlist.dart';
import '../data/parsers/m3u_parser.dart';
import '../data/repositories/playlist_repository.dart';

// Master Data List Store for Saved Playlists
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

// Global UI Navigation Filters
final activeCategoryProvider = StateProvider<String?>((ref) => null);
final activeModuleProvider = StateProvider<String>((ref) => 'Live TV');
final searchFilterProvider = StateProvider<String>((ref) => '');
final selectedChannelProvider = StateProvider<Channel?>((ref) => null);

// In-Memory Master Registry for channels of the actively loaded playlist
final rawChannelsProvider = StateProvider<List<Channel>>((ref) => []);

// Custom Created User Folders Registry Map (ID -> Name)
final customFoldersProvider = StateNotifierProvider<FolderNotifier, Map<String, String>>((ref) {
  return FolderNotifier();
});

class FolderNotifier extends StateNotifier<Map<String, String>> {
  FolderNotifier() : super({'fav': '⭐ Pin Top Section'});
  void createFolder(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    state = {...state, id: name};
  }
}

// Reactive UI Processor Core: Combines Search Filters & Sidebar Group Category Rules
final processedChannelsProvider = Provider<List<Channel>>((ref) {
  final channels = ref.watch(rawChannelsProvider);
  final activeCat = ref.watch(activeCategoryProvider);
  final search = ref.watch(searchFilterProvider).toLowerCase();

  return channels.where((ch) {
    final matchesSearch = ch.name.toLowerCase().contains(search) || ch.groupTitle.toLowerCase().contains(search);
    final matchesCategory = activeCat == null || ch.groupTitle == activeCat;
    return matchesSearch && matchesCategory;
  }).toList();
});

// Resilient Async Playlist Loader Pipeline
final channelsProvider = FutureProvider.family<List<Channel>, String>((ref, url) async {
  final channels = await M3UParser().fetchAndParse(url);
  
  // Transform standard M3U models into rich indexed dashboard channel objects
  final mapped = List<Channel>.generate(channels.length, (index) => Channel(
    id: index.toString(),
    name: channels[index].name,
    streamUrl: channels[index].streamUrl,
    logoUrl: channels[index].logoUrl,
    groupTitle: channels[index].groupTitle,
  ));
  
  ref.read(rawChannelsProvider.notifier).state = mapped;
  return mapped;
});
