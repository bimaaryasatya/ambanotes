import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/home_controller.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../dashboard/controllers/dashboard_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text("AmbaNotes"),
        leading: IconButton(
          icon: const Icon(LucideIcons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning, Sarah",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 24,
                    color: AppTheme.onSurface,
                  ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 32),
            _buildAgendaHeader(context),
            const SizedBox(height: 16),
            _buildAgendaList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(LucideIcons.search, color: AppTheme.secondary),
          hintText: "Search agendas, files, or ask AmbaAI...",
          hintStyle: TextStyle(fontSize: 14, color: AppTheme.outline),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': LucideIcons.scan, 'label': 'SCAN'},
      {'icon': LucideIcons.upload, 'label': 'UPLOAD'},
      {'icon': LucideIcons.sparkles, 'label': 'AMBAAI', 'isAi': true},
      {'icon': LucideIcons.archive, 'label': 'ARCHIVE'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final isAi = action['isAi'] == true;

        return InkWell(
          onTap: () {
            if (action['label'] == 'AMBAAI') {
              Get.find<DashboardController>().changeTabIndex(3);
            } else if (action['label'] == 'ARCHIVE') {
              Get.find<DashboardController>().changeTabIndex(1);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isAi ? AppTheme.primaryContainer : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  color: isAi ? AppTheme.onPrimaryContainer : AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isAi
                        ? AppTheme.onPrimaryContainer
                        : AppTheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgendaHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today's Agenda",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: AppTheme.primary,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "View All",
            style: TextStyle(fontSize: 14, color: AppTheme.secondary),
          ),
        ),
      ],
    );
  }

  Widget _buildAgendaList() {
    return Obx(() => AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: controller.agenda
                  .map((item) => _buildAgendaItem(item))
                  .toList(),
            ),
          ),
        ));
  }

  Widget _buildAgendaItem(dynamic item) {
    Color priorityColor;
    switch (item.priority) {
      case 'HIGH':
        priorityColor = Colors.red;
        break;
      case 'REVIEW':
        priorityColor = Colors.amber;
        break;
      default:
        priorityColor = AppTheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: priorityColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.priority,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 14, color: AppTheme.outline),
                          const SizedBox(width: 6),
                          Text(
                            "${item.startTime} - ${item.endTime}",
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 14, color: AppTheme.outline),
                          const SizedBox(width: 6),
                          Text(
                            item.location,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
