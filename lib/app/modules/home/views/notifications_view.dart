import 'package:ambanotes/app/modules/home/controllers/home_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationsView extends GetView<HomeController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: Obx(() {
        if (controller.isLoadingNotifications.value &&
            controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada notifikasi terbaru.',
              style: TextStyle(color: AppTheme.outline),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            final parsedTime = DateTime.tryParse(item['timestamp'] ?? '');
            final formattedTime = parsedTime != null
                ? DateFormat('dd MMM yyyy, HH:mm').format(parsedTime.toLocal())
                : 'Baru saja';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppTheme.outlineVariant.withOpacity(0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (item['is_personal'] == true
                              ? AppTheme.primary
                              : AppTheme.aiAccent)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item['is_personal'] == true
                          ? LucideIcons.bellRing
                          : LucideIcons.sparkles,
                      color: item['is_personal'] == true
                          ? AppTheme.primary
                          : AppTheme.aiAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] ?? 'Notifikasi',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message'] ?? '',
                          style: const TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
