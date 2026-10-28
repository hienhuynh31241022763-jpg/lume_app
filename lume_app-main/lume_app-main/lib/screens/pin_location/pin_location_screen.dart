import 'package:flutter/material.dart';

class PinLocationScreen extends StatelessWidget {
  const PinLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ghim vị trí')),
      body: const Center(child: Text('Ghim vị trí (đang làm)')),
    );
  }
}
