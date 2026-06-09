import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class M3UParser {
  // Increased timeout to 60 seconds to support massive IPTV provider files
  static const _timeout = Duration(seconds: 60);

  Future<List<Channel>> fetchAndParse(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) {
      throw Exception('Invalid URL format. Make sure it starts with http:// or https://');
    }

    final http.Response response;
    try {
      response = await http.get(
        uri, 
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          'Accept': '*/*',
        },
      ).timeout(_timeout);
    } on TimeoutException {
      throw Exception('The server took too long to respond. The playlist file might be too large or the link is temporarily offline. Try again.');
    } catch (e) {
      throw Exception('Network connection error: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('Server returned error code ${response.statusCode}. Please verify your IPTV link.');
    }

    final body = response.body;
    if (!body.trimLeft().startsWith('#EXTM3U')) {
      throw Exception('The link provided does not point to a valid M3U IPTV playlist file.');
    }

    return _parse(body);
  }

  List<Channel> _parse(String content) {
    final channels = <Channel>[];
    final lines = content.split(RegExp(r'\r?\n'));

    String? pendingName;
    String? pendingLogo;
    String? pendingGroup;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line == '#EXTM3U') continue;

      if (line.startsWith('#EXTINF:')) {
        pendingName = RegExp('group-title="([^"]*)"').hasMatch(line) 
            ? (RegExp('title="([^"]*)"').firstMatch(line)?.group(1) ?? _extractFallbackName(line))
            : _extractFallbackName(line);
            
        pendingLogo = RegExp('tvg-logo="([^"]*)"').firstMatch(line)?.group(1);
        pendingGroup = RegExp('group-title="([^"]*)"').firstMatch(line)?.group(1) ?? 'Uncategorized';
      } else if (!line.startsWith('#')) {
        if (line.isNotEmpty) {
          channels.add(Channel(
            name: pendingName ?? 'Unknown Channel',
            streamUrl: line,
            logoUrl: pendingLogo,
            groupTitle: pendingGroup ?? 'Uncategorized',
          ));
        }
        pendingName = null;
        pendingLogo = null;
        pendingGroup = null;
      }
    }
    return channels;
  }

  String _extractFallbackName(String line) {
    if (line.contains(',')) {
      return line.substring(line.lastIndexOf(',') + 1).trim();
    }
    return 'Live Stream';
  }
}
