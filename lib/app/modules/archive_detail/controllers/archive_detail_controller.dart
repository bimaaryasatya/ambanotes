import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ambanotes/app/data/models/models.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/api_service.dart';

class ArchiveDetailController extends GetxController {
  final apiService = Get.find<ApiService>();

  late Document document;
  final isLoading = false.obs;
  final securitySuggestion = ''.obs;
  final nomorSurat = ''.obs;
  final perihal = ''.obs;
  final organisasiPenerbit = ''.obs;
  final uploadedBy = ''.obs;
  final googleDriveConnected = false.obs;

  final base64Image = ''.obs;
  final driveWebViewLink = ''.obs;
  final driveContentLink = ''.obs;
  final mimetype = ''.obs;

  final delegationId = RxnString();
  final delegationName = RxnString();
  final delegations = <Map<String, dynamic>>[].obs;

  final isAnalyzingDisposition = false.obs;
  final aiSuggestedDelegation = ''.obs;
  final aiSuggestedReason = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Document) {
      document = args;
      fetchDetailedData();
    } else {
      document = Document(
        id: 'error',
        title: 'Error Loading Document',
        summary: 'No details available.',
        status: 'Error',
        type: 'Error',
        archivedDate: 'Unknown',
        size: '0 KB',
      );
    }
  }

  Future<void> fetchDetailedData() async {
    isLoading.value = true;
    try {
      final detail = await apiService.getDocumentDetail(document.id);
      if (detail != null) {
        final entities = detail['entities'] ?? {};
        nomorSurat.value = entities['nomor_surat'] ?? 'Tidak Terdeteksi';
        perihal.value = entities['perihal'] ?? 'Tidak Terdeteksi';
        organisasiPenerbit.value =
            entities['organisasi_penerbit'] ?? 'Tidak Terdeteksi';

        securitySuggestion.value = detail['security_suggestion'] ?? '';
        uploadedBy.value = detail['uploaded_by']?.toString() ?? 'Admin User';

        mimetype.value = detail['mimetype'] ?? 'image/jpeg';

        final gd = detail['google_drive'];

        if (gd != null &&
            ((gd['web_view_link'] ?? '').toString().isNotEmpty ||
                (gd['web_content_link'] ?? '').toString().isNotEmpty)) {
          googleDriveConnected.value = true;
          driveWebViewLink.value = gd['web_view_link'] ?? '';
          driveContentLink.value = gd['web_content_link'] ?? '';
          base64Image.value = '';
        } else {
          googleDriveConnected.value = false;
          driveWebViewLink.value = '';
          driveContentLink.value = '';
          base64Image.value = detail['file_data'] ?? '';
        }

        delegationId.value = detail['delegation_id'];
        if (apiService.isOwner) {
          final list = await apiService.getDelegations();
          delegations.assignAll(List<Map<String, dynamic>>.from(list));

          if (delegationId.value != null) {
            final found = delegations
                .firstWhereOrNull((d) => d['_id'] == delegationId.value);
            delegationName.value =
                found != null ? found['name'] : 'Belum Ditentukan';
          } else {
            delegationName.value = 'Belum Ditentukan';
          }
        }
      }
    } catch (e) {
      print("Fetch document details error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void askAIForMore() {
    Get.toNamed('/chat', arguments: {
      'context': 'document',
      'docId': document.id,
      'documentTitle': document.title,
      'documentSummary': document.summary,
    });
  }

  Future<void> downloadDocument() async {
    if (googleDriveConnected.value && driveWebViewLink.value.isNotEmpty) {
      final url = driveContentLink.value.isNotEmpty
          ? driveContentLink.value
          : driveWebViewLink.value;
      Get.snackbar(
        'Download',
        'Membuka tautan unduh di browser...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary.withOpacity(0.9),
        colorText: Colors.white,
      );
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar('Error', 'Gagal membuka browser: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else if (base64Image.value.isNotEmpty) {
      try {
        final bytes = base64Decode(base64Image.value);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${document.title}');
        await file.writeAsBytes(bytes);

        Get.snackbar(
          'Download Berhasil',
          'Berkas disimpan sementara di ${file.path}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () {
              Share.shareXFiles([XFile(file.path)], text: document.title);
            },
            child: const Text('Buka',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      } catch (e) {
        Get.snackbar('Error', 'Gagal mengunduh dokumen: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Info', 'Sumber dokumen tidak tersedia.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> backupToLocal() async {
    try {
      List<int>? bytes;

      if (googleDriveConnected.value) {
        bytes = await apiService.downloadDocumentBytes(document.id);
      } else if (base64Image.value.isNotEmpty) {
        bytes = base64Decode(base64Image.value);
      }

      if (bytes == null || bytes.isEmpty) {
        Get.snackbar(
          'Backup Gagal',
          'Sumber dokumen tidak tersedia.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Directory? targetDir;

      if (Platform.isAndroid) {
        targetDir = Directory('/storage/emulated/0/Download');

        if (!await targetDir.exists()) {
          targetDir = await getExternalStorageDirectory();
        }
      } else {
        targetDir = await getApplicationDocumentsDirectory();
      }

      if (targetDir == null) {
        Get.snackbar(
          'Backup Gagal',
          'Folder penyimpanan tidak ditemukan.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final safeName = document.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final file = File('${targetDir.path}/$safeName');

      await file.writeAsBytes(bytes);

      Get.snackbar(
        'Backup Berhasil',
        'Dokumen berhasil disimpan ke ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Backup Error',
        'Gagal mencadangkan dokumen: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareDocument() async {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Bagikan Dokumen',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  document.title,
                  style: const TextStyle(fontSize: 14, color: AppTheme.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(LucideIcons.share2, color: AppTheme.primary),
                  ),
                  title: const Text('Bagikan via Aplikasi Sistem',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Kirim berkas/tautan via WhatsApp, Gmail, dll.'),
                  onTap: () async {
                    Get.back();
                    await _triggerNativeShare();
                  },
                ),
                const Divider(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.copy, color: Colors.blue),
                  ),
                  title: const Text('Salin Informasi Dokumen',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Salin ringkasan dan tautan dokumen ke papan klip.'),
                  onTap: () {
                    Get.back();
                    _copyDocInfoToClipboard();
                  },
                ),
                if (googleDriveConnected.value &&
                    driveWebViewLink.value.isNotEmpty) ...[
                  const Divider(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.externalLink,
                          color: Colors.green),
                    ),
                    title: const Text('Buka Tautan Google Drive',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                        'Buka pratinjau berkas di Google Drive Anda.'),
                    onTap: () async {
                      Get.back();
                      try {
                        await launchUrl(Uri.parse(driveWebViewLink.value),
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        Get.snackbar('Error', 'Gagal membuka tautan: $e',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _triggerNativeShare() async {
    String shareText =
        'Dokumen: ${document.title}\nTipe: ${document.type}\nStatus: ${document.status}\n\nRingkasan AI:\n${document.summary}';
    if (googleDriveConnected.value && driveWebViewLink.value.isNotEmpty) {
      shareText += '\n\nTautan Google Drive:\n${driveWebViewLink.value}';
    }

    try {
      await Share.share(
        shareText,
        subject: document.title,
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      _copyDocInfoToClipboard();
      Get.snackbar(
        'Tautan Disalin',
        'Berbagi natif tidak didukung di perangkat ini. Informasi telah disalin otomatis ke papan klip!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  void _copyDocInfoToClipboard() {
    String shareText =
        'Dokumen: ${document.title}\nTipe: ${document.type}\nStatus: ${document.status}\n\nRingkasan AI:\n${document.summary}';
    if (googleDriveConnected.value && driveWebViewLink.value.isNotEmpty) {
      shareText += '\n\nTautan Google Drive:\n${driveWebViewLink.value}';
    }

    Clipboard.setData(ClipboardData(text: shareText));
    Get.snackbar(
      'Salin Berhasil',
      'Informasi dokumen berhasil disalin ke papan klip!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void showAddReminderDialog(BuildContext context) {
    final taskController = TextEditingController(
        text: perihal.value != 'Tidak Terdeteksi'
            ? 'Agenda: ${perihal.value}'
            : 'Agenda: ${document.title}');

    String parsedDate = DateTime.now().toIso8601String().split('T')[0];
    if (document.archivedDate.isNotEmpty) {
      final regex = RegExp(r'\d{4}-\d{2}-\d{2}');
      final match = regex.firstMatch(document.archivedDate);
      if (match != null) {
        parsedDate = match.group(0)!;
      }
    }

    final dateController = TextEditingController(text: parsedDate);
    final timeController = TextEditingController(text: '09:00');
    final locationController = TextEditingController(
        text: organisasiPenerbit.value != 'Tidak Terdeteksi'
            ? organisasiPenerbit.value
            : '');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.aiSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.calendarPlus,
                  color: AppTheme.aiAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Buat Pengingat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simpan agenda surat ini dan sinkronkan langsung ke Google Calendar Anda.',
                style: TextStyle(fontSize: 12, color: AppTheme.outline),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Nama Agenda/Tugas',
                  prefixIcon: const Icon(LucideIcons.type),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  prefixIcon: const Icon(LucideIcons.calendarDays),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(dateController.text) ??
                        DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text =
                        picked.toIso8601String().split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Waktu',
                  prefixIcon: const Icon(LucideIcons.clock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) {
                    final hh = picked.hour.toString().padLeft(2, '0');
                    final mm = picked.minute.toString().padLeft(2, '0');
                    timeController.text = '$hh:$mm';
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  prefixIcon: const Icon(LucideIcons.mapPin),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (taskController.text.trim().isEmpty ||
                  dateController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Nama agenda dan tanggal wajib diisi.',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              Get.back();
              isLoading.value = true;
              try {
                final result = await apiService.createReminder(
                  task: taskController.text.trim(),
                  date: dateController.text.trim(),
                  time: timeController.text.trim(),
                  location: locationController.text.trim(),
                  docId: document.id,
                );
                if (result != null) {
                  final isCalendarSyncOk =
                      result['google_calendar_success'] ?? true;
                  if (isCalendarSyncOk) {
                    Get.snackbar(
                      'Berhasil',
                      'Pengingat berhasil disimpan & disinkronkan ke Google Calendar!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.9),
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Penyimpanan Berhasil dengan Peringatan',
                      'Pengingat disimpan di sistem lokal, tetapi gagal disinkronkan ke Google Calendar Anda. Hubungkan ulang akun Google Anda untuk memperbarui izin.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange.withOpacity(0.9),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                    );
                  }
                } else {
                  Get.snackbar('Gagal', 'Gagal membuat pengingat.',
                      snackPosition: SnackPosition.BOTTOM);
                }
              } catch (e) {
                print("Create reminder UI error: $e");
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan & Sinkron',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> suggestAndShowDispositionDialog(BuildContext context) async {
    if (delegations.isEmpty) {
      Get.snackbar('Disposisi',
          'Belum ada divisi yang dibuat. Buat divisi di halaman Profil terlebih dahulu.',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isAnalyzingDisposition.value = true;

    // Show loading dialog
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI sedang menganalisis tujuan disposisi...',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    Map<String, dynamic>? res;
    try {
      // Get document full detail for full text content
      final detail = await apiService.getDocumentDetail(document.id);
      final contentText = detail?['content'] ?? document.summary;

      final delegationNames =
          delegations.map((d) => d['name'].toString()).toList();
      res = await apiService.suggestDisposition(contentText, delegationNames);
    } catch (e) {
      print("Suggest disposition error: $e");
    } finally {
      isAnalyzingDisposition.value = false;
    }

    Get.back(); // Close loading dialog

    if (res != null) {
      aiSuggestedDelegation.value = res['suggested_delegation'] ?? '';
      aiSuggestedReason.value = res['reason'] ?? '';
    } else {
      aiSuggestedDelegation.value = '';
      aiSuggestedReason.value = '';
    }

    // Open disposition select dialog
    String? selectedDelId;
    if (aiSuggestedDelegation.value.isNotEmpty) {
      final matchedDel = delegations
          .firstWhereOrNull((d) => d['name'] == aiSuggestedDelegation.value);
      if (matchedDel != null) {
        selectedDelId = matchedDel['_id'];
      }
    }

    final selectedDelIdObs = selectedDelId.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
                aiSuggestedDelegation.value.isNotEmpty
                    ? LucideIcons.sparkles
                    : LucideIcons.send,
                color: aiSuggestedDelegation.value.isNotEmpty
                    ? AppTheme.aiAccent
                    : AppTheme.primary),
            const SizedBox(width: 8),
            Text(
                aiSuggestedDelegation.value.isNotEmpty
                    ? 'Rekomendasi Disposisi AI'
                    : 'Disposisi Surat Manual',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aiSuggestedDelegation.value.isNotEmpty) ...[
                const Text(
                    'AI menyarankan surat ini didisposisikan ke divisi berikut:',
                    style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.aiSoft,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.aiAccent.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aiSuggestedDelegation.value.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.aiAccent),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aiSuggestedReason.value,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceVariant,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                    'Rekomendasi AI tidak tersedia. Silakan pilih divisi penerima secara manual untuk mendisposisikan surat ini:',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.4)),
              ],
              const SizedBox(height: 20),
              const Text('Pilih Divisi Penerima Konfirmasi:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface)),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    value: selectedDelIdObs.value,
                    hint: const Text('Pilih Divisi'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: 'general',
                        child: Text('General (Semua Tanpa Divisi)'),
                      ),
                      ...delegations.map((d) {
                        return DropdownMenuItem<String>(
                          value: d['_id'],
                          child: Text(d['name'] ?? ''),
                        );
                      }).toList(),
                    ],
                    onChanged: (val) {
                      selectedDelIdObs.value = val;
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedDelIdObs.value == null) {
                Get.snackbar('Error', 'Silakan pilih divisi penerima.',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              Get.back();
              isLoading.value = true;
              try {
                final success = await apiService.dispositionDocument(
                    document.id, selectedDelIdObs.value!);
                if (success) {
                  Get.snackbar(
                    'Sukses Disposisi',
                    'Surat berhasil didisposisikan ke divisi tujuan!',
                    backgroundColor: Colors.green.withOpacity(0.9),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  await fetchDetailedData(); // Refresh details page
                } else {
                  Get.snackbar('Gagal', 'Gagal memproses disposisi.',
                      snackPosition: SnackPosition.BOTTOM);
                }
              } catch (e) {
                print("Submit disposition error: $e");
                Get.snackbar(
                  'Error',
                  'Terjadi kesalahan saat memproses disposisi: $e',
                  backgroundColor: Colors.red.withOpacity(0.9),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kirim ke Divisi',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
