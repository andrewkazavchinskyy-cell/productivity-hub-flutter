import 'package:flutter/material.dart';

import '../../../../shared/widgets/bottom_nav_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: const Center(
        child: Text('Настройки в разработке'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
