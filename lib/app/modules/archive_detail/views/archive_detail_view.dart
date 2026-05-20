import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/modules/archive_detail/controllers/archive_detail_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:ambanotes/app/routes/app_pages.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:ambanotes/app/widgets/drive_preview_widget.dart';

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
            onPressed: () => controller.downloadDocument(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () => controller.shareDocument(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching details from AI analysis...', style: TextStyle(color: AppTheme.outline)),
              ],
            ),
          );
        }
        return SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildAISummaryCard(),
                _buildSecuritySuggestionCard(),
                const SizedBox(height: 24),
                if (controller.apiService.isOwner) ...[
                  _buildDispositionCard(context),
                  const SizedBox(height: 24),
                ],
                _buildMetadataSection(),
                () {
                  final showReminder = controller.document.type.toLowerCase().contains('undangan') || 
                                       controller.document.type.toLowerCase().contains('invitation') ||
                                       controller.document.summary.toLowerCase().contains('rapat') || 
                                       controller.document.summary.toLowerCase().contains('tanggal') || 
                                       controller.document.summary.toLowerCase().contains('waktu');
                  if (!showReminder) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showAddReminderDialog(context),
                        icon: const Icon(LucideIcons.calendarPlus, color: Colors.white),
                        label: const Text(
                          'Tambahkan Pengingat ke Google Calendar',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.aiAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  );
                }(),
                const SizedBox(height: 24),
                _buildDocumentPreview(context),
                if (controller.document.type.toLowerCase().contains('invitation') || 
                    controller.document.type.toLowerCase().contains('undangan')) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.ASSIGNMENT_LETTER_FORM, arguments: {
                        'doc_id': controller.document.id,
                        'nomor_surat': controller.nomorSurat.value,
                        'perihal': controller.perihal.value,
                        'organisasi': controller.organisasiPenerbit.value,
                      }),
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
      }),
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
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.calendar, size: 16, color: AppTheme.outline),
                  const SizedBox(width: 8),
                  Text(doc.archivedDate, style: const TextStyle(color: AppTheme.outline)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.hardDrive, size: 16, color: AppTheme.outline),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      doc.size,
                      style: const TextStyle(color: AppTheme.outline),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isApproved = status == 'Approved' || status.toLowerCase() == 'processed';
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
            isApproved ? 'Processed' : status,
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
        gradient: const LinearGradient(
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
          const Row(
            children: [
              Icon(LucideIcons.sparkles, color: AppTheme.aiAccent),
              SizedBox(width: 8),
              Text('AI Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.aiAccent)),
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

  Widget _buildSecuritySuggestionCard() {
    return Obx(() {
      if (controller.securitySuggestion.value.isEmpty) return const SizedBox.shrink();
      final isConnected = controller.googleDriveConnected.value;

      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isConnected ? Colors.green.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isConnected ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
                  color: isConnected ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isConnected ? 'Secured in Google Drive' : 'Cybersecurity Alert',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isConnected ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              controller.securitySuggestion.value,
              style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.5),
            ),
            if (!isConnected) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(Routes.PROFILE),
                  icon: const Icon(LucideIcons.hardDrive, size: 16),
                  label: const Text('Integrate Google Drive Cloud'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildMetadataSection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Extracted NER Entities & Metadata', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
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
              _buildMetadataRow('Nomor Surat', controller.nomorSurat.value),
              const Divider(height: 24),
              _buildMetadataRow('Perihal', controller.perihal.value),
              const Divider(height: 24),
              _buildMetadataRow('Pengirim/Organisasi', controller.organisasiPenerbit.value),
              const Divider(height: 24),
              _buildMetadataRow('Uploaded By', controller.uploadedBy.value),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildMetadataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.outline, fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value, 
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        const SizedBox(height: 12),
        Obx(() {
          final isDrive = controller.googleDriveConnected.value;
          final b64 = controller.base64Image.value;
          final viewLink = controller.driveWebViewLink.value;
          final mime = controller.mimetype.value;

          Widget previewContent;

          if (isDrive && viewLink.isNotEmpty) {
            final downloadLink = controller.driveContentLink.value;
            final isImage = mime.toLowerCase().contains('image') || 
                            controller.document.title.toLowerCase().endsWith('.png') ||
                            controller.document.title.toLowerCase().endsWith('.jpg') ||
                            controller.document.title.toLowerCase().endsWith('.jpeg') ||
                            controller.document.title.toLowerCase().endsWith('.webp');

            if (isImage && downloadLink.isNotEmpty) {
              previewContent = GestureDetector(
                onTap: () => _showFullScreenImage(context, Image.network(downloadLink, fit: BoxFit.contain)),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: 'Ketuk untuk memperbesar gambar',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        downloadLink,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: AppTheme.primary),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDriveOpenButton(viewLink);
                        },
                      ),
                    ),
                  ),
                ),
              );
            } else {
              previewContent = DrivePreviewWidget(
                viewLink: viewLink,
                title: controller.document.title,
              );
            }
          } else if (b64.isNotEmpty) {
            final isImage = mime.toLowerCase().contains('image') || 
                            controller.document.title.toLowerCase().endsWith('.png') ||
                            controller.document.title.toLowerCase().endsWith('.jpg') ||
                            controller.document.title.toLowerCase().endsWith('.jpeg') ||
                            controller.document.title.toLowerCase().endsWith('.webp');
            if (isImage) {
              try {
                final bytes = base64Decode(b64);
                previewContent = GestureDetector(
                  onTap: () => _showFullScreenImage(context, Image.memory(bytes, fit: BoxFit.contain)),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Tooltip(
                      message: 'Ketuk untuk memperbesar gambar',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              } catch (e) {
                previewContent = const Center(
                  child: Text('Gagal mendekode gambar biner.', style: TextStyle(color: Colors.red)),
                );
              }
            } else {
              previewContent = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.fileText, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      controller.document.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text('Berkas non-gambar disimpan lokal di database.', style: TextStyle(color: AppTheme.outline, fontSize: 12)),
                  ],
                ),
              );
            }
          } else {
            previewContent = const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.fileText, size: 48, color: AppTheme.outline),
                  SizedBox(height: 16),
                  Text('Pratinjau berkas tidak tersedia.', style: TextStyle(color: AppTheme.outline)),
                ],
              ),
            );
          }

          return Container(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: previewContent,
          );
        }),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Pratinjau Lengkap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: imageWidget,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriveOpenButton(String url) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.cloud, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Berkas Disimpan Aman di Google Drive',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Buka pratinjau asli di Drive pribadi Anda.',
            style: TextStyle(color: AppTheme.outline, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Get.snackbar(
                'Google Drive Link',
                'Tautan berkas berhasil disalin ke papan klip!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.withOpacity(0.9),
                colorText: Colors.white,
              );
            },
            icon: const Icon(LucideIcons.copy, size: 16, color: Colors.white),
            label: const Text('Salin Tautan Drive', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDispositionCard(BuildContext context) {
    return Obx(() {
      final isDispatched = controller.delegationId.value != null;
      final delName = controller.delegationName.value ?? 'Belum Ditentukan';
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDispatched ? Colors.green.withOpacity(0.3) : Colors.amber.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDispatched ? LucideIcons.send : LucideIcons.alertTriangle,
                  color: isDispatched ? Colors.green : Colors.amber,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Disposisi Surat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Tentukan divisi penerima dokumen ini agar dapat diakses oleh staff pada divisi tersebut.",
              style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDispatched ? Colors.green.withOpacity(0.05) : Colors.amber.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    isDispatched ? LucideIcons.users : LucideIcons.eyeOff,
                    size: 16,
                    color: isDispatched ? Colors.green : Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDispatched
                          ? "Didisposisikan ke: $delName"
                          : "Status: Draf (Hanya Owner yang dapat melihat)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDispatched ? Colors.green : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.suggestAndShowDispositionDialog(context),
                icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                label: Text(
                  isDispatched ? "Ubah Disposisi" : "Kirim / Disposisi Surat",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
