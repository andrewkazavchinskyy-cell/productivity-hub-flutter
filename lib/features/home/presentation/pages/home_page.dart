import 'package:flutter/material.dart';

import '../../../../shared/widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')), 
      body: const Center(
        child: Text('Экран главной страницы в разработке'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
