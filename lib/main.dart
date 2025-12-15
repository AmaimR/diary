import 'package:flutter/material.dart';

void main() {
  runApp(const TagebuchApp());
}

class TagebuchApp extends StatelessWidget {
  const TagebuchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Privates Tagebuch',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Privates Tagebuch'),
        ),
      ),
    );
  }
}
