import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/modules/assignment_form/controllers/assignment_form_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';

class AssignmentFormView extends GetView<AssignmentFormController> {
  const AssignmentFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isOwner = controller.apiService.isOwner;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Buat Surat Tugas'),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReferenceCard(),
                const SizedBox(height: 24),

                // ── Missing assets warning banner ──────────────────────────
                Obx(() {
                  if (!controller.isAssetsMissing.value) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.45)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(LucideIcons.alertTriangle,
                              color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Kop Surat / TTD Belum Tersedia',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Owner belum menambahkan atau mengaktifkan Kop Surat dan Tanda Tangan Digital. '
                                'Hubungi owner untuk mengatur aset organisasi terlebih dahulu.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Text('Detail Surat',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface)),
                const SizedBox(height: 16),

                // ── Kop & TTD only shown to Owner ─────────────────────────
                if (isOwner) ...[
                  _buildDropdown(
                    label: 'Kop Surat',
                    icon: LucideIcons.building,
                    value: controller.selectedKopSurat,
                    options: controller.kopSuratOptions,
                    onChanged: (val) {
                      if (val != null) controller.selectedKopSurat.value = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Tanda Tangan (TTD)',
                    icon: LucideIcons.penTool,
                    value: controller.selectedTtd,
                    options: controller.ttdOptions,
                    onChanged: (val) {
                      if (val != null) controller.selectedTtd.value = val;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                _buildTextField(
                  label: 'Nomor Surat',
                  controller: controller.letterNumberController,
                  icon: LucideIcons.hash,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Nomor surat wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildDateTimeField(
                  label: 'Tanggal Penugasan',
                  displayValue: () => controller.formattedDate,
                  icon: LucideIcons.calendar,
                  onTap: () => controller.pickDate(context),
                ),
                const SizedBox(height: 16),
                _buildDateTimeField(
                  label: 'Waktu Penugasan',
                  displayValue: () => controller.formattedTime,
                  icon: LucideIcons.clock,
                  onTap: () => controller.pickTime(context),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Tempat / Lokasi',
                  controller: controller.locationController,
                  icon: LucideIcons.mapPin,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Tempat wajib diisi' : null,
                ),
                const SizedBox(height: 40),

                // ── Submit button ──────────────────────────────────────────
                Obx(() {
                  final disabled =
                      controller.isLoading.value || controller.isAssetsMissing.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: disabled ? null : controller.submitForm,
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(
                              controller.isAssetsMissing.value
                                  ? LucideIcons.alertCircle
                                  : LucideIcons.checkCircle,
                              color: Colors.white,
                            ),
                      label: Text(
                        controller.isLoading.value
                            ? 'Memproses...'
                            : controller.isAssetsMissing.value
                                ? 'Kop / TTD Belum Aktif'
                                : 'Konfirmasi Surat Jalan',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: disabled
                            ? Colors.grey.shade400
                            : AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: disabled ? 0 : 2,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileText, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Referensi Undangan',
                    style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                Obx(() => Text(
                      controller.sourceDocumentTitle.value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: AppTheme.primary),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required RxString value,
    required RxList<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() => DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppTheme.outline),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.outlineVariant)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.outlineVariant)),
          ),
          value: value.value.isNotEmpty && options.contains(value.value)
              ? value.value
              : (options.isNotEmpty ? options.first : null),
          items: options.map((opt) {
            return DropdownMenuItem(value: opt, child: Text(opt));
          }).toList(),
          onChanged: onChanged,
        ));
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.outline),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.outlineVariant)),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String Function() displayValue,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.outline),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.outline)),
                Obx(() => Text(
                      displayValue(),
                      style: const TextStyle(
                          fontSize: 16, color: AppTheme.onSurface),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
