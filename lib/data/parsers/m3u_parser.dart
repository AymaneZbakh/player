import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class M3UParser {
  Future<List<Channel>> fetchAndParse(String url) async {
    final response = await http.get(Uri.parse(url.trim())).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Failed to load playlist');

    final lines = response.body.split(RegExp(r'\r?\n'));
    final channels = <Channel>[];

    String? pendingName;
    String? pendingLogo;
    String? pendingGroup;

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('#EXTINF:')) {
        pendingName = RegExp('title="([^"]*)"').firstMatch(line)?.group(1) ?? 
                      (line.contains(',') ? line.substring(line.lastIndexOf(',') + 1).trim() : 'Unknown Channel');
        pendingLogo = RegExp('tvg-logo="([^"]*)"').firstMatch(line)?.group(1);
        pendingGroup = RegExp('group-title="([^"]*)"').firstMatch(line)?.group(1) ?? 'Uncategorized';
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        if (pendingName != null) {
          channels.add(Channel(
            name: pendingName,
            streamUrl: line,
            logoUrl: pendingLogo,
            groupTitle: pendingGroup ?? 'Uncategorized',
          ));
        }
        pendingName = null; pendingLogo = null; pendingGroup = null;
      }
    }
    return channels;
  }
}
