import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt hàng thành công')),
      body: const Center(child: Text('Đặt hàng thành công (đang làm)')),
    );
  }
}
