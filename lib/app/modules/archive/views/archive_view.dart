import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/modules/archive/controllers/archive_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:ambanotes/app/data/models/models.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';

class ArchiveView extends GetView<ArchiveController> {
  const ArchiveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        title: const Text("Document Archive"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSearchBar(),
          ),
          _buildCategoryFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildDocumentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, color: AppTheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: const InputDecoration(
                hintText: "Search documents, entities...",
                hintStyle: TextStyle(fontSize: 14, color: AppTheme.outline),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: controller.toggleSort,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.sliders, size: 18, color: AppTheme.secondary),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All Documents', 'Letters', 'Invitations', 'Contracts', 'Reports'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedCategory.value == categories[index];
            return GestureDetector(
              onTap: () => controller.selectCategory(categories[index]),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.outline,
                    ),
                  ),
                  backgroundColor: isSelected ? AppTheme.primary : Colors.white,
                  side: isSelected ? BorderSide.none : const BorderSide(color: AppTheme.outlineVariant),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildDocumentList() {
    return Obx(() {
      final filteredDocs = controller.filteredDocuments;
      if (filteredDocs.isEmpty) {
        return const Center(
          child: Text('No documents found.', style: TextStyle(color: AppTheme.outline)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: filteredDocs.length,
        itemBuilder: (context, index) {
          final doc = filteredDocs[index];
          return _buildDocumentItem(doc);
        },
      );
    });
  }

  Widget _buildDocumentItem(Document doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.ARCHIVE_DETAIL, arguments: doc),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.fileText, color: AppTheme.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doc.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doc.type.toUpperCase(),
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.outline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.aiSoft.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.aiAccent.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.sparkles, size: 12, color: AppTheme.aiAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          doc.summary,
                          style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildStatusBadge(doc.status),
                        const SizedBox(width: 12),
                        Text(
                          doc.archivedDate,
                          style: const TextStyle(fontSize: 10, color: AppTheme.outline, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppTheme.outline),
                      onSelected: (value) {
                        if (value == 'delete') {
                          controller.deleteDocument(doc);
                        } else if (value == 'edit') {
                          controller.editDocument(doc);
                        } else if (value == 'replace') {
                          controller.replaceDocument(doc);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'replace',
                          child: Text('Replace'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isApproved = status == 'Approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green.withOpacity(0.1) : AppTheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (isApproved) ...[
            const Icon(LucideIcons.checkCircle, size: 10, color: Colors.green),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isApproved ? Colors.green : AppTheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }


}
