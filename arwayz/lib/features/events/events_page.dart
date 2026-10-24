import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      body: const Center(
        child: Text(
          'Campus events will appear here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
