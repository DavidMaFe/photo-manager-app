import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';


class MainShell extends StatelessWidget {

  final Widget child;
  final StatefulNavigationShell navigationShell;

  const MainShell({
    Key? key,
    required this.child,
    required this.navigationShell
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        selectedItemColor: PhotoManagerColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.folder, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sync, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, size: 28), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: ''),
        ],
      ),
    );
  }
}