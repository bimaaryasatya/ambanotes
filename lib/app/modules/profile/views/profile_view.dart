import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';
import 'security_view.dart';
import 'notification_settings_view.dart';
import 'manage_enterprise_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text("Pengaturan & Profil",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.primary)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.red),
            onPressed: controller.logout,
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildGoogleDriveCard(),
              const SizedBox(height: 24),
              _buildGeneralSettingsCard(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2), width: 2),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDmU6mMwiX67PUwAXsSeel6gR6OcCaGid7ocK9MoDsDXFStorjDCsvKbQHT2Vm0fUGtCM1YVhoEhJMe5kNYPOIAbfhqNP28Wp6EGhevy3WIPRrObwRIAeRUnLZIJQ7rwkO133r4qEX6HRgzf5ZBocAlxCoHhPtJVLpMvUSQfGFQ95yNwh9RlBu37TYcaHmWzW74vVSV3crHQnydSGuM288kkNwQMBTzMthQBsYMEqFFe6pDYB6k0nnrHLmNZ1ygQmD4j0kggcdubE8z'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.username.value.toUpperCase(),
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            controller.email.value,
            style: const TextStyle(fontSize: 13, color: AppTheme.outline),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.building2,
                    size: 14, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  controller.orgName.value.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 0.5),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: controller.role.value == 'owner'
                        ? Colors.purple
                        : AppTheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.role.value.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (controller.role.value == 'owner' &&
              controller.inviteCode.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: controller.inviteCode.value));
                Get.snackbar(
                  'Salin Berhasil',
                  'Kode undangan "${controller.inviteCode.value}" telah disalin ke clipboard.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.9),
                  colorText: Colors.white,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.copy,
                        size: 14, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      "Kode Undang: ${controller.inviteCode.value}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleDriveCard() {
    final connected = controller.isDriveConnected.value;
    final migrating = controller.isMigrating.value;
    final isOwner = controller.apiService.isOwner;

    if (!isOwner) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.hardDrive, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  "Integrasi Cloud Storage",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Penyimpanan Google Drive organisasi dikelola oleh pemilik organisasi. Dokumen yang Anda unggah tetap aman dan hanya dapat diakses sesuai hak akses Anda, sementara file fisik disimpan secara terpusat di Google Drive owner.",
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.hardDrive, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text("Integrasi Cloud Storage",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: connected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  connected ? "Connected" : "Disconnected",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: connected ? Colors.green : Colors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Hubungkan akun Google Drive institusi Anda untuk mengamankan penyimpanan dokumen digital secara otomatis serta mengaktifkan pemindaian berkas.",
            style: TextStyle(
                fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (!connected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(LucideIcons.lock, size: 16),
                label: const Text("Otorisasi Google Drive",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.connectDrive,
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: migrating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(LucideIcons.refreshCw, size: 16),
                label: Text(
                    migrating
                        ? "Memindahkan Berkas..."
                        : "Migrasikan Berkas Lokal ke Drive",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: migrating ? null : controller.migrateFiles,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.unlock, size: 16),
                label: const Text("Putuskan Koneksi Google Drive",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text("Putuskan Google Drive?",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text(
                          "Apakah Anda yakin ingin memutuskan integrasi Google Drive Anda? Akun akan dilepas dan sinkronisasi berkas otomatis akan dinonaktifkan."),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Batal",
                              style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.disconnectDrive();
                          },
                          child: const Text("Putuskan",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GENERAL SETTINGS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGeneralSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsRow(
            LucideIcons.bell,
            "Pengaturan Notifikasi",
            onTap: () => Get.to(() => const NotificationSettingsView()),
          ),
          const Divider(height: 24),
          _buildSettingsRow(
            LucideIcons.shieldAlert,
            "Keamanan & Sandi",
            onTap: () => Get.to(() => const SecurityView()),
          ),
          const Divider(height: 24),
          if (controller.apiService.isOwner) ...[
            _buildSettingsRow(
              LucideIcons.building2,
              "Manajemen Organisasi",
              onTap: () => Get.to(() => const ManageEnterpriseView()),
            ),
            const Divider(height: 24),
          ],
          _buildSettingsRow(LucideIcons.helpCircle, "Pusat Bantuan AmbaNotes"),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface)),
          const Spacer(),
          const Icon(LucideIcons.chevronRight,
              size: 16, color: AppTheme.outlineVariant),
        ],
      ),
    );
  }
}
