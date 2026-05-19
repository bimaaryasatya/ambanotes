import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/api_service.dart';

class ProfileController extends GetxController {
  final apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  
  // Profile stats
  final username = ''.obs;
  final email = ''.obs;
  final role = ''.obs;
  final orgName = ''.obs;

  // Google Drive state
  final isDriveConnected = false.obs;
  final isMigrating = false.obs;
  
  // Organization members
  final members = <Map<String, dynamic>>[].obs;
  final inviteEmailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      // 1. Load User Profile (which directly populates ApiService properties)
      await apiService.getProfile();
      username.value = apiService.username.value ?? '';
      email.value = apiService.email.value ?? '';
      role.value = apiService.role.value ?? '';
      orgName.value = apiService.delegationName.value ?? 'Personal Workspace';

      // 2. Load Google Drive Status from ApiService observable
      isDriveConnected.value = apiService.googleDriveConnected.value;

      // 3. Load Members if Owner
      if (apiService.isOwner) {
        final memberList = await apiService.getOrganizationMembers();
        members.assignAll(List<Map<String, dynamic>>.from(memberList));
      }
    } catch (e) {
      print("Fetch profile data error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> inviteMember() async {
    final emailText = inviteEmailController.text.trim();
    if (emailText.isEmpty) {
      Get.snackbar('Input Error', 'Silakan masukkan email yang valid.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      // Pass both email and role ('member') to the backend
      final success = await apiService.inviteMember(emailText, 'member');
      if (success) {
        Get.snackbar(
          'Undangan Terkirim', 
          'Undangan berhasil dikirim ke $emailText. Berkas lama akan termigrasi setelah mereka mendaftar!', 
          backgroundColor: Colors.green.withOpacity(0.1), 
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM
        );
        inviteEmailController.clear();
        fetchProfileData(); // reload members
      } else {
        Get.snackbar('Error', 'Gagal mengirim undangan.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      }
    } catch (e) {
      print("Invite member error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> connectDrive() async {
    try {
      final url = await apiService.getGoogleConnectUrl();
      if (url != null) {
        print("Google OAuth URL: $url");
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          Get.snackbar('Google OAuth', 'Membuka portal otorisasi Google Drive...', backgroundColor: Colors.blue.withOpacity(0.1), colorText: Colors.blue);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback ke Clipboard jika gagal membuka browser otomatis
          await Clipboard.setData(ClipboardData(text: url));
          Get.snackbar(
            'Google OAuth', 
            'Gagal membuka browser otomatis. Link otorisasi disalin ke clipboard! Tempel di browser Anda.', 
            backgroundColor: Colors.blue.withOpacity(0.1), 
            colorText: Colors.blue,
            duration: const Duration(seconds: 8),
            snackPosition: SnackPosition.BOTTOM
          );
        }
      }
    } catch (e) {
      print("Connect Google Drive error: $e");
    }
  }

  Future<void> disconnectDrive() async {
    isLoading.value = true;
    try {
      final success = await apiService.disconnectGoogleDrive();
      if (success) {
        isDriveConnected.value = false;
        Get.snackbar(
          'Google Drive', 
          'Koneksi Google Drive berhasil diputuskan.', 
          backgroundColor: Colors.green.withOpacity(0.1), 
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM
        );
      } else {
        Get.snackbar(
          'Error', 
          'Gagal memutuskan koneksi Google Drive.', 
          backgroundColor: Colors.red.withOpacity(0.1), 
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM
        );
      }
    } catch (e) {
      print("Disconnect Google Drive error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> migrateFiles() async {
    isMigrating.value = true;
    try {
      final data = await apiService.migrateToDrive();
      if (data != null) {
        final total = data['total_to_migrate'] ?? 0;
        final success = data['migrated_count'] ?? 0;
        final failed = data['failed_count'] ?? 0;

        if (total == 0) {
          Get.snackbar('Migrasi', 'Tidak ada berkas lokal baru yang perlu dipindahkan.', 
              backgroundColor: Colors.blue.withOpacity(0.1), colorText: Colors.blue);
        } else if (success == total) {
          Get.snackbar('Migrasi Sukses', 'Semua berkas lokal ($success/$total) berhasil dipindahkan ke Google Drive!', 
              backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
        } else if (success > 0 && failed > 0) {
          Get.snackbar('Migrasi Parsial', 'Berhasil memindahkan $success berkas, tetapi $failed berkas gagal dipindahkan.', 
              backgroundColor: Colors.amber.withOpacity(0.1), colorText: Colors.amber);
        } else {
          Get.snackbar('Migrasi Gagal', 'Gagal memindahkan berkas. Semua dokumen ($failed) gagal diunggah.', 
              backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
        }
      } else {
        Get.snackbar('Migrasi Gagal', 'Gagal memindahkan berkas.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      }
    } catch (e) {
      print("Migrate error: $e");
      Get.snackbar('Migrasi Gagal', 'Terjadi kesalahan saat memindahkan berkas.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      isMigrating.value = false;
    }
  }

  void logout() {
    apiService.logout();
    Get.offAllNamed('/login');
  }
}
