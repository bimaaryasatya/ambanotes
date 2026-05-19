import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ambanotes/app/data/models/models.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/notification_service.dart';
import '../../archive/controllers/archive_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../theme/app_theme.dart';

class HomeController extends GetxController {
  final apiService = Get.find<ApiService>();

  final agenda = <AgendaItem>[].obs;
  final documents = <Document>[].obs;
  final isLoading = false.obs;
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  // ... (keeping fetchDashboardData intact)
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      // 1. Fetch real reminders
      final remindersList = await apiService.listReminders();
      final List<AgendaItem> parsedAgenda = [];
      
      for (var item in remindersList) {
        final task = item['task'] ?? 'No Task';
        
        // Super smart AI priority computation based on keywords
        String priority = 'NORMAL';
        final lowerTask = task.toLowerCase();
        if (lowerTask.contains('penting') || lowerTask.contains('segera') || lowerTask.contains('rapat') || lowerTask.contains('urgent')) {
          priority = 'HIGH';
        } else if (lowerTask.contains('evaluasi') || lowerTask.contains('kontrak') || lowerTask.contains('review')) {
          priority = 'REVIEW';
        }

        final time = item['time'] != null && item['time'].toString().isNotEmpty 
            ? item['time'] 
            : '09:00 AM';
        
        parsedAgenda.add(AgendaItem(
          id: item['_id'] ?? '',
          title: task,
          startTime: time,
          endTime: item['date'] ?? 'Today',
          location: item['location'] != null && item['location'].toString().isNotEmpty 
              ? item['location'] 
              : 'Secretariat Office',
          priority: priority,
        ));
      }

      if (parsedAgenda.isEmpty) {
        // Fallback placeholder if empty
        agenda.assignAll([
          AgendaItem(
            id: 'placeholder',
            title: 'Welcome to AmbaNotes! Try scanning a letter to extract tasks.',
            startTime: 'Now',
            endTime: 'Today',
            location: 'Secretariat Office',
            priority: 'NORMAL',
          )
        ]);
      } else {
        agenda.assignAll(parsedAgenda);
      }

      // 2. Fetch real documents list
      final docsList = await apiService.listDocuments();
      final List<Document> parsedDocs = [];
      for (var item in docsList) {
        final classification = item['classification'] ?? {};
        parsedDocs.add(Document(
          id: item['doc_id'] ?? '',
          title: item['filename'] ?? 'Untitled Doc',
          summary: item['content'] ?? 'No text extracted.',
          status: item['status'] ?? 'processed',
          type: classification['label_name'] ?? 'Letter',
          archivedDate: item['uploaded_at'] ?? 'Unknown',
          size: '1.2 MB',
        ));
      }
      documents.assignAll(parsedDocs);
    } catch (e) {
      print("Fetch dashboard data error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadDocument(bool fromCamera) async {
    try {
      List<int>? bytes;
      String? filename;

      if (fromCamera) {
        final options = DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.full,
          pageLimit: 1,
          isGalleryImport: true,
        );
        final documentScanner = DocumentScanner(options: options);
        final result = await documentScanner.scanDocument();
        
        if (result.images.isNotEmpty) {
          final imagePath = result.images.first;
          final file = File(imagePath);
          bytes = await file.readAsBytes();
          filename = imagePath.split('/').last;
        } else {
          return; // User canceled scan
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        );
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          bytes = await file.readAsBytes();
          filename = result.files.single.name;
        }
      }

      if (bytes == null || filename == null) return;

      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempDoc = Document(
        id: tempId,
        title: filename,
        summary: 'Dokumen sedang diproses di server oleh pipeline AI...',
        status: 'processing',
        type: 'Processing',
        archivedDate: 'Sedang diproses',
        size: '...',
      );

      // Insert into local documents list
      documents.insert(0, tempDoc);

      // If ArchiveController is active, insert it there too so the user sees it in the document list!
      if (Get.isRegistered<ArchiveController>()) {
        final archiveCtrl = Get.find<ArchiveController>();
        archiveCtrl.documents.insert(0, tempDoc);
      }

      // Show beautiful non-blocking snackbar notifying the user
      Get.snackbar(
        "Mengunggah Dokumen",
        "Dokumen '$filename' sedang diproses di latar belakang. Anda bisa mengecek statusnya di tab Files.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () {
            Get.offAllNamed(Routes.ARCHIVE);
          },
          child: const Text("LIHAT FILES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );

      // Start the background upload job asynchronously (non-blocking!)
      apiService.uploadDocument(bytes, filename).then((result) {
        // Remove the temporary placeholder
        documents.removeWhere((doc) => doc.id == tempId);
        if (Get.isRegistered<ArchiveController>()) {
          Get.find<ArchiveController>().documents.removeWhere((doc) => doc.id == tempId);
        }

        if (result != null) {
          // Trigger a silent refresh so both controllers get fully populated updated states
          fetchDashboardData();
          if (Get.isRegistered<ArchiveController>()) {
            Get.find<ArchiveController>().fetchDocuments();
          }

          if (Get.isRegistered<ProfileController>()) {
            final profile = Get.find<ProfileController>();
            if (profile.enableNotifications.value && profile.notifyProcessing.value) {
              Get.find<NotificationService>().showNotification(
                "Analisis AI Selesai",
                "Dokumen '$filename' berhasil diekstrak dan siap diakses.",
              );
            }
          }

          Get.snackbar(
            "Dokumen Selesai Diproses",
            "Analisis AI selesai untuk '$filename'!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () {
                final classification = result['classification'] ?? {};
                final completedDoc = Document(
                  id: result['doc_id'] ?? 'unknown',
                  title: result['filename'] ?? filename!,
                  summary: result['content'] ?? 'No text extracted.',
                  status: result['status'] ?? 'processed',
                  type: classification['label_name'] ?? 'Letter',
                  archivedDate: result['uploaded_at'] ?? 'Just now',
                  size: '1.2 MB',
                );
                Get.toNamed(Routes.ARCHIVE_DETAIL, arguments: completedDoc);
              },
              child: const Text("BUKA DETAIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          );
        } else {
          Get.snackbar(
            "Upload Gagal",
            "Gagal memproses dokumen '$filename'.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
          );
        }
      }).catchError((err) {
        // Cleanup placeholders on error
        documents.removeWhere((doc) => doc.id == tempId);
        if (Get.isRegistered<ArchiveController>()) {
          Get.find<ArchiveController>().documents.removeWhere((doc) => doc.id == tempId);
        }

        Get.snackbar(
          "Error Ingesti",
          "Terjadi kesalahan saat memproses '$filename': $err",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      });

    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menyiapkan upload: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> confirmDeleteReminder(AgendaItem item) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Agenda', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus agenda "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              isLoading.value = true;
              try {
                final success = await apiService.deleteReminder(item.id);
                if (success) {
                  Get.snackbar(
                    'Berhasil',
                    'Agenda berhasil dihapus.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.9),
                    colorText: Colors.white,
                  );
                  fetchDashboardData(); // Refresh list
                } else {
                  Get.snackbar(
                    'Gagal',
                    'Gagal menghapus agenda.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.9),
                    colorText: Colors.white,
                  );
                }
              } catch (e) {
                print("Delete reminder error: $e");
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
