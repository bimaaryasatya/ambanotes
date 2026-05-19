import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ambanotes/app/modules/home/views/home_view.dart';
import 'package:ambanotes/app/modules/archive/views/archive_view.dart';
import 'package:ambanotes/app/modules/chat/views/chat_view.dart';
import 'package:ambanotes/app/modules/profile/views/profile_view.dart';
import 'package:ambanotes/app/modules/add/views/add_view.dart';
import 'package:ambanotes/app/theme/app_theme.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeView(),
            ArchiveView(),
            AddView(),
            ChatView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => SafeArea(
          bottom: true,
          child: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.outline,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: const [
              BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Files'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.plusCircle), label: 'Add'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.sparkles), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
            ],
            onTap: controller.changeTabIndex,
          ),
        ),
      ),
    );
  }
}
