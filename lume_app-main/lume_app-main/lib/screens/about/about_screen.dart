import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Về LUMÉ')),
      body: const Center(child: Text('Về LUMÉ (đang làm)')),
    );
  }
}
