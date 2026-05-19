import 'package:get/get.dart';
import 'package:ambanotes/app/data/models/models.dart';
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
      // Provide a fallback document to prevent null errors in UI
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
    // Navigate to Chat and pass the document context
    Get.toNamed('/chat', arguments: {
      'context': 'document',
      'documentTitle': document.title,
      'documentSummary': document.summary,
    });
  }
}
