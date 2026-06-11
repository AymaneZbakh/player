import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My IPTV Player',
      theme: ThemeData.dark(),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player player;
  late final VideoController controller;

  final List<Map<String, String>> dummyChannels = [
    {
      "name": "Test Video (Big Buck Bunny)",
      "url": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
    },
    {
      "name": "Live Apple HLS Stream",
      "url": "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
    }
  ];

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void playStream(String url) {
    player.open(Media(url));
    player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My IPTV Player")),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: ListView.builder(
              itemCount: dummyChannels.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(dummyChannels[index]["name"]!),
                  leading: const Icon(Icons.tv),
                  onTap: () => playStream(dummyChannels[index]["url"]!),
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Video(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}
