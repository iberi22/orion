import 'package:flutter/material.dart';

class AnimationDemoApp extends StatelessWidget {
  const AnimationDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Animation Demo')),
        body: const Center(child: Text('Welcome to Animation Demo!')),
      ),
    );
  }
}
