import 'package:flutter/material.dart';
import '../widgets/disclaimer_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Disclaimer'),
            onTap: () => showDialog(context: context, builder: (_) => const DisclaimerDialog()),
          ),
          const ListTile(leading: const Icon(Icons.developer_board), title: const Text('Version'), trailing: Text('1.0.0 Desktop')),
        ],
      ),
    );
  }
}
