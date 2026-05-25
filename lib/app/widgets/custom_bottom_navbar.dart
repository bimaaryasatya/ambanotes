import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:ambanotes/app/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(int index) {
    if (index == currentIndex) return;
    
    switch (index) {
      case 0:
        Get.offAllNamed(Routes.HOME);
        break;
      case 1:
        Get.offAllNamed(Routes.ARCHIVE);
        break;
      case 2:
        Get.offAllNamed(Routes.INSIGHT);
        break;
      case 3:
        Get.offAllNamed(Routes.CHAT);
        break;
      case 4:
        Get.offAllNamed(Routes.PROFILE);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF152023) : Colors.white).withOpacity(0.88),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: (isDark ? const Color(0xFF35413E) : AppTheme.outlineVariant)
                .withOpacity(0.45),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home_filled, label: 'Home', index: 0),
                  _buildNavItem(icon: Icons.description, label: 'Files', index: 1),
                  _buildNavItem(icon: Icons.insights, label: 'Insights', index: 2),
                  _buildNavItem(icon: Icons.auto_awesome, label: 'Chat', index: 3),
                  _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = currentIndex == index;
    final isDark = Get.isDarkMode;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected
                ? AppTheme.primary
                : (isDark ? const Color(0xFFB7C8D3) : AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? AppTheme.primary
                  : (isDark ? const Color(0xFFB7C8D3) : AppTheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
