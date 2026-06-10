import 'dart:convert';
import '../models/channel.dart';

class M3UParser {
  List<Channel> parseString(String m3uContent) {
    final List<Channel> channels = [];
    final List<String> lines = const LineSplitter().convert(m3uContent);
    
    String? currentGroup;
    String? currentLogo;
    String? currentName;
    int fallbackIdCounter = 0;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('#EXTINF:')) {
        final groupMatch = RegExp(r'group-title="([^"]+)"').firstMatch(trimmed);
        currentGroup = groupMatch?.group(1);

        final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(trimmed);
        currentLogo = logoMatch?.group(1);

        final commaIndex = trimmed.lastIndexOf(',');
        if (commaIndex != -1) {
          currentName = trimmed.substring(commaIndex + 1).trim();
        }
      } else if (!trimmed.startsWith('#') && currentName != null) {
        final streamUrl = trimmed;
        final id = 'parsed_stream_${fallbackIdCounter++}';

        final lowerTitle = currentName.toLowerCase();
        final lowerGroup = (currentGroup ?? '').toLowerCase();
        MediaType autoType = MediaType.live;
        String year = '2026';
        String length = '2h 05m';

        if (lowerTitle.contains('s01') || lowerTitle.contains('s02') || lowerTitle.contains('e01') || lowerGroup.contains('series')) {
          autoType = MediaType.series;
          length = 'Season 1';
        } else if (lowerGroup.contains('movie') || lowerTitle.contains('.mp4') || lowerTitle.contains('.mkv') || RegExp(r'\b(19|20)\d{2}\b').hasMatch(lowerTitle)) {
          autoType = MediaType.movie;
          final match = RegExp(r'\b((19|20)\d{2})\b').firstMatch(lowerTitle);
          if (match != null) {
            year = match.group(1)!;
          }
        }

        channels.add(
          Channel(
            id: id,
            name: currentName,
            streamUrl: streamUrl,
            logoUrl: currentLogo,
            groupTitle: currentGroup ?? 'General',
            type: autoType,
            currentProgram: autoType == MediaType.live ? 'Live Broadcast Feed' : currentName,
            releaseYear: year,
            durationOrSeasons: length,
            rating: ((72 + (fallbackIdCounter % 20)) / 10).toStringAsFixed(1),
          ),
        );

        currentGroup = null;
        currentLogo = null;
        currentName = null;
      }
    }
    return channels;
  }
}
