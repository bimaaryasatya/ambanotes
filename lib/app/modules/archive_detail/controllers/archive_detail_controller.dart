import 'package:get/get.dart';
import 'package:ambanotes/app/data/models/models.dart';

class ArchiveDetailController extends GetxController {
  late Document document;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Document) {
      document = args;
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

  void askAIForMore() {
    // Navigate to Chat and pass the document context
    Get.toNamed('/chat', arguments: {
      'context': 'document',
      'documentTitle': document.title,
      'documentSummary': document.summary,
    });
  }
}
