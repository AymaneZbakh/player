import 'package:flutter/material.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Important Notice'),
      content: const Text('This Stream Player is an empty container application. It does not provide, host, or contain any pre-loaded media or live streams. You are completely responsible for configuration URLs added to this client.'),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('I Understand'))],
    );
  }
}
