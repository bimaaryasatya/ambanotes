import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/services/api_service.dart';

class AssignmentFormController extends GetxController {
  final apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();

  final letterNumberController = TextEditingController();
  final locationController = TextEditingController();

  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<TimeOfDay?>(null);
  
  final selectedKopSurat = 'Kop Utama Institusi'.obs;
  final sourceDocumentTitle = 'Undangan'.obs;
  final isLoading = false.obs;
  
  String docId = 'unknown';

  final List<String> kopSuratOptions = [
    'Kop Utama Institusi',
    'Kop Divisi HR',
    'Kop Divisi Operasional',
    'Kop Kepanitiaan Acara',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      docId = args['doc_id'] ?? 'unknown';
      letterNumberController.text = args['nomor_surat'] ?? '';
      locationController.text = args['organisasi'] ?? '';
      sourceDocumentTitle.value = args['title'] ?? args['perihal'] ?? 'Undangan';
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      selectedTime.value = time;
    }
  }

  String get formattedDate => selectedDate.value != null 
    ? DateFormat('dd MMMM yyyy').format(selectedDate.value!) 
    : 'Pilih Tanggal';

  String get formattedTime => selectedTime.value != null 
    ? '${selectedTime.value!.hour.toString().padLeft(2, '0')}:${selectedTime.value!.minute.toString().padLeft(2, '0')} WIB' 
    : 'Pilih Waktu';

  void submitForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (formKey.currentState!.validate()) {
      if (selectedDate.value == null || selectedTime.value == null) {
        Get.snackbar('Error', 'Silakan pilih tanggal dan waktu', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
        return;
      }

      final dateStr = formattedDate;
      final timeStr = formattedTime;
      final location = locationController.text;
      final letterNo = letterNumberController.text;
      
      // Default to delegation name if member, otherwise owner chooses from dropdown
      final kop = apiService.isOwner ? selectedKopSurat.value : (apiService.delegationName.value ?? 'Kop Utama Institusi');

      isLoading.value = true;
      final result = await apiService.generateSuratTugas(
        referenceDocId: docId,
        letterNumber: letterNo,
        date: dateStr,
        time: timeStr,
        location: location,
        kop: kop,
      );
      isLoading.value = false;

      if (result != null) {
        Get.back(); // go back to details
        Get.snackbar(
          'Sukses', 
          'Surat tugas berhasil dibuat dan didaftarkan ke sistem.', 
          backgroundColor: Colors.green.withOpacity(0.1), 
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM
        );
      } else {
        Get.snackbar(
          'Error', 
          'Gagal mendaftarkan surat tugas ke server.', 
          backgroundColor: Colors.red.withOpacity(0.1), 
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM
        );
      }
    }
  }
}
