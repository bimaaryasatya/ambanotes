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
        organisasiPenerbit.value = entities['organisasi_penerbit'] ?? 'Tidak Terdeteksi';
        
        securitySuggestion.value = detail['security_suggestion'] ?? '';
        uploadedBy.value = detail['uploaded_by']?.toString() ?? 'Admin User';
        
        mimetype.value = detail['mimetype'] ?? 'image/jpeg';
        
        final gd = detail['google_drive'];
        if (gd != null) {
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
      'documentTitle': document.title,
      'documentSummary': document.summary,
    });
  }

  Future<void> downloadDocument() async {
    if (googleDriveConnected.value && driveWebViewLink.value.isNotEmpty) {
      final url = driveContentLink.value.isNotEmpty ? driveContentLink.value : driveWebViewLink.value;
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
        Get.snackbar('Error', 'Gagal membuka browser: $e', snackPosition: SnackPosition.BOTTOM);
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
            child: const Text('Buka', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      } catch (e) {
        Get.snackbar('Error', 'Gagal mengunduh dokumen: $e', snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Info', 'Sumber dokumen tidak tersedia.', snackPosition: SnackPosition.BOTTOM);
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
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
                    child: const Icon(LucideIcons.share2, color: AppTheme.primary),
                  ),
                  title: const Text('Bagikan via Aplikasi Sistem', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Kirim berkas/tautan via WhatsApp, Gmail, dll.'),
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
                  title: const Text('Salin Informasi Dokumen', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Salin ringkasan dan tautan dokumen ke papan klip.'),
                  onTap: () {
                    Get.back();
                    _copyDocInfoToClipboard();
                  },
                ),
                if (googleDriveConnected.value && driveWebViewLink.value.isNotEmpty) ...[
                  const Divider(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.externalLink, color: Colors.green),
                    ),
                    title: const Text('Buka Tautan Google Drive', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Buka pratinjau berkas di Google Drive Anda.'),
                    onTap: () async {
                      Get.back();
                      try {
                        await launchUrl(Uri.parse(driveWebViewLink.value), mode: LaunchMode.externalApplication);
                      } catch (e) {
                        Get.snackbar('Error', 'Gagal membuka tautan: $e', snackPosition: SnackPosition.BOTTOM);
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
    String shareText = 'Dokumen: ${document.title}\nTipe: ${document.type}\nStatus: ${document.status}\n\nRingkasan AI:\n${document.summary}';
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
    String shareText = 'Dokumen: ${document.title}\nTipe: ${document.type}\nStatus: ${document.status}\n\nRingkasan AI:\n${document.summary}';
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
      text: perihal.value != 'Tidak Terdeteksi' ? 'Agenda: ${perihal.value}' : 'Agenda: ${document.title}'
    );
    
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
      text: organisasiPenerbit.value != 'Tidak Terdeteksi' ? organisasiPenerbit.value : ''
    );

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
              child: const Icon(LucideIcons.calendarPlus, color: AppTheme.aiAccent, size: 20),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  prefixIcon: const Icon(LucideIcons.calendarDays),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(dateController.text) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text = picked.toIso8601String().split('T')[0];
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              if (taskController.text.trim().isEmpty || dateController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Nama agenda dan tanggal wajib diisi.', snackPosition: SnackPosition.BOTTOM);
                return;
              }
              Get.back();
              isLoading.value = true;
              try {
                final success = await apiService.createReminder(
                  task: taskController.text.trim(),
                  date: dateController.text.trim(),
                  time: timeController.text.trim(),
                  location: locationController.text.trim(),
                  docId: document.id,
                );
                if (success) {
                  Get.snackbar(
                    'Berhasil', 
                    'Pengingat berhasil disimpan & disinkronkan ke Google Calendar!', 
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.9),
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar('Gagal', 'Gagal membuat pengingat.', snackPosition: SnackPosition.BOTTOM);
                }
              } catch (e) {
                print("Create reminder UI error: $e");
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan & Sinkron', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
