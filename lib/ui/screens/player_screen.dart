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
  late final Player player;
  late final VideoController controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    player = Player(configuration: const PlayerConfiguration());
    controller = VideoController(player);

    player.open(Media(widget.channel.streamUrl.trim()));
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: _isInitialized
            ? Video(controller: controller, controls: MaterialVideoControls)
            : const CircularProgressIndicator(color: Color(0xFF3B82F6)),
      ),
    );
  }
}
