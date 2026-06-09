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

// Global UI Layout Navigation Selectors
final activeModuleProvider = StateProvider<MediaType>((ref) => MediaType.live);
final activeCategoryProvider = StateProvider<String?>((ref) => null);
final searchFilterProvider = StateProvider<String>((ref) => '');
final selectedChannelProvider = StateProvider<Channel?>((ref) => null);
final customFoldersProvider = StateProvider<List<String>>((ref) => ['⭐ Favorite Channels', '🎬 Watch Later', '🎵 Music Mix']);

// In-Memory Master Array Registry
final rawChannelsProvider = StateProvider<List<Channel>>((ref) => []);

// High-Density Core Processor: Filters on type, sub-category tabs, and query text simultaneously
final processedChannelsProvider = Provider<List<Channel>>((ref) {
  final channels = ref.watch(rawChannelsProvider);
  final activeMod = ref.watch(activeModuleProvider);
  final activeCat = ref.watch(activeCategoryProvider);
  final search = ref.watch(searchFilterProvider).toLowerCase();

  return channels.where((ch) {
    if (ch.type != activeMod) return false;
    if (activeCat != null && ch.groupTitle != activeCat) return false;
    if (search.isNotEmpty) {
      return ch.name.toLowerCase().contains(search) || ch.groupTitle.toLowerCase().contains(search);
    }
    return true;
  }).toList();
});

// Intelligent Streaming Intake Parser Pipeline
final channelsFetchProvider = FutureProvider.family<List<Channel>, String>((ref, url) async {
  final items = await M3UParser().fetchAndParse(url);
  
  final builtList = List<Channel>.generate(items.length, (idx) {
    final raw = items[idx];
    final title = raw.name;
    final lowerTitle = title.toLowerCase();
    final lowerCat = raw.groupTitle.toLowerCase();

    // Context Inference: Sort entries using structural token attributes
    MediaType autoType = MediaType.live;
    String cleanTitle = title;
    String year = '2025';
    String length = '2h 05m';

    if (lowerTitle.contains('s01') || lowerTitle.contains('s02') || lowerTitle.contains('e01') || lowerCat.contains('series') || lowerCat.contains('seasons')) {
      autoType = MediaType.series;
      length = 'Season 1';
    } else if (lowerCat.contains('movie') || lowerCat.contains('cinema') || lowerTitle.contains('.mp4') || lowerTitle.contains('.mkv') || RegExp(r'\b(19|20)\d{2}\b').hasMatch(lowerTitle)) {
      autoType = MediaType.movie;
      final match = RegExp(r'\b((19|20)\d{2})\b').firstMatch(lowerTitle);
      if (match != null) {
        year = match.group(1)!;
      }
    }

    return Channel(
      id: 'item_$idx',
      name: cleanTitle,
      streamUrl: raw.streamUrl,
      logoUrl: raw.logoUrl,
      groupTitle: raw.groupTitle.isEmpty ? 'General' : raw.groupTitle,
      type: autoType,
      currentProgram: autoType == MediaType.live ? 'Live Broadcast Transmission Feed' : cleanTitle,
      releaseYear: year,
      durationOrSeasons: length,
      rating: ((70 + (idx % 25)) / 10).toStringAsFixed(1), // Balanced mock calculations for visual density
    );
  });

  ref.read(rawChannelsProvider.notifier).state = builtList;
  
  // Prime the first category cluster automatically
  if (builtList.isNotEmpty) {
    final initial = builtList.first;
    ref.read(activeModuleProvider.notifier).state = initial.type;
    ref.read(activeCategoryProvider.notifier).state = initial.groupTitle;
  }
  
  return builtList;
});
