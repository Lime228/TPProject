import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин'),
      ),
      body: const Center(
        child: Text('Раздел в разработке',
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}