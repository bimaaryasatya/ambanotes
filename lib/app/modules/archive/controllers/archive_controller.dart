import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ambanotes/app/data/models/models.dart';
import '../../../data/services/api_service.dart';

class ArchiveController extends GetxController {
  final apiService = Get.find<ApiService>();

  final documents = <Document>[].obs;
  final isLoading = false.obs;

  final searchQuery = ''.obs;
  final selectedCategory = 'All Documents'.obs;
  final sortOrder = 'date_desc'.obs;
  final isSemanticSearchEnabled = false.obs;
  final selectedDocIds = <String>{}.obs;
  final isSelectionMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    isLoading.value = true;
    try {
      final docList = await apiService.listDocuments();
      final List<Document> parsed = [];
      for (var item in docList) {
        final classification = item['classification'] ?? {};
        parsed.add(Document(
          id: item['doc_id'] ?? '',
          title: item['filename'] ?? 'Untitled Doc',
          summary: item['content'] ?? 'No text extracted.',
          status: item['status'] ?? 'processed',
          type: classification['label_name'] ?? 'Letter',
          archivedDate: item['uploaded_at'] ?? 'Unknown',
          size: '1.2 MB',
        ));
      }

      // Inject dummy invitation document for testing Surat Tugas feature
      parsed.insert(
          0,
          Document(
            id: 'dummy_invitation_001',
            title: 'Undangan Rapat Koordinasi Wilayah',
            summary:
                'Kami mengundang Bapak/Ibu untuk menghadiri rapat koordinasi wilayah pada hari Senin, 20 Oktober 2026 pukul 09:00 WIB bertempat di Ruang Rapat Utama Balai Kota Jakarta.',
            status: 'processed',
            type: 'Undangan',
            archivedDate: DateTime.now().toIso8601String(),
            size: '450 KB',
          ));

      documents.assignAll(parsed);
    } catch (e) {
      print("Fetch documents error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Document> get filteredDocuments {
    var result = documents.toList();

    // 1. Filter by Category
    if (selectedCategory.value != 'All Documents') {
      String targetType = '';
      switch (selectedCategory.value) {
        case 'Letters':
          targetType = 'surat_masuk';
          break;
        case 'Invitations':
          targetType = 'undangan';
          break;
        case 'Contracts':
          targetType = 'kontrak';
          break;
        case 'Reports':
          targetType = 'laporan';
          break;
      }
      if (targetType.isNotEmpty) {
        result = result
            .where((doc) =>
                doc.type.toLowerCase() == targetType ||
                doc.type.toLowerCase().contains(selectedCategory.value
                    .substring(0, selectedCategory.value.length - 1)
                    .toLowerCase()))
            .toList();
      }
    }

    // 2. Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((doc) {
        return doc.title.toLowerCase().contains(query) ||
            doc.summary.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Sort
    result.sort((a, b) {
      if (sortOrder.value == 'title_asc') {
        return a.title.compareTo(b.title);
      } else if (sortOrder.value == 'title_desc') {
        return b.title.compareTo(a.title);
      } else if (sortOrder.value == 'date_asc') {
        return a.archivedDate.compareTo(b.archivedDate);
      } else {
        return b.archivedDate.compareTo(a.archivedDate);
      }
    });

    return result;
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  Future<void> performSemanticSearch() async {
    if (searchQuery.value.isEmpty) {
      fetchDocuments();
      return;
    }

    isLoading.value = true;
    try {
      final results = await apiService.semanticSearch(searchQuery.value);
      final List<Document> matchedDocs = [];

      // Match semantic search results (which return doc_id and filename) with our local detailed documents
      for (var item in results) {
        final docId = item['doc_id'];
        final match = documents.firstWhereOrNull((d) => d.id == docId);
        if (match != null) {
          matchedDocs.add(match);
        }
      }

      if (matchedDocs.isNotEmpty) {
        documents.assignAll(matchedDocs);
        Get.snackbar(
          'Semantic Search',
          'Found ${matchedDocs.length} conceptually relevant documents!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.deepPurple.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Semantic Search',
          'No conceptually matching documents found.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Semantic search error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleSort() {
    if (sortOrder.value == 'date_desc') {
      sortOrder.value = 'title_asc';
    } else {
      sortOrder.value = 'date_desc';
    }
  }

  // --- ACTIONS ---

  void deleteDocument(Document doc) async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Are you sure you want to delete ${doc.title}?'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));

    if (confirmed == true) {
      isLoading.value = true;
      final success = await apiService.deleteDocument(doc.id);
      isLoading.value = false;

      if (success) {
        documents.removeWhere((element) => element.id == doc.id);
        Get.snackbar(
          'Document Deleted',
          '${doc.title} has been removed successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Deletion Failed',
          'Could not delete document. Ensure you are an organization Owner.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  void enterSelectionMode(String id) {
    isSelectionMode.value = true;
    selectedDocIds.add(id);
  }

  void toggleSelection(String id) {
    if (selectedDocIds.contains(id)) {
      selectedDocIds.remove(id);
    } else {
      selectedDocIds.add(id);
    }

    if (selectedDocIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void clearSelection() {
    selectedDocIds.clear();
    isSelectionMode.value = false;
  }

  Future<void> deleteSelectedDocuments() async {
    final ids = selectedDocIds.toList();

    if (ids.isEmpty) {
      clearSelection();
      return;
    }

    isLoading.value = true;

    try {
      for (final id in ids) {
        await apiService.deleteDocument(id);
      }

      clearSelection();
      await fetchDocuments();

      Get.snackbar(
        'Berhasil',
        'Dokumen terpilih berhasil dihapus.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menghapus dokumen terpilih: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void replaceDocument(Document doc) {
    Get.toNamed(Routes.REPLACE, arguments: doc);
  }

  void editDocument(Document doc) {
    Get.snackbar(
      'Edit Mode',
      'Feature details editing is handled inside document details screen.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
