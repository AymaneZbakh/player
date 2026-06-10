class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String groupTitle;
  final String currentProgram;
  final String nextProgram;

  const Channel({
    this.id = '',
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle = 'Uncategorized',
    this.currentProgram = 'Live Streaming Event Presentation',
    this.nextProgram = 'Upcoming Interactive Scheduled Segment',
  });
}
