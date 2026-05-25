import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ambanotes/app/data/models/models.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';
import '../../../data/services/backup_registry_service.dart';
import '../../../data/services/api_service.dart';
import '../../../utils/document_backup_helper.dart';

class ArchiveController extends GetxController {
  final apiService = Get.find<ApiService>();
  final backupRegistry = Get.find<BackupRegistryService>();

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
          delegationId: item['delegation_id'] ?? 'general',
          delegationName: item['delegation_name'] ?? 'General',
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
            delegationId: 'general',
            delegationName: 'General',
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
        return _parseArchivedDate(a.archivedDate)
            .compareTo(_parseArchivedDate(b.archivedDate));
      } else if (sortOrder.value == 'delegation_asc') {
        final delegationCompare = a.delegationName
            .toLowerCase()
            .compareTo(b.delegationName.toLowerCase());
        return delegationCompare != 0
            ? delegationCompare
            : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      } else {
        return _parseArchivedDate(b.archivedDate)
            .compareTo(_parseArchivedDate(a.archivedDate));
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

  void setSortOrder(String value) {
    sortOrder.value = value;
  }

  String get sortLabel {
    switch (sortOrder.value) {
      case 'date_asc':
        return 'Terlama';
      case 'title_asc':
        return 'Nama A-Z';
      case 'title_desc':
        return 'Nama Z-A';
      case 'delegation_asc':
        return 'Divisi A-Z';
      default:
        return 'Terbaru';
    }
  }

  void showSortOptions() {
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            28 + MediaQuery.of(Get.context!).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urutkan Dokumen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...[
                {'value': 'date_desc', 'label': 'Tanggal Terbaru'},
                {'value': 'date_asc', 'label': 'Tanggal Terlama'},
                {'value': 'delegation_asc', 'label': 'Divisi A-Z'},
                {'value': 'title_asc', 'label': 'Nama A-Z'},
                {'value': 'title_desc', 'label': 'Nama Z-A'},
              ].map((option) {
                final value = option['value']!;
                final label = option['label']!;
                return Obx(() {
                  final selected = sortOrder.value == value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      selected ? LucideIcons.checkCircle : LucideIcons.circle,
                      color: selected ? Colors.teal : Colors.grey,
                    ),
                    title: Text(label),
                    onTap: () {
                      setSortOrder(value);
                      Get.back();
                    },
                  );
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- ACTIONS ---

  void deleteDocument(Document doc) async {
    final deleteBackup = await _confirmDeleteDocument(doc);

    if (deleteBackup != null) {
      isLoading.value = true;
      final success = await apiService.deleteDocument(doc.id);
      isLoading.value = false;

      if (success) {
        int deletedBackupCount = 0;
        if (deleteBackup) {
          deletedBackupCount = await _deleteRegisteredBackups(doc.id);
        }

        documents.removeWhere((element) => element.id == doc.id);
        Get.snackbar(
          'Document Deleted',
          deletedBackupCount > 0
              ? '${doc.title} dihapus bersama $deletedBackupCount file cadangan.'
              : '${doc.title} has been removed successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Deletion Failed',
          'Dokumen tidak dapat dihapus. Periksa koneksi server/Google Drive atau coba login ulang sebagai owner.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  void enterSelectionMode(String id) {
    selectedDocIds.add(id);
    selectedDocIds.refresh();
    isSelectionMode.value = true;
  }

  void toggleSelection(String id) {
    final updatedIds = selectedDocIds.toSet();

    if (selectedDocIds.contains(id)) {
      updatedIds.remove(id);
    } else {
      updatedIds.add(id);
    }

    selectedDocIds
      ..clear()
      ..addAll(updatedIds);
    selectedDocIds.refresh();

    if (selectedDocIds.isEmpty) {
      isSelectionMode.value = false;
    }
  }

  void clearSelection() {
    selectedDocIds.clear();
    selectedDocIds.refresh();
    isSelectionMode.value = false;
  }

  void selectAllVisibleDocuments() {
    final visibleIds = filteredDocuments
        .where((doc) => doc.status != 'processing')
        .map((doc) => doc.id)
        .toSet();

    if (visibleIds.isEmpty) return;

    isSelectionMode.value = true;

    if (selectedDocIds.length == visibleIds.length &&
        selectedDocIds.containsAll(visibleIds)) {
      selectedDocIds.clear();
      isSelectionMode.value = false;
    } else {
      selectedDocIds.assignAll(visibleIds);
    }
    selectedDocIds.refresh();
  }

  Future<void> deleteSelectedDocuments() async {
    final ids = selectedDocIds.toList();

    if (ids.isEmpty) {
      clearSelection();
      return;
    }

    final selectedDocs =
        documents.where((doc) => ids.contains(doc.id)).toList();
    final deleteBackup = await _confirmDeleteDocuments(selectedDocs);

    if (deleteBackup == null) return;

    isLoading.value = true;
    int deletedBackupCount = 0;

    try {
      for (final id in ids) {
        final deleted = await apiService.deleteDocument(id);
        if (deleted && deleteBackup) {
          deletedBackupCount += await _deleteRegisteredBackups(id);
        }
      }

      clearSelection();
      await fetchDocuments();

      Get.snackbar(
        'Berhasil',
        deletedBackupCount > 0
            ? 'Dokumen terpilih dan $deletedBackupCount file cadangan berhasil dihapus.'
            : 'Dokumen terpilih berhasil dihapus.',
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
    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            28 + MediaQuery.of(Get.context!).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ganti Dokumen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih sumber file pengganti untuk ${doc.title}.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7F6F4),
                  child: Icon(LucideIcons.scan, color: Colors.teal),
                ),
                title: const Text('Foto Scan'),
                subtitle:
                    const Text('Gunakan kamera scanner untuk memindai ulang surat'),
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    Routes.REPLACE,
                    arguments: {'document': doc, 'initialSource': 'scan'},
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF3FF),
                  child: Icon(LucideIcons.upload, color: Colors.blue),
                ),
                title: const Text('Upload File'),
                subtitle: const Text('Pilih file gambar atau PDF dari perangkat'),
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    Routes.REPLACE,
                    arguments: {'document': doc, 'initialSource': 'upload'},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> backupDocument(Document doc) async {
    try {
      final bytes = await apiService.downloadDocumentBytes(doc.id);
      if (bytes == null || bytes.isEmpty) {
        Get.snackbar(
          'Backup Gagal',
          'Dokumen ${doc.title} tidak dapat diunduh.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final pathOrMessage = await saveDocumentToLocal(bytes, doc.title);
      if (canDeleteDocumentBackupFile(pathOrMessage)) {
        await backupRegistry.registerBackupPath(doc.id, pathOrMessage);
      }
      Get.snackbar(
        'Backup Berhasil',
        pathOrMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Backup Gagal',
        'Terjadi kesalahan saat mencadangkan ${doc.title}: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> backupSelectedDocuments() async {
    final selectedDocs = filteredDocuments
        .where((doc) => selectedDocIds.contains(doc.id))
        .toList();

    if (selectedDocs.isEmpty) {
      clearSelection();
      return;
    }

    isLoading.value = true;
    int successCount = 0;

    try {
      for (final doc in selectedDocs) {
        final bytes = await apiService.downloadDocumentBytes(doc.id);
        if (bytes == null || bytes.isEmpty) {
          continue;
        }

        final pathOrMessage = await saveDocumentToLocal(bytes, doc.title);
        if (canDeleteDocumentBackupFile(pathOrMessage)) {
          await backupRegistry.registerBackupPath(doc.id, pathOrMessage);
        }
        successCount++;
      }

      Get.snackbar(
        'Cadangan Selesai',
        '$successCount dari ${selectedDocs.length} dokumen berhasil dicadangkan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      clearSelection();
    } catch (e) {
      Get.snackbar(
        'Cadangan Gagal',
        'Terjadi kesalahan saat batch backup: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  DateTime _parseArchivedDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<bool?> _confirmDeleteDocument(Document doc) async {
    final backupCount = backupRegistry.getBackupPaths(doc.id).length;
    var keepBackup = false;

    return Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Hapus Dokumen?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dokumen "${doc.title}" akan dihapus dari aplikasi.',
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 14),
              _buildKeepBackupCheckbox(
                value: keepBackup,
                backupCount: backupCount,
                onChanged: (value) {
                  setState(() => keepBackup = value);
                },
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: null),
              child: const Text('Batal', style: TextStyle(fontSize: 13)),
            ),
            TextButton(
              onPressed: () => Get.back(result: !keepBackup),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteDocuments(List<Document> docs) async {
    final backupCount = docs.fold<int>(
      0,
      (total, doc) => total + backupRegistry.getBackupPaths(doc.id).length,
    );
    var keepBackup = false;

    return Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Hapus Dokumen Terpilih?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sebanyak ${docs.length} dokumen akan dihapus permanen.',
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 14),
              _buildKeepBackupCheckbox(
                value: keepBackup,
                backupCount: backupCount,
                onChanged: (value) {
                  setState(() => keepBackup = value);
                },
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: null),
              child: const Text('Batal', style: TextStyle(fontSize: 13)),
            ),
            TextButton(
              onPressed: () => Get.back(result: !keepBackup),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeepBackupCheckbox({
    required bool value,
    required int backupCount,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: value,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (checked) => onChanged(checked ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jangan hapus file cadangan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    backupCount > 0
                        ? '$backupCount file cadangan terdeteksi.'
                        : 'Belum ada file cadangan tercatat.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _deleteRegisteredBackups(String docId) async {
    final paths = backupRegistry.getBackupPaths(docId);
    int deletedCount = 0;

    for (final path in paths) {
      final deleted = await deleteDocumentBackupFile(path);
      if (deleted) {
        deletedCount++;
      }
      await backupRegistry.removeBackupPath(docId, path);
    }

    return deletedCount;
  }
}
