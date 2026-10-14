import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'custom_app_bar.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (Navigator.canPop(context))
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: 'Go Back',
            onPressed: () => Navigator.pop(context),
          ),
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Home Screen',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}