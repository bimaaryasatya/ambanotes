import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ambanotes/app/data/models/models.dart';
import 'package:ambanotes/app/modules/home/controllers/home_controller.dart';

class ArchiveController extends GetxController {
  final documents = <Document>[].obs;
  
  final searchQuery = ''.obs;
  final selectedCategory = 'All Documents'.obs;
  // Options: 'date_desc', 'date_asc', 'title_asc', 'title_desc'
  final sortOrder = 'date_desc'.obs; 

  @override
  void onInit() {
    super.onInit();
    // In a real app we might fetch from a repository, here we link to HomeController's data
    final homeController = Get.find<HomeController>();
    // Clone the list to allow local modifications without immediately affecting home unless desired
    documents.assignAll(homeController.documents.map((d) => Document(
      id: d.id,
      title: d.title,
      summary: d.summary,
      status: d.status,
      type: d.type,
      archivedDate: d.archivedDate,
      size: d.size,
    )).toList());
  }

  List<Document> get filteredDocuments {
    var result = documents.toList();

    // 1. Filter by Search Query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((doc) {
        return doc.title.toLowerCase().contains(query) || 
               doc.summary.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Filter by Category
    if (selectedCategory.value != 'All Documents') {
      // Map 'Letters', 'Invitations', 'Contracts', 'Reports' to doc.type
      // Assuming doc.type is like 'letter', 'contract', 'report' etc.
      String targetType = '';
      switch (selectedCategory.value) {
        case 'Letters': targetType = 'letter'; break;
        case 'Invitations': targetType = 'invitation'; break;
        case 'Contracts': targetType = 'contract'; break;
        case 'Reports': targetType = 'report'; break;
      }
      if (targetType.isNotEmpty) {
        result = result.where((doc) => doc.type.toLowerCase() == targetType).toList();
      }
    }

    // 3. Sort
    result.sort((a, b) {
      if (sortOrder.value == 'title_asc') {
        return a.title.compareTo(b.title);
      } else if (sortOrder.value == 'title_desc') {
        return b.title.compareTo(a.title);
      } else if (sortOrder.value == 'date_asc') {
        // Dummy date sort based on string
        return a.archivedDate.compareTo(b.archivedDate);
      } else {
        // default 'date_desc'
        return b.archivedDate.compareTo(a.archivedDate);
      }
    });

    return result;
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
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

  void deleteDocument(Document doc) {
    documents.removeWhere((element) => element.id == doc.id);
    Get.snackbar(
      'Document Deleted',
      '${doc.title} has been removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void replaceDocument(Document doc) {
    // Dummy replace logic
    Get.snackbar(
      'Document Replaced',
      '${doc.title} has been replaced successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void editDocument(Document doc) {
    // Dummy edit logic
    Get.snackbar(
      'Edit Mode',
      'Entering edit mode for ${doc.title}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
