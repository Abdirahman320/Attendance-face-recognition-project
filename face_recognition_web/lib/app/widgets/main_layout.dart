import 'package:flutter/material.dart';
import 'sidebar_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title; // Added title parameter

  const MainLayout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      appBar: AppBar(
        title: SelectableText(title), // Use the dynamic title here
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      drawer: const SidebarDrawer(),
      body: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
