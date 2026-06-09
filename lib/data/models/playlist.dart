class Playlist {
  final String id;
  final String name;
  final String url;
  final DateTime addedAt;

  const Playlist({required this.id, required this.name, required this.url, required this.addedAt});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'url': url, 'addedAt': addedAt.toIso8601String()};

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        addedAt: DateTime.parse(json['addedAt'] as String),
      );
}
