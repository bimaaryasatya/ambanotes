import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';

class NotificationSettingsView extends GetView<ProfileController> {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          "Pengaturan Notifikasi", 
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMasterToggleCard(),
            const SizedBox(height: 24),
            _buildPreferencesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Obx(() => SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: controller.enableNotifications.value ? AppTheme.primary.withOpacity(0.1) : AppTheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(
            controller.enableNotifications.value ? LucideIcons.bellRing : LucideIcons.bellOff, 
            color: controller.enableNotifications.value ? AppTheme.primary : AppTheme.outline,
          ),
        ),
        title: const Text("Notifikasi Sistem", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: const Text("Izinkan AmbaNotes menampilkan notifikasi di latar belakang Android Anda.", style: TextStyle(fontSize: 12)),
        activeColor: AppTheme.primary,
        value: controller.enableNotifications.value,
        onChanged: (val) => controller.toggleNotifications(val),
      )),
    );
  }

  Widget _buildPreferencesCard() {
    return Obx(() {
      final enabled = controller.enableNotifications.value;
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: IgnorePointer(
          ignoring: !enabled,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
                  title: const Text("Pemrosesan Dokumen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text("Pemberitahuan saat analisis AI dan ekstraksi entitas telah selesai."),
                  activeColor: AppTheme.primary,
                  value: controller.notifyProcessing.value,
                  onChanged: (val) => controller.toggleNotifyProcessing(val),
                ),
                const Divider(height: 1, indent: 24, endIndent: 24),
                SwitchListTile(
                  contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
                  title: const Text("Update Insight Mingguan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text("Pemberitahuan metrik terbaru dan ringkasan eksekutif AI."),
                  activeColor: AppTheme.primary,
                  value: controller.notifyInsights.value,
                  onChanged: (val) => controller.toggleNotifyInsights(val),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
