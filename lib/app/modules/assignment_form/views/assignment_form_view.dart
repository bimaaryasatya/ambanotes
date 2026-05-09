import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/modules/assignment_form/controllers/assignment_form_controller.dart';
import 'package:ambanotes/app/theme/app_theme.dart';

class AssignmentFormView extends GetView<AssignmentFormController> {
  const AssignmentFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Buat Surat Tugas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReferenceCard(),
              const SizedBox(height: 24),
              const Text('Detail Surat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nomor Surat',
                controller: controller.letterNumberController,
                icon: LucideIcons.hash,
                validator: (val) => val == null || val.isEmpty ? 'Nomor surat wajib diisi' : null,
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
                validator: (val) => val == null || val.isEmpty ? 'Tempat wajib diisi' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: controller.submitForm,
                  icon: const Icon(LucideIcons.checkCircle, color: Colors.white),
                  label: const Text(
                    'Konfirmasi Surat Jalan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
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
                const Text('Referensi Undangan', style: TextStyle(fontSize: 12, color: AppTheme.outline)),
                Text(
                  controller.sourceDocument.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Kop Surat',
        prefixIcon: const Icon(LucideIcons.building, color: AppTheme.outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.outlineVariant)),
      ),
      value: controller.selectedKopSurat.value,
      items: controller.kopSuratOptions.map((kop) {
        return DropdownMenuItem(value: kop, child: Text(kop));
      }).toList(),
      onChanged: (val) {
        if (val != null) controller.selectedKopSurat.value = val;
      },
    );
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.outlineVariant)),
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
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.outline)),
                Obx(() => Text(
                  displayValue(),
                  style: const TextStyle(fontSize: 16, color: AppTheme.onSurface),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
