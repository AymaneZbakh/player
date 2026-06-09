class Channel {
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String groupTitle;

  const Channel({
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle = 'Uncategorized',
  });
}
