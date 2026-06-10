import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/playlist.dart';
import '../../data/models/channel.dart';
import '../../providers/playlist_provider.dart';
import 'player_screen.dart';

class ChannelDashboardScreen extends ConsumerWidget {
  final Playlist playlist;
  const ChannelDashboardScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFetch = ref.watch(channelsFetchProvider(playlist.url));

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      body: asyncFetch.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, _) => Center(child: Text('Stream Processing Error: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (channels) => Row(
          children: [
            const _LeftNavigationDock(),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E232A)),
            const _MiddleMediaBrowser(),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E232A)),
            const Expanded(child: _RightExecutionStage()),
          ],
        ),
      ),
    );
  }
}

// ── PANEL 1: SIDEBAR NAVIGATION DOCK ──────────────────────────────────────────
class _LeftNavigationDock extends ConsumerWidget {
  const _LeftNavigationDock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMod = ref.watch(activeModuleProvider);
    final activeCat = ref.watch(activeCategoryProvider);
    final allStreams = ref.watch(rawChannelsProvider);

    final filteredModuleStreams = allStreams.where((ch) => ch.type == activeMod).toList();
    final groupMetrics = <String, int>{};
    for (var ch in filteredModuleStreams) {
      groupMetrics[ch.groupTitle] = (groupMetrics[ch.groupTitle] ?? 0) + 1;
    }

    return Container(
      width: 260,
      color: const Color(0xFF0F1115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Row(
              children: [
                Icon(Icons.bolt, color: Color(0xFF3B82F6), size: 22),
                SizedBox(width: 8),
                Text('IPTV ZERO DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF161A22), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  _moduleSegment(ref, 'Live TV', MediaType.live, activeMod == MediaType.live),
                  _moduleSegment(ref, 'Movies', MediaType.movie, activeMod == MediaType.movie),
                  _moduleSegment(ref, 'Series', MediaType.series, activeMod == MediaType.series),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                ListTile(
                  selected: activeCat == null,
                  selectedTileColor: const Color(0xFF1C222E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  title: const Text('All Streams Context', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  trailing: Text('${filteredModuleStreams.length}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  dense: true,
                  onTap: () => ref.read(activeCategoryProvider.notifier).state = null,
                ),
                const Divider(height: 16, color: Color(0xFF1E232A)),
                ...groupMetrics.entries.map((meta) {
                  final check = activeCat == meta.key;
                  return ListTile(
                    selected: check,
                    selectedTileColor: const Color(0xFF1C222E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    title: Text(meta.key, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text('${meta.value}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    dense: true,
                    onTap: () => ref.read(activeCategoryProvider.notifier).state = meta.key,
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _moduleSegment(WidgetRef ref, String label, MediaType module, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(activeModuleProvider.notifier).state = module;
          ref.read(activeCategoryProvider.notifier).state = null;
          ref.read(selectedChannelProvider.notifier).state = null;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: active ? const Color(0xFF222938) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? const Color(0xFF3B82F6) : Colors.white38)),
        ),
      ),
    );
  }
}

// ── PANEL 2: MIDDLE MEDIA BROWSER OVERLAY ──────────────────────────────────────
class _MiddleMediaBrowser extends ConsumerWidget {
  const _MiddleMediaBrowser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = ref.watch(processedChannelsProvider);
    final selection = ref.watch(selectedChannelProvider);
    final currentModule = ref.watch(activeModuleProvider);

    return Container(
      width: 340,
      color: const Color(0xFF111318),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => ref.read(searchFilterProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Filter current streams...',
                prefixIcon: const Icon(Icons.search, size: 16, color: Colors.white38),
                isDense: true,
                fillColor: const Color(0xFF1A1D24),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: channels.isEmpty
                ? const Center(child: Text('No matching items', style: TextStyle(color: Colors.white24, fontSize: 12)))
                : currentModule == MediaType.live
                    ? ListView.builder(
                        itemCount: channels.length,
                        itemBuilder: (context, idx) {
                          final channel = channels[idx];
                          final isSelected = selection?.id == channel.id;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: isSelected ? const Color(0xFF1C2333) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                            child: ListTile(
                              dense: true,
                              title: Text(channel.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(channel.currentProgram, style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              onTap: () => ref.read(selectedChannelProvider.notifier).state = channel,
                            ),
                          );
                        },
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemCount: channels.length,
                        itemBuilder: (context, idx) {
                          final movie = channels[idx];
                          final isSelected = selection?.id == movie.id;
                          return GestureDetector(
                            onTap: () => ref.read(selectedChannelProvider.notifier).state = movie,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF161A23),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent, width: 2),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: movie.logoUrl != null
                                        ? CachedNetworkImage(imageUrl: movie.logoUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black26, child: Icon(Icons.movie, size: 24)))
                                        : const ColoredBox(color: Colors.black26, child: Icon(Icons.movie, size: 24)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(movie.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.between,
                                          children: [
                                            Text(movie.releaseYear, style: const TextStyle(fontSize: 9, color: Colors.white38)),
                                            Text('⭐ ${movie.rating}', style: const TextStyle(fontSize: 9, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── PANEL 3: RIGHT WORKSPACE PRODUCTION STAGE ──────────────────────────────────
class _RightExecutionStage extends ConsumerWidget {
  const _RightExecutionStage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChannel = ref.watch(selectedChannelProvider);

    if (activeChannel == null) {
      return const Center(child: Text('No Active Video Stream Initialized', style: TextStyle(color: Colors.white24, fontSize: 13)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: PlayerScreen(key: ValueKey(activeChannel.id), channel: activeChannel)),
              Container(
                width: 280,
                color: const Color(0xFF12141A),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activeChannel.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(activeChannel.groupTitle, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w500)),
                    const Divider(height: 24, color: Color(0xFF1E232A)),
                    const Text('METADATA MANIFEST', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Release Context: ${activeChannel.releaseYear}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('Length/Duration: ${activeChannel.durationOrSeasons}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('Rating Track: ⭐ ${activeChannel.rating}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const Divider(height: 24, color: Color(0xFF1E232A)),
                    const Text('PLOT SUMMARY', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(activeChannel.plotSummary, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
                      ),
                    ),
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
                const Text('ELECTRONIC CHANNEL GUIDE TRACKS (EPG)', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (activeChannel.type == MediaType.live) ...[
                  Text('Now Playing: ${activeChannel.currentProgram}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: activeChannel.programProgress, backgroundColor: Colors.white10, color: const Color(0xFF10B981)),
                  const SizedBox(height: 8),
                  Text('Next: ${activeChannel.nextProgram}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ] else ...[
                  const Expanded(child: Center(child: Text('EPG timelines are disabled for VOD assets.', style: TextStyle(color: Colors.white12, fontSize: 11)))),
                ],
              ],
            ),
          ),
        )
      ],
    );
  }
}
