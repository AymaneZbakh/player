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
    final asyncChan = ref.watch(channelsFetchProvider(playlist.url));

    return Scaffold(
      body: asyncChan.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
        error: (err, _) => Center(child: Text('Error parsing playlist: $err', style: const TextStyle(color: Colors.red))),
        data: (_) => const Row(
          children: [
            _LeftSidebar(),
            VerticalDivider(width: 1, thickness: 1),
            _MiddleChannelBrowser(),
            VerticalDivider(width: 1, thickness: 1),
            Expanded(child: _RightWorkspaceArea()),
          ],
        ),
      ),
    );
  }
}

// ── LEFT SIDEBAR: CATEGORIES AND CUSTOM FOLDERS ────────────────────────────────
class _LeftSidebar extends ConsumerWidget {
  const _LeftSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ['Live TV', 'Movies', 'Series'];
    final activeMod = ref.watch(activeModuleProvider);
    final channels = ref.watch(rawChannelsProvider);
    final activeCat = ref.watch(activeCategoryProvider);
    final folders = ref.watch(customFoldersProvider);

    // Compute metrics
    final categoryCounts = <String, int>{};
    for (var ch in channels) {
      categoryCounts[ch.groupTitle] = (categoryCounts[ch.groupTitle] ?? 0) + 1;
    }

    return Container(
      width: 280,
      color: const Color(0xFF0F1115),
      child: Column(
        children: [
          // Header Actions Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xFF3B82F6)),
                const SizedBox(width: 8),
                const Text('IPTV ZERO CONTAINER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                  onPressed: () => _showNewFolderDialog(context, ref),
                  tooltip: 'Create New Folder',
                )
              ],
            ),
          ),
          
          // Premium Media Module Selector Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: modules.map((mod) {
                final isSelected = activeMod == mod;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(activeModuleProvider.notifier).state = mod,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E2430) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isSelected ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)) : null,
                      ),
                      child: Text(mod, textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF3B82F6) : Colors.white60)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Core Category & Custom Folders Content Scroller
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold),
                  child: Text('FOLDERS & SEGMENTS'),
                ),
                ...folders.entries.map((f) => ListTile(
                      horizontalTitleGap: 8,
                      leading: const Icon(Icons.folder_special, size: 18, color: Colors.amber),
                      title: Text(f.value, style: const TextStyle(fontSize: 13)),
                      trailing: const Text('0', style: TextStyle(color: Colors.white38, fontSize: 11)),
                      dense: true,
                      onTap: () {},
                    )),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      const Text('CATEGORIES', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold)),
                      Text('${categoryCounts.length}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                ),
                ListTile(
                  selected: activeCat == null,
                  selectedTileColor: const Color(0xFF161B22),
                  title: const Text('All Streams', style: TextStyle(fontSize: 13)),
                  trailing: Text('${channels.length}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  dense: true,
                  onTap: () => ref.read(activeCategoryProvider.notifier).state = null,
                ),
                ...categoryCounts.entries.map((cat) {
                  final isSelected = activeCat == cat.key;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF161B22),
                    title: Text(cat.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.2) : Colors.white10, borderRadius: BorderRadius.circular(10)),
                      child: Text('${cat.value}', style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFF3B82F6) : Colors.white60)),
                    ),
                    dense: true,
                    onTap: () => ref.read(activeCategoryProvider.notifier).state = cat.key,
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showNewFolderDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Custom Folder'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Folder Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                ref.read(customFoldersProvider.notifier).createFolder(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }
}

// ── MIDDLE COLUMN: FILTERED LIVE CHANNEL LIST ──────────────────────────────────
class _MiddleChannelBrowser extends ConsumerWidget {
  const _MiddleChannelBrowser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(processedChannelsProvider);
    final selected = ref.watch(selectedChannelProvider);

    return Container(
      width: 340,
      color: const Color(0xFF111318),
      child: Column(
        children: [
          // Filter Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => ref.read(searchFilterProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search within list...',
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                fillColor: const Color(0xFF1A1D24),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          // Row Counts Tracker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('Channels Found', style: Theme.of(context).textTheme.bodySmall),
                Text('${list.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Channels Stream Roster List
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final ch = list[i];
                final isSelected = selected?.id == ch.id;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E2533) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                      child: ch.logoUrl != null
                          ? CachedNetworkImage(imageUrl: ch.logoUrl!, errorWidget: (_, __, ___) => const Icon(Icons.tv, size: 20))
                          : const Icon(Icons.tv, size: 20, color: Colors.white24),
                    ),
                    title: Text(ch.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(ch.currentProgram, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: ch.programProgress, minHeight: 2, backgroundColor: Colors.white10, color: const Color(0xFF10B981)),
                      ],
                    ),
                    onTap: () => ref.read(selectedChannelProvider.notifier).state = ch,
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

// ── RIGHT COLUMN: PLAYER ZONE & HORIZONTAL EPG ───────────────────────────────
class _RightWorkspaceArea extends ConsumerWidget {
  const _RightWorkspaceArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChan = ref.watch(selectedChannelProvider);

    if (activeChan == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_filled, size: 64, color: Colors.white12),
            SizedBox(height: 16),
            Text('No Channel Selected', style: TextStyle(color: Colors.white38, fontSize: 14)),
            Text('Choose a channel from the browser to start viewing.', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Layout Workspace: Player Canvas & Info Sidecar Card
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Video Screen Area Container
                Expanded(
                  flex: 3,
                  child: PlayerScreen(key: ValueKey(activeChan.id), channel: activeChan),
                ),
                
                // Show Sidebar Detail Box
                Container(
                  width: 300,
                  color: const Color(0xFF111419),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NOW PLAYING', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(activeChan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(activeChan.groupTitle, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
                      const Divider(height: 24),
                      Text('Current: ${activeChan.currentProgram}', style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF10B981))),
                      const SizedBox(height: 8),
                      const Text('Description detail context blocks from EPG feeds parse here natively.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1D24), minimumSize: const Size.fromHeight(40)),
                        onPressed: () {},
                        icon: const Icon(Icons.star, color: Colors.amber, size: 18),
                        label: const Text('Add To Favorites'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        // Bottom Layout Workspace: Horizon Timeline EPG Schedule Grid Tracker
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFF0C0E12),
            border: const Border(top: BorderSide(color: Color(0xFF1E232A))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.white38),
                      SizedBox(width: 8),
                      Text('ELECTRONIC PROGRAM GUIDE (EPG) TIMELINE', style: TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildEPGRow('6:00 PM', activeChan.currentProgram, 'Active running stream presentation track.', isCurrent: true),
                      _buildEPGRow('7:00 PM', activeChan.nextProgram, 'Next scheduled playlist presentation entry block.'),
                      _buildEPGRow('8:30 PM', 'Late Night Broadcast Segment', 'Night entertainment block stream sequence.'),
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

  Widget _buildEPGRow(String time, String title, String desc, {bool isCurrent = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF10B981).withOpacity(0.05) : const Color(0xFF13171F),
        border: Border.all(color: isCurrent ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFF1E232A)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
            child: Text(time, style: TextStyle(color: isCurrent ? const Color(0xFF10B981) : Colors.white38, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
