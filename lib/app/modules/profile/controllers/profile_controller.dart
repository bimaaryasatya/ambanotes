import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/theme_service.dart';

class ProfileController extends GetxController {
  final apiService = Get.find<ApiService>();
  final themeService = Get.find<ThemeService>();

  final isLoading = false.obs;

  // Profile stats
  final username = ''.obs;
  final email = ''.obs;
  final role = ''.obs;
  final fullName = ''.obs;
  final orgName = ''.obs;
  final inviteCode = ''.obs;
  final profileImageData = ''.obs;

  // Google Drive state
  final isDriveConnected = false.obs;
  final isMigrating = false.obs;

  // Organization members
  final members = <Map<String, dynamic>>[].obs;
  final inviteEmailController = TextEditingController();

  // Organization assets (kop & ttd)
  final assets = <Map<String, dynamic>>[].obs;
  final activityLogs = <Map<String, dynamic>>[].obs;
  final isLoadingActivityLogs = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotificationSettings();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      // 1. Load User Profile (which directly populates ApiService properties)
      await apiService.getProfile();
      username.value = apiService.username.value ?? '';
      fullName.value = apiService.username.value ?? '';
      email.value = apiService.email.value ?? '';
      role.value = apiService.role.value ?? '';
      orgName.value = apiService.orgName.value ?? 'Personal Workspace';
      inviteCode.value = apiService.inviteCode.value ?? '';
      profileImageData.value = apiService.profileImageData.value ?? '';

      // 2. Load Google Drive Status from ApiService observable
      isDriveConnected.value = apiService.googleDriveConnected.value;

      // 3. Load Members if Owner
      if (apiService.isOwner) {
        final memberList = await apiService.getOrganizationMembers();
        members.assignAll(List<Map<String, dynamic>>.from(memberList));
        await fetchDelegations();
        await fetchAssets();
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
      Get.snackbar('Input Error', 'Silakan masukkan email yang valid.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      // Pass both email and role ('member') to the backend
      final success = await apiService.inviteMember(emailText, 'member');
      if (success) {
        Get.snackbar('Undangan Terkirim',
            'Undangan berhasil dikirim ke $emailText. Berkas lama akan termigrasi setelah mereka mendaftar!',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        inviteEmailController.clear();
        fetchProfileData(); // reload members
      } else {
        print("Invitation failed, detailed snackbar shown by ApiService.");
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
          Get.snackbar(
              'Google OAuth', 'Membuka portal otorisasi Google Drive...',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback ke Clipboard jika gagal membuka browser otomatis
          await Clipboard.setData(ClipboardData(text: url));
          Get.snackbar('Google OAuth',
              'Gagal membuka browser otomatis. Link otorisasi disalin ke clipboard! Tempel di browser Anda.',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue,
              duration: const Duration(seconds: 8),
              snackPosition: SnackPosition.BOTTOM);
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
            'Google Drive', 'Koneksi Google Drive berhasil diputuskan.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Gagal memutuskan koneksi Google Drive.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
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
          Get.snackbar(
              'Migrasi', 'Tidak ada berkas lokal baru yang perlu dipindahkan.',
              backgroundColor: Colors.blue.withOpacity(0.1),
              colorText: Colors.blue);
        } else if (success == total) {
          Get.snackbar('Migrasi Sukses',
              'Semua berkas lokal ($success/$total) berhasil dipindahkan ke Google Drive!',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green);
        } else if (success > 0 && failed > 0) {
          Get.snackbar('Migrasi Parsial',
              'Berhasil memindahkan $success berkas, tetapi $failed berkas gagal dipindahkan.',
              backgroundColor: Colors.amber.withOpacity(0.1),
              colorText: Colors.amber);
        } else {
          Get.snackbar('Migrasi Gagal',
              'Gagal memindahkan berkas. Semua dokumen ($failed) gagal diunggah.',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red);
        }
      } else {
        Get.snackbar('Migrasi Gagal', 'Gagal memindahkan berkas.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red);
      }
    } catch (e) {
      print("Migrate error: $e");
      Get.snackbar(
          'Migrasi Gagal', 'Terjadi kesalahan saat memindahkan berkas.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      isMigrating.value = false;
    }
  }

  void logout() {
    apiService.logout();
    Get.offAllNamed('/login');
  }

  Future<void> fetchActivityLogs() async {
    isLoadingActivityLogs.value = true;
    try {
      final result = await apiService.getActivityLogs(limit: 100);
      activityLogs.assignAll(List<Map<String, dynamic>>.from(result));
    } catch (e) {
      print("Fetch activity logs error: $e");
    } finally {
      isLoadingActivityLogs.value = false;
    }
  }

  // --- Security & Account Management ---
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> updatePassword() async {
    final oldPass = oldPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar('Input Error', 'Semua kolom password harus diisi.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar('Input Error', 'Konfirmasi password baru tidak cocok.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      final success = await apiService.changePassword(oldPass, newPass);
      if (success) {
        Get.snackbar(
            'Password Diperbarui', 'Password Anda berhasil diperbarui.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
    } catch (e) {
      print("Update password error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeAccount() async {
    isLoading.value = true;
    try {
      final success = await apiService.deleteAccount();
      if (success) {
        Get.snackbar(
            'Akun Dihapus', 'Akun Anda telah berhasil dihapus selamanya.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        logout();
      }
    } catch (e) {
      print("Delete account error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  final _picker = ImagePicker();

  Future<void> pickAndUpdateProfilePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image == null) return;

    isLoading.value = true;
    try {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final result = await apiService.updateProfile(
        profileImageBase64: base64Image,
      );
      if (result != null) {
        profileImageData.value = base64Image;
        Get.snackbar(
          'Foto Profil Diperbarui',
          'Foto profil berhasil diperbarui.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Foto profil gagal diperbarui.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Update profile photo error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrganizationName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    isLoading.value = true;
    try {
      final result = await apiService.updateProfile(orgNameInput: trimmed);
      if (result != null) {
        orgName.value = apiService.orgName.value ?? trimmed;
        Get.snackbar(
          'Organisasi Diperbarui',
          'Nama organisasi berhasil diperbarui.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Nama organisasi gagal diperbarui.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Update organization name error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Notification Preferences ---
  final _storage = GetStorage();
  final enableNotifications = true.obs;
  final notifyProcessing = true.obs;
  final notifyInsights = true.obs;

  void loadNotificationSettings() {
    enableNotifications.value = _storage.read('enableNotifications') ?? true;
    notifyProcessing.value = _storage.read('notifyProcessing') ?? true;
    notifyInsights.value = _storage.read('notifyInsights') ?? true;
  }

  void toggleNotifications(bool value) {
    enableNotifications.value = value;
    _storage.write('enableNotifications', value);
  }

  void toggleNotifyProcessing(bool value) {
    notifyProcessing.value = value;
    _storage.write('notifyProcessing', value);
  }

  void toggleNotifyInsights(bool value) {
    notifyInsights.value = value;
    _storage.write('notifyInsights', value);
  }

  // --- Delegation Management ---
  final delegations = <Map<String, dynamic>>[].obs;
  final delegationNameController = TextEditingController();

  // Batch selection for delegations
  final isDelegationSelectionMode = false.obs;
  final selectedDelegationIds = <String>{}.obs;

  void toggleDelegationSelectionMode() {
    isDelegationSelectionMode.value = !isDelegationSelectionMode.value;
    if (!isDelegationSelectionMode.value) selectedDelegationIds.clear();
  }

  void toggleDelegationSelection(String id) {
    if (selectedDelegationIds.contains(id)) {
      selectedDelegationIds.remove(id);
    } else {
      selectedDelegationIds.add(id);
    }
  }

  void selectAllDelegations() {
    if (selectedDelegationIds.length == delegations.length) {
      selectedDelegationIds.clear();
    } else {
      selectedDelegationIds
          .assignAll(delegations.map((a) => a['_id'] as String));
    }
  }

  Future<void> deleteSelectedDelegations() async {
    if (selectedDelegationIds.isEmpty) return;

    final count = selectedDelegationIds.length;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Divisi Terpilih',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus $count divisi yang dipilih? Semua anggota di dalam divisi tersebut akan dipindahkan ke General (tanpa divisi).',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus Semua',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isLoading.value = true;
    int successCount = 0;
    try {
      for (final id in selectedDelegationIds.toList()) {
        final ok = await apiService.deleteDelegation(id);
        if (ok) successCount++;
      }
      Get.snackbar(
          'Berhasil', '$successCount dari $count divisi berhasil dihapus.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM);
      selectedDelegationIds.clear();
      isDelegationSelectionMode.value = false;
      await fetchDelegations();
      await fetchProfileData();
    } catch (e) {
      print("Batch delete delegation error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDelegations() async {
    try {
      final list = await apiService.getDelegations();
      delegations.assignAll(List<Map<String, dynamic>>.from(list));
    } catch (e) {
      print("Fetch delegations error: $e");
    }
  }

  Future<void> createDelegation(String name) async {
    if (name.trim().isEmpty) return;
    isLoading.value = true;
    try {
      final success = await apiService.createDelegation(name);
      if (success) {
        Get.snackbar('Sukses', 'Delegasi "$name" berhasil dibuat.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        delegationNameController.clear();
        await fetchDelegations();
      } else {
        Get.snackbar('Gagal', 'Gagal membuat delegasi.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Create delegation error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renameDelegation(String id, String name) async {
    if (name.trim().isEmpty) return;
    isLoading.value = true;
    try {
      final success = await apiService.updateDelegation(id, name);
      if (success) {
        Get.snackbar('Sukses', 'Delegasi berhasil diubah nama menjadi "$name".',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchDelegations();
        await fetchProfileData();
      } else {
        Get.snackbar('Gagal', 'Gagal mengubah nama delegasi.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Rename delegation error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDelegation(String id) async {
    isLoading.value = true;
    try {
      final success = await apiService.deleteDelegation(id);
      if (success) {
        Get.snackbar('Sukses',
            'Delegasi berhasil dihapus dan semua anggota dialihkan ke general.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchDelegations();
        await fetchProfileData();
      } else {
        Get.snackbar('Gagal', 'Gagal menghapus delegasi.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Delete delegation error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> moveMemberDelegation(
      String targetUserId, String newDelegationId) async {
    isLoading.value = true;
    try {
      final success =
          await apiService.changeDelegation(targetUserId, newDelegationId);
      if (success) {
        Get.snackbar('Sukses', 'Anggota berhasil dipindahkan delegasi/divisi.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchProfileData(); // reload members list
      } else {
        Get.snackbar('Gagal', 'Gagal memindahkan anggota ke delegasi.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Move member delegation error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> moveMultipleMembersDelegation(
      List<String> targetUserIds, String newDelegationId) async {
    isLoading.value = true;
    try {
      int successCount = 0;
      for (final uid in targetUserIds) {
        final success = await apiService.changeDelegation(uid, newDelegationId);
        if (success) {
          successCount++;
        }
      }
      Get.snackbar('Batch Update Selesai',
          '$successCount dari ${targetUserIds.length} anggota berhasil dipindahkan.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM);
      await fetchProfileData(); // reload members list
    } catch (e) {
      print("Move multiple members error: $e");
      Get.snackbar('Error', 'Terjadi kesalahan saat memproses batch update: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Asset Management (Kop Surat & TTD Digital) ---
  final isUploadingAsset = false.obs;

  // Batch selection
  final isSelectionMode = false.obs;
  final selectedAssetIds = <String>{}.obs;

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) selectedAssetIds.clear();
  }

  void toggleAssetSelection(String assetId) {
    if (selectedAssetIds.contains(assetId)) {
      selectedAssetIds.remove(assetId);
    } else {
      selectedAssetIds.add(assetId);
    }
  }

  void selectAllAssets() {
    if (selectedAssetIds.length == assets.length) {
      selectedAssetIds.clear();
    } else {
      selectedAssetIds.assignAll(assets.map((a) => a['id'] as String));
    }
  }

  Future<void> deleteSelectedAssets() async {
    if (selectedAssetIds.isEmpty) return;

    final count = selectedAssetIds.length;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Aset Terpilih',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus $count aset yang dipilih? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus Semua',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isUploadingAsset.value = true;
    int successCount = 0;
    try {
      for (final id in selectedAssetIds.toList()) {
        final ok = await apiService.deleteAsset(id);
        if (ok) successCount++;
      }
      Get.snackbar(
          'Berhasil', '$successCount dari $count aset berhasil dihapus.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM);
      selectedAssetIds.clear();
      isSelectionMode.value = false;
      await fetchAssets();
    } catch (e) {
      print("Batch delete error: $e");
    } finally {
      isUploadingAsset.value = false;
    }
  }

  Future<void> pickAndUploadAsset(String assetType) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image == null) return;

    final nameController = TextEditingController();
    final nameResult = await Get.dialog<String>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
          assetType == 'kop' ? 'Beri Nama Kop Surat' : 'Beri Nama TTD Digital',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'Masukkan nama/label untuk ${assetType == 'kop' ? "Kop Surat" : "Tanda Tangan"} ini agar dapat dipilih di dropdown.',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: assetType == 'kop'
                  ? 'Kop Utama, Kop Dinas, dll'
                  : 'TTD Kepala, TTD Plt, dll',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              Get.back(result: name);
            } else {
              Get.snackbar('Input Error', 'Nama tidak boleh kosong',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red);
            }
          },
          child: const Text('Simpan & Upload',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
        ),
      ],
    ));

    if (nameResult == null || nameResult.isEmpty) return;

    isUploadingAsset.value = true;
    try {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final delegId = apiService.delegationId.value ?? '';

      final success = await apiService.uploadAsset(
          assetType, delegId, base64Image, nameResult);
      if (success) {
        Get.snackbar(
          'Berhasil Diunggah',
          'Aset "$nameResult" berhasil diperbarui.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchAssets();
      } else {
        Get.snackbar(
          'Gagal',
          'Upload aset gagal. Silakan coba lagi.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Upload asset error: $e");
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingAsset.value = false;
    }
  }

  /// Upload aset (kop/ttd) langsung ke divisi tertentu (dipanggil dari section per divisi).
  Future<void> pickAndUploadAssetToDelegation(String assetType,
      String targetDelegationId, String delegationName) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image == null) return;

    final nameController = TextEditingController();
    final nameResult = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          assetType == 'kop'
              ? 'Kop Surat — $delegationName'
              : 'TTD Digital — $delegationName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan nama untuk ${assetType == 'kop' ? "Kop Surat" : "Tanda Tangan"} '
              'divisi "$delegationName". Aset baru akan berstatus nonaktif, aktifkan setelah upload.',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: assetType == 'kop'
                    ? 'Kop Utama, Kop Dinas, dll'
                    : 'TTD Kepala, TTD Plt, dll',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Get.back(result: name);
              } else {
                Get.snackbar('Input Error', 'Nama tidak boleh kosong',
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red);
              }
            },
            child: const Text('Upload',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple)),
          ),
        ],
      ),
    );

    if (nameResult == null || nameResult.isEmpty) return;

    isUploadingAsset.value = true;
    try {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final success = await apiService.uploadAsset(
          assetType, targetDelegationId, base64Image, nameResult);
      if (success) {
        Get.snackbar(
          'Berhasil Diunggah',
          'Aset "$nameResult" berhasil ditambahkan ke divisi $delegationName. Aktifkan untuk menggunakannya.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchAssets();
      } else {
        Get.snackbar(
          'Gagal',
          'Upload aset gagal. Silakan coba lagi.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Upload asset to delegation error: $e");
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingAsset.value = false;
    }
  }

  Future<void> fetchAssets() async {
    try {
      final result = await apiService.getAssets();
      assets.assignAll(List<Map<String, dynamic>>.from(result));
    } catch (e) {
      print("Fetch assets error: $e");
    }
  }

  Future<void> deleteAsset(String assetId, String assetName) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Aset',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Apakah Anda yakin ingin menghapus aset "$assetName"? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isUploadingAsset.value = true;
    try {
      final success = await apiService.deleteAsset(assetId);
      if (success) {
        Get.snackbar('Berhasil', 'Aset "$assetName" telah dihapus.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchAssets();
      } else {
        Get.snackbar('Gagal', 'Gagal menghapus aset.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Delete asset error: $e");
    } finally {
      isUploadingAsset.value = false;
    }
  }

  Future<void> updateAssetName(String assetId, String currentName) async {
    final nameController = TextEditingController(text: currentName);
    final newName = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ubah Nama Aset',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nama baru aset',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Get.back(result: name);
              }
            },
            child: const Text('Simpan',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.purple)),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == currentName) return;

    isUploadingAsset.value = true;
    try {
      final success = await apiService.updateAsset(assetId, name: newName);
      if (success) {
        Get.snackbar('Berhasil', 'Nama aset diperbarui menjadi "$newName".',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchAssets();
      } else {
        Get.snackbar('Gagal', 'Gagal memperbarui nama aset.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Update asset error: $e");
    } finally {
      isUploadingAsset.value = false;
    }
  }

  Future<void> updateAssetImage(String assetId, String assetName) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image == null) return;

    isUploadingAsset.value = true;
    try {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final success =
          await apiService.updateAsset(assetId, base64Image: base64Image);
      if (success) {
        Get.snackbar(
            'Berhasil', 'Gambar aset "$assetName" berhasil diperbarui.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchAssets();
      } else {
        Get.snackbar('Gagal', 'Gagal memperbarui gambar aset.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Update asset image error: $e");
    } finally {
      isUploadingAsset.value = false;
    }
  }

  Future<void> toggleAssetActivation(
      String assetId, String name, bool currentActive) async {
    isLoading.value = true;
    try {
      final newStatus = !currentActive;
      final success =
          await apiService.updateAsset(assetId, isActive: newStatus);
      if (success) {
        Get.snackbar('Berhasil',
            'Aset "$name" berhasil ${newStatus ? "diaktifkan" : "dinonaktifkan"}.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
        await fetchAssets();
      } else {
        Get.snackbar('Gagal', 'Gagal mengubah status aktif aset.',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print("Toggle asset activation error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
