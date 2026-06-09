import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/playlist.dart';
import '../../providers/playlist_provider.dart';
import 'player_screen.dart';

class ChannelDashboardScreen extends ConsumerWidget {
  final Playlist playlist;
  const ChannelDashboardScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChan = ref.watch(channelsProvider(playlist.url));

    return Scaffold(
      body: asyncChan.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, _) => Center(child: Text('Error parsing playlist data: $err', style: const TextStyle(color: Colors.red))),
        data: (_) => const Row(
          children: [
            _LeftSidebarWidget(),
            VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E232A)),
            _MiddleBrowserWidget(),
            VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E232A)),
            Expanded(child: _RightStageWidget()),
          ],
        ),
      ),
    );
  }
}

class _LeftSidebarWidget extends ConsumerWidget {
  const _LeftSidebarWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMod = ref.watch(activeModuleProvider);
    final channels = ref.watch(rawChannelsProvider);
    final activeCat = ref.watch(activeCategoryProvider);
    final folders = ref.watch(customFoldersProvider);

    final categoryCounts = <String, int>{};
    for (var ch in channels) {
      categoryCounts[ch.groupTitle] = (categoryCounts[ch.groupTitle] ?? 0) + 1;
    }

    return Container(
      width: 260,
      color: const Color(0xFF0F1115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.bolt, color: Color(0xFF3B82F6)),
                SizedBox(width: 8),
                Text('IPTV PLAYER ZERO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: ['Live TV', 'Movies', 'Series'].map((mod) {
                final isSelected = activeMod == mod;
                return Expanded(
                  child: InkWell(
                    onTap: () => ref.read(activeModuleProvider.notifier).state = mod,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E2430) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(mod, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF3B82F6) : Colors.white60)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ...folders.entries.map((f) => ListTile(
                      leading: const Icon(Icons.folder, size: 16, color: Colors.amber),
                      title: Text(f.value, style: const TextStyle(fontSize: 12)),
                      dense: true,
                      onTap: () {},
                    )),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('CATEGORIES', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  selected: activeCat == null,
                  title: const Text('All Streams', style: TextStyle(fontSize: 12)),
                  dense: true,
                  onTap: () => ref.read(activeCategoryProvider.notifier).state = null,
                ),
                ...categoryCounts.entries.map((cat) => ListTile(
                      selected: activeCat == cat.key,
                      title: Text(cat.key, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text('${cat.value}', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                      dense: true,
                      onTap: () => ref.read(activeCategoryProvider.notifier).state = cat.key,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MiddleBrowserWidget extends ConsumerWidget {
  const _MiddleBrowserWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(processedChannelsProvider);
    final selected = ref.watch(selectedChannelProvider);

    return Container(
      width: 320,
      color: const Color(0xFF111318),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => ref.read(searchFilterProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search channel entries...',
                prefixIcon: const Icon(Icons.search, size: 16),
                isDense: true,
                fillColor: const Color(0xFF1A1D24),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final ch = list[i];
                final isSelected = selected?.id == ch.id;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: const Color(0xFF1E2533),
                  leading: SizedBox(
                    width: 32,
                    height: 32,
                    child: ch.logoUrl != null 
                        ? CachedNetworkImage(imageUrl: ch.logoUrl!, errorWidget: (_, __, ___) => const Icon(Icons.tv)) 
                        : const Icon(Icons.tv),
                  ),
                  title: Text(ch.name, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(ch.currentProgram, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => ref.read(selectedChannelProvider.notifier).state = ch,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _RightStageWidget extends ConsumerWidget {
  const _RightStageWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChan = ref.watch(selectedChannelProvider);

    if (activeChan == null) {
      return const Center(child: Text('Select a channel from the browser roster matrix', style: TextStyle(color: Colors.white24)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(flex: 3, child: PlayerScreen(key: ValueKey(activeChan.id), channel: activeChan)),
              Container(
                width: 240,
                color: const Color(0xFF111419),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activeChan.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(activeChan.groupTitle, style: const TextStyle(fontSize: 11, color: Color(0xFF3B82F6))),
                    const Divider(height: 20),
                    const Text('EPG OVERVIEW', style: TextStyle(fontSize: 10, color: Colors.white38)),
                    const SizedBox(height: 8),
                    Text('Now: ${activeChan.currentProgram}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                    const SizedBox(height: 4),
                    Text('Next: ${activeChan.nextProgram}', style: const TextStyle(fontSize: 11, color: Colors.white60)),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF0C0E12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FULL TIMELINE GUIDE SCHEDULE', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(leading: const Text('6:00 PM'), title: Text(activeChan.currentProgram), dense: true),
                      ListTile(leading: const Text('7:30 PM'), title: Text(activeChan.nextProgram), dense: true),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
