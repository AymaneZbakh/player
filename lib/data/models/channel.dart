class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String groupTitle;
  final bool isFavorite;
  final List<String> customFolderIds;
  final String currentProgram;
  final String nextProgram;
  final double programProgress; // Value between 0.0 and 1.0

  const Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle = 'Uncategorized',
    this.isFavorite = false,
    this.customFolderIds = const [],
    this.currentProgram = 'Live Broadcast Program',
    this.nextProgram = 'Upcoming Scheduled Content',
    this.programProgress = 0.35,
  });

  Channel copyWith({
    bool? isFavorite,
    List<String>? customFolderIds,
    String? currentProgram,
    String? nextProgram,
    double? programProgress,
  }) {
    return Channel(
      id: id,
      name: name,
      streamUrl: streamUrl,
      logoUrl: logoUrl,
      groupTitle: groupTitle,
      isFavorite: isFavorite ?? this.isFavorite,
      customFolderIds: customFolderIds ?? this.customFolderIds,
      currentProgram: currentProgram ?? this.currentProgram,
      nextProgram: nextProgram ?? this.nextProgram,
      programProgress: programProgress ?? this.programProgress,
    );
  }
}
