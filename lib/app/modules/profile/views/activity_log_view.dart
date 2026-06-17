import 'package:ambanotes/app/modules/profile/controllers/profile_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActivityLogView extends GetView<ProfileController> {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
      ),
      body: Obx(() {
        if (controller.isLoadingActivityLogs.value &&
            controller.activityLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activityLogs.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada aktivitas yang tercatat.',
              style: TextStyle(color: AppTheme.outline),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.activityLogs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.activityLogs[index];
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
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      LucideIcons.history,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['message'] ?? 'Aktivitas',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item['service'] ?? 'service'} • ${item['action'] ?? 'ACTION'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
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
