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
    final asyncLoad = ref.watch(channelsFetchProvider(playlist.url));

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      body: asyncLoad.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, _) => Center(child: Text('Data integration breakdown: $err', style: const TextStyle(color: Colors.redAccent))),
        data: (_) => const Row(
          children: [
            _LeftControlDock(),
            VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E232A)),
            _MiddleMediaBrowser(),
            VerticalDivider(width: 1, thickness: 1, color: Color(0xFF1E232A)),
            Expanded(child: _RightWorkspaceStage()),
          ],
        ),
      ),
    );
  }
}

// ── COLUMN 1: COLLAPSIBLE SIDEBAR DOCK CONTROLS ──────────────────────────────────
class _LeftControlDock extends ConsumerWidget {
  const _LeftControlDock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMod = ref.watch(activeModuleProvider);
    final activeCat = ref.watch(activeCategoryProvider);
    final allItems = ref.watch(rawChannelsProvider);
    final userFolders = ref.watch(customFoldersProvider);

    final totalForModule = allItems.where((ch) => ch.type == activeMod).toList();
    final categoriesMap = <String, int>{};
    for (var ch in totalForModule) {
      categoriesMap[ch.groupTitle] = (categoriesMap[ch.groupTitle] ?? 0) + 1;
    }

    return Container(
      width: 270,
      color: const Color(0xFF0F1115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Icon(Icons.bolt, color: Color(0xFF3B82F6), size: 24),
                SizedBox(width: 8),
                Text('IPTV PLAYER ZERO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.0, color: Colors.white)),
              ],
            ),
          ),

          // High-Fidelity Module Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF161A22), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  _buildTabItem(ref, 'Live TV', MediaType.live, activeMod == MediaType.live),
                  _buildTabItem(ref, 'Movies', MediaType.movie, activeMod == MediaType.movie),
                  _buildTabItem(ref, 'Series', MediaType.series, activeMod == MediaType.series),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 0.8),
                  child: Text('USER FOLDERS'),
                ),
                ...userFolders.map((folder) => ListTile(
                  horizontalTitleGap: 8,
                  leading: const Icon(Icons.folder_open, color: Colors.amber, size: 16),
                  title: Text(folder, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  onTap: () {},
                )),
                const Divider(height: 24, color: Color(0xFF1E232A)),
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 8),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 0.8),
                  child: Text('STREAM SEGMENTS'),
                ),
                ListTile(
                  selected: activeCat == null,
                  selectedTileColor: const Color(0xFF1C222E),
                  title: const Text('All Filtered Entries', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  trailing: Text('${totalForModule.length}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onTap: () => ref.read(activeCategoryProvider.notifier).state = null,
                ),
                ...categoriesMap.entries.map((category) {
                  final isSelected = activeCat == category.key;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF1C222E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    title: Text(category.key, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E242E), borderRadius: BorderRadius.circular(8)),
                      child: Text('${category.value}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white54)),
                    ),
                    dense: true,
                    onTap: () => ref.read(activeCategoryProvider.notifier).state = category.key,
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabItem(WidgetRef ref, String text, MediaType target, bool active) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(activeModuleProvider.notifier).state = target;
          ref.read(activeCategoryProvider.notifier).state = null;
          ref.read(selectedChannelProvider.notifier).state = null;
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: active ? const Color(0xFF222938) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? const Color(0xFF3B82F6) : Colors.white38)),
        ),
      ),
    );
  }
}

// ── COLUMN 2: HIGH-DENSITY SEARCHABLE MEDIA ROSTER BROWSER ──────────────────────────
class _MiddleMediaBrowser extends ConsumerWidget {
  const _MiddleMediaBrowser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(processedChannelsProvider);
    final activeSelection = ref.watch(selectedChannelProvider);
    final activeModule = ref.watch(activeModuleProvider);

    return Container(
      width: 350,
      color: const Color(0xFF111318),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => ref.read(searchFilterProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Filter current index array...',
                prefixIcon: const Icon(Icons.search, size: 16, color: Colors.white38),
                isDense: true,
                fillColor: const Color(0xFF1A1D24),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: dataset.isEmpty
                ? const Center(child: Text('No media items match configuration', style: TextStyle(color: Colors.white24, fontSize: 12)))
                : activeModule == MediaType.live
                    ? ListView.builder(
                        itemCount: dataset.length,
                        itemBuilder: (ctx, i) {
                          final stream = dataset[i];
                          final active = activeSelection?.id == stream.id;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: active ? const Color(0xFF1C2333) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
                            child: ListTile(
                              dense: true,
                              leading: _renderAvatarIcon(stream.logoUrl),
                              title: Text(stream.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(stream.currentProgram, style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(value: stream.programProgress, minHeight: 2, backgroundColor: Colors.white10, color: const Color(0xFF10B981)),
                                ],
                              ),
                              onTap: () => ref.read(selectedChannelProvider.notifier).state = stream,
                            ),
                          );
                        },
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.70, crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemCount: dataset.length,
                        itemBuilder: (ctx, i) {
                          final media = dataset[i];
                          final active = activeSelection?.id == media.id;
                          return GestureDetector(
                            onTap: () => ref.read(selectedChannelProvider.notifier).state = media,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF161A23),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: active ? const Color(0xFF3B82F6) : Colors.transparent, width: 2),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: media.logoUrl != null
                                        ? CachedNetworkImage(imageUrl: media.logoUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black38, child: Icon(Icons.movie, size: 28, color: Colors.white12)))
                                        : const ColoredBox(color: Colors.black38, child: Icon(Icons.movie, size: 28, color: Colors.white12)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // This explicit mapping line ensures Movie and Series names display clearly underneath cover art posters
                                        Text(media.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.between,
                                          children: [
                                            Text(media.releaseYear, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                                            Text('⭐ ${media.rating}', style: const TextStyle(fontSize: 10, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
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

  Widget _renderAvatarIcon(String? url) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
      child: url != null ? CachedNetworkImage(imageUrl: url, errorWidget: (_, __, ___) => const Icon(Icons.tv, size: 16)) : const Icon(Icons.tv, size: 16, color: Colors.white24),
    );
  }
}

// ── COLUMN 3: LARGE RUNTIME STAGE AREA (PLAYER + INTERACTIVE SIDE CAR) ───────────
class _RightWorkspaceStage extends ConsumerWidget {
  const _RightWorkspaceStage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMedia = ref.watch(selectedChannelProvider);

    if (selectedMedia == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_filter, size: 64, color: Colors.white10),
            SizedBox(height: 12),
            Text('No Active Target Initialized', style: TextStyle(color: Colors.white24, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Panel Split View
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: PlayerScreen(key: ValueKey(selectedMedia.id), channel: selectedMedia)),
              Container(
                width: 290,
                color: const Color(0xFF12141A),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedMedia.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(selectedMedia.groupTitle, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold)),
                    const Divider(height: 32, color: Color(0xFF1E232A)),
                    
                    if (selectedMedia.type == MediaType.live) ...[
                      const Text('EPG LIVE SCHEDULE', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Running: ${selectedMedia.currentProgram}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Next up: ${selectedMedia.nextProgram}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ] else ...[
                      const Text('ASSET ATTRIBUTES', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: Colors.white38),
                          const SizedBox(width: 6),
                          Text(selectedMedia.releaseYear, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(width: 20),
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.white38),
                          const SizedBox(width: 6),
                          Text(selectedMedia.durationOrSeasons, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('STORYLINE SYNOPSIS', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(selectedMedia.plotSummary, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
                    ],
                    
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1D24), minimumSize: const Size.fromHeight(42), side: const BorderSide(color: Color(0xFF1E232A))),
                      onPressed: () {},
                      icon: const Icon(Icons.add_to_photos, color: Colors.amber, size: 16),
                      label: const Text('Pin to Workspace Folder', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),

        // Bottom EPG / Playback History Slate Tracker
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF0C0E12),
            border: const Border(top: BorderSide(color: Color(0xFF1E232A))),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    Text(selectedMedia.type == MediaType.live ? 'ELECTRONIC CHANNEL TIMELINE PROGRAM GUIDE (EPG)' : 'PLAYBACK LOG FILE RECORDS', style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      _buildEPGCard('08:00 PM', selectedMedia.currentProgram, 'Active primary incoming network presentation vector pipeline stream.', current: true),
                      _buildEPGCard('09:30 PM', selectedMedia.type == MediaType.live ? selectedMedia.nextProgram : 'Continuous Buffer Sequence Event Logger', 'Next sequential file allocation processing thread block.'),
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

  Widget _buildEPGCard(String time, String title, String desc, {bool current = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: current ? const Color(0xFF10B981).withOpacity(0.04) : const Color(0xFF13171F),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: current ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFF1E232A)),
      ),
      child: Row(
        children: [
          Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: current ? const Color(0xFF10B981) : Colors.white38)),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
