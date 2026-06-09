import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../data/models/channel.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    player.setProperty('user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
    player.setProperty('referrer', 'https://www.google.com/');
    player.open(Media(widget.channel.streamUrl.trim()));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.channel.name), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(aspectRatio: 16 / 9, child: Video(controller: controller)),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: Text(widget.channel.name, style: const TextStyle(fontSize: 18, color: Colors.white))),
        ],
      ),
    );
  }
}
