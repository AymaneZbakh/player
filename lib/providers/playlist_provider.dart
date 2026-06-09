import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/channel.dart';
import '../data/parsers/m3u_parser.dart';

// Current loaded channel master list
final rawChannelsProvider = StateProvider<List<Channel>>((ref) => []);

// Navigation and UI state management
final activeCategoryProvider = StateProvider<String?>((ref) => null);
final activeModuleProvider = StateProvider<String>((ref) => 'Live TV'); // Live TV, Movies, Series
final searchFilterProvider = StateProvider<String>((ref) => '');
final selectedChannelProvider = StateProvider<Channel?>((ref) => null);

// User-created folder mapping (Id -> Folder Name)
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

// Global active channels processor (Applies searches, category filters, and custom structures)
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

final channelsFetchProvider = FutureProvider.family<List<Channel>, String>((ref, url) async {
  final channels = await M3UParser().fetchAndParse(url);
  // Map index data automatically
  final mapped = List<Channel>.generate(channels.length, (index) => Channel(
    id: index.toString(),
    name: channels[index].name,
    streamUrl: channels[index].streamUrl,
    logoUrl: channels[index].logoUrl,
    groupTitle: channels[index].groupTitle,
  ));
  ref.read(rawChannelsProvider.notifier).state = mapped;
  if (mapped.isNotEmpty) {
    ref.read(activeCategoryProvider.notifier).state = mapped.first.groupTitle;
  }
  return mapped;
});
