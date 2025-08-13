// 📄 lib/app/widgets/sidebar_drawer.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_pages.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const DrawerHeader(
            child: Text("Attendance System", style: TextStyle(fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Get.offAllNamed(Routes.DASHBOARD);
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Students"),
            onTap: () {
              Get.offAllNamed(Routes.Students);
            },
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("Report"),
            onTap: () {
              Get.offAllNamed(Routes.AttendanceReport);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note),
            title: const Text("Create Session"),
            onTap: () {
              Get.offAllNamed(Routes.CreateSession);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.event_note),
          //   title: const Text("attendance "),
          //   onTap: () {
          //     Get.offAllNamed(Routes.Attendance);
          //   },
          // ),
        ],
      ),
    );
  }
}
