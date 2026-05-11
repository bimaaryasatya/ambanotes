import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildMenuGroup([
                    {
                      'label': 'Manage Institution',
                      'icon': LucideIcons.building2
                    },
                    {'label': 'My Activity', 'icon': LucideIcons.history},
                    {'label': 'Saved Documents', 'icon': LucideIcons.bookmark},
                  ]),
                  const SizedBox(height: 20),
                  _buildMenuGroup([
                    {'label': 'Security', 'icon': LucideIcons.shield},
                    {
                      'label': 'Notification Settings',
                      'icon': LucideIcons.bellRing
                    },
                    {'label': 'Integrations', 'icon': LucideIcons.puzzle},
                    {
                      'label': 'Language',
                      'icon': LucideIcons.languages,
                      'value': 'English'
                    },
                  ]),
                  const SizedBox(height: 20),
                  _buildMenuGroup([
                    {'label': 'Help Center', 'icon': LucideIcons.helpCircle},
                    {
                      'label': 'Logout',
                      'icon': LucideIcons.logOut,
                      'isDanger': true
                    },
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDmU6mMwiX67PUwAXsSeel6gR6OcCaGid7ocK9MoDsDXFStorjDCsvKbQHT2Vm0fUGtCM1YVhoEhJMe5kNYPOIAbfhqNP28Wp6EGhevy3WIPRrObwRIAeRUnLZIJQ7rwkO133r4qEX6HRgzf5ZBocAlxCoHhPtJVLpMvUSQfGFQ95yNwh9RlBu37TYcaHmWzW74vVSV3crHQnydSGuM288kkNwQMBTzMthQBsYMEqFFe6pDYB6k0nnrHLmNZ1ygQmD4j0kggcdubE8z'),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Sarah Mitchell",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface)),
          const Text("Senior Executive Secretary",
              style: TextStyle(fontSize: 14, color: AppTheme.outline)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.building2, size: 14, color: AppTheme.primary),
                SizedBox(width: 8),
                Text("DEPT. OF ADMINISTRATION",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: items
            .map((item) => _buildMenuItem(item, item == items.last))
            .toList(),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isLast) {
    final isDanger = item['isDanger'] == true;
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                      color: AppTheme.outlineVariant.withOpacity(0.1))),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color:
                      isDanger ? Colors.red.withOpacity(0.1) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(item['icon'] as IconData,
                  size: 20, color: isDanger ? Colors.red : AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(item['label'] as String,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDanger ? Colors.red : AppTheme.onSurface)),
            ),
            if (item['value'] != null) ...[
              Text(item['value'] as String,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.outline)),
              const SizedBox(width: 8),
            ],
            if (!isDanger)
              const Icon(LucideIcons.chevronRight,
                  size: 16, color: AppTheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
