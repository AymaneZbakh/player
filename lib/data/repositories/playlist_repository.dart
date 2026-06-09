import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) => PlaylistRepository(ref.watch(sharedPreferencesProvider)));

class PlaylistRepository {
  static const _key = 'playlists_v1';
  final SharedPreferences _prefs;
  PlaylistRepository(this._prefs);

  List<Playlist> loadAll() {
    final raw = _prefs.getStringList(_key) ?? [];
    return raw.map((e) => Playlist.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  Future<void> save(Playlist playlist) async {
    final all = loadAll()..add(playlist);
    await _prefs.setStringList(_key, all.map((p) => jsonEncode(p.toJson())).toList());
  }

  Future<void> remove(String id) async {
    final all = loadAll()..removeWhere((p) => p.id == id);
    await _prefs.setStringList(_key, all.map((p) => jsonEncode(p.toJson())).toList());
  }
}
