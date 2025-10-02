import 'package:flutter/material.dart';

import '../../../../shared/widgets/bottom_nav_bar.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI ассистент')),
      body: const Center(
        child: Text('AI ассистент в разработке'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
