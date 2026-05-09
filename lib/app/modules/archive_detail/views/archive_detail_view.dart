import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/modules/archive_detail/controllers/archive_detail_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:ambanotes/app/routes/app_pages.dart';

class ArchiveDetailView extends GetView<ArchiveDetailController> {
  const ArchiveDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Document Details'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () {
              Get.snackbar('Download', 'Downloading document...', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {
              Get.snackbar('Share', 'Sharing document...', snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildAISummaryCard(),
            const SizedBox(height: 24),
            _buildMetadataSection(),
            const SizedBox(height: 24),
            _buildDocumentPreview(),
            if (controller.document.type.toLowerCase() == 'invitation') ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.ASSIGNMENT_LETTER_FORM, arguments: controller.document),
                  icon: const Icon(LucideIcons.penTool, color: Colors.white),
                  label: const Text(
                    'Buat Surat Tugas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final doc = controller.document;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  doc.type.toUpperCase(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(doc.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            doc.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 16, color: AppTheme.outline),
              const SizedBox(width: 8),
              Text(doc.archivedDate, style: const TextStyle(color: AppTheme.outline)),
              const SizedBox(width: 16),
              const Icon(LucideIcons.hardDrive, size: 16, color: AppTheme.outline),
              const SizedBox(width: 8),
              Text(doc.size, style: const TextStyle(color: AppTheme.outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isApproved = status == 'Approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green.withOpacity(0.1) : AppTheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isApproved) ...[
            const Icon(LucideIcons.checkCircle, size: 12, color: Colors.green),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isApproved ? Colors.green : AppTheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.aiSoft, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.aiAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: AppTheme.aiAccent),
              const SizedBox(width: 8),
              const Text('AI Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.aiAccent)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.document.summary,
            style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: controller.askAIForMore,
              icon: const Icon(LucideIcons.messageCircle, size: 16),
              label: const Text('Ask AI for More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Metadata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildMetadataRow('Uploaded By', 'Admin User'),
              const Divider(height: 24),
              _buildMetadataRow('Entity', 'Secretariat Division'),
              const Divider(height: 24),
              _buildMetadataRow('Tags', 'Report, Q3, Finance'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.outline, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildDocumentPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        const SizedBox(height: 12),
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.fileText, size: 48, color: AppTheme.outline),
                SizedBox(height: 16),
                Text('Document Preview Unavailable', style: TextStyle(color: AppTheme.outline)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
