import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        print("Redirecting to OAuth URL: $url");
        Get.snackbar('Google OAuth', 'Membuka portal otorisasi Google Drive...', backgroundColor: Colors.blue.withOpacity(0.1), colorText: Colors.blue);
        isDriveConnected.value = true;
      }
    } catch (e) {
      print("Connect Google Drive error: $e");
    }
  }

  Future<void> migrateFiles() async {
    isMigrating.value = true;
    try {
      final data = await apiService.migrateToDrive();
      if (data != null) {
        Get.snackbar('Migrasi Sukses', 'Semua berkas lokal berhasil dipindahkan ke Google Drive!', backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      } else {
        Get.snackbar('Migrasi Gagal', 'Gagal memindahkan berkas.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      }
    } catch (e) {
      print("Migrate error: $e");
    } finally {
      isMigrating.value = false;
    }
  }

  void logout() {
    apiService.logout();
    Get.offAllNamed('/login');
  }
}
