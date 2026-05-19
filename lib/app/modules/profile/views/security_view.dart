import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';

class SecurityView extends GetView<ProfileController> {
  const SecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          "Keamanan & Sandi", 
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChangePasswordSection(),
              const SizedBox(height: 24),
              _buildDeleteAccountSection(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChangePasswordSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.lock, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                "Ganti Password", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Perbarui kata sandi akun Anda secara berkala untuk menjaga kerahasiaan arsip surat dan data organisasi.",
            style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.oldPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password Lama",
              prefixIcon: const Icon(LucideIcons.key, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password Baru",
              prefixIcon: const Icon(LucideIcons.shieldCheck, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Konfirmasi Password Baru",
              prefixIcon: const Icon(LucideIcons.checkSquare, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text("Perbarui Password", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: controller.updatePassword,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.005),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.userX, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Zona Bahaya", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Tindakan menghapus akun bersifat permanen. Seluruh akses Anda ke dokumen organisasi, riwayat disposisi, dan delegasi unit akan terhapus selamanya dan tidak dapat dikembalikan.",
            style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(LucideIcons.trash2, size: 16),
              label: const Text("Hapus Akun Saya Selamanya", style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.red.withOpacity(0.02),
              ),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Row(
                      children: const [
                        Icon(LucideIcons.alertTriangle, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Hapus Akun?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    content: const Text(
                      "Apakah Anda benar-benar yakin ingin menghapus akun AmbaNotes Anda secara permanen? Semua data delegasi dan akses surat Anda akan segera dihapus selamanya."
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.removeAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Hapus Permanen", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
