import 'dart:typed_data';

import 'package:ambanotes/app/data/models/models.dart';
import 'package:ambanotes/app/data/services/api_service.dart';
import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ReplaceController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final ImagePicker picker = ImagePicker();

  late Document document;

  final isLoading = false.obs;
  final selectedBytes = Rxn<Uint8List>();
  final selectedFilename = ''.obs;
  final selectedMimeHint = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is Document) {
      document = args;
    } else {
      document = Document(
        id: '',
        title: 'Dokumen tidak ditemukan',
        summary: 'Data dokumen tidak dikirim ke halaman replace.',
        status: 'error',
        type: 'unknown',
        archivedDate: '',
        size: '0 KB',
      );

      Future.microtask(() {
        Get.snackbar(
          'Error',
          'Data dokumen tidak ditemukan.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      });
    }
  }

  bool get hasSelectedFile => selectedBytes.value != null;

  bool get isSelectedImage {
    final name = selectedFilename.value.toLowerCase();

    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');
  }

  bool get isSelectedPdf {
    return selectedFilename.value.toLowerCase().endsWith('.pdf');
  }

  /// Alias agar view lama yang masih memanggil controller.pickImage tetap aman.
  Future<void> pickImage() async {
    await pickFromGallery();
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (file == null) return;

      final Uint8List bytes = await file.readAsBytes();

      selectedBytes.value = bytes;
      selectedFilename.value = file.name;
      selectedMimeHint.value = _guessMimeFromFilename(file.name);
    } catch (e) {
      Get.snackbar(
        'Gagal Memilih File',
        'Terjadi kesalahan saat memilih file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (file == null) return;

      final Uint8List bytes = await file.readAsBytes();

      selectedBytes.value = bytes;
      selectedFilename.value = file.name;
      selectedMimeHint.value = _guessMimeFromFilename(file.name);
    } catch (e) {
      Get.snackbar(
        'Gagal Membuka Kamera',
        'Terjadi kesalahan saat mengambil gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearSelectedFile() {
    selectedBytes.value = null;
    selectedFilename.value = '';
    selectedMimeHint.value = '';
  }

  Future<void> submitReplace() async {
    if (document.id.isEmpty) {
      Get.snackbar(
        'Gagal',
        'ID dokumen tidak valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedBytes.value == null || selectedFilename.value.isEmpty) {
      Get.snackbar(
        'File Belum Dipilih',
        'Pilih file pengganti terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Ganti Dokumen?'),
        content: Text(
          'Dokumen "${document.title}" akan diganti dengan file baru dan diproses ulang oleh OCR, klasifikasi, dan ekstraksi AI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ganti'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;

    try {
      final result = await apiService.replaceDocument(
        document.id,
        bytes: selectedBytes.value,
        filename: selectedFilename.value,
      );

      if (result != null) {
        Get.snackbar(
          'Berhasil',
          'Dokumen berhasil diganti dan diproses ulang.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );

        Get.offAllNamed(Routes.ARCHIVE);
      } else {
        Get.snackbar(
          'Gagal',
          'Dokumen gagal diganti. Periksa koneksi atau response backend.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat replace dokumen: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _guessMimeFromFilename(String filename) {
    final lower = filename.toLowerCase();

    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';

    return 'application/octet-stream';
  }
}
