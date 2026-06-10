enum MediaType { live, movie, series }

class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String groupTitle;
  final MediaType type;
  
  // Live TV Meta
  final String currentProgram;
  final String nextProgram;
  final double programProgress;

  // Video-On-Demand (VOD) Meta
  final String releaseYear;
  final String durationOrSeasons;
  final String rating;
  final String plotSummary;

  const Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle = 'General',
    this.type = MediaType.live,
    this.currentProgram = 'Live Broadcast Stream',
    this.nextProgram = 'Upcoming Scheduled Program',
    this.programProgress = 0.40,
    this.releaseYear = '2026',
    this.durationOrSeasons = 'N/A',
    this.rating = '7.5',
    this.plotSummary = 'No structural EPG summary metadata or storyline plot information is provided by the active playlist container source feed.',
  });

  Channel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? groupTitle,
    MediaType? type,
    String? currentProgram,
    String? nextProgram,
    double? programProgress,
    String? releaseYear,
    String? durationOrSeasons,
    String? rating,
    String? plotSummary,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      groupTitle: groupTitle ?? this.groupTitle,
      type: type ?? this.type,
      currentProgram: currentProgram ?? this.currentProgram,
      nextProgram: nextProgram ?? this.nextProgram,
      programProgress: programProgress ?? this.programProgress,
      releaseYear: releaseYear ?? this.releaseYear,
      durationOrSeasons: durationOrSeasons ?? this.durationOrSeasons,
      rating: rating ?? this.rating,
      plotSummary: plotSummary ?? this.plotSummary,
    );
  }
}
