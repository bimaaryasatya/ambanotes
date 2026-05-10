import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ambanotes/app/data/models/models.dart';
import 'package:ambanotes/app/modules/archive/controllers/archive_controller.dart';
import 'package:intl/intl.dart';

class AssignmentFormController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final letterNumberController = TextEditingController();
  final locationController = TextEditingController();

  final selectedDate = Rx<DateTime?>(null);
  final selectedTime = Rx<TimeOfDay?>(null);
  
  final selectedKopSurat = 'Kop Utama Institusi'.obs;

  final List<String> kopSuratOptions = [
    'Kop Utama Institusi',
    'Kop Divisi HR',
    'Kop Divisi Operasional',
    'Kop Kepanitiaan Acara',
  ];

  late Document sourceDocument;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Document) {
      sourceDocument = args;
    } else {
      sourceDocument = Document(
        id: 'unknown',
        title: 'Unknown',
        summary: '',
        status: 'Draft',
        type: 'Invitation',
        archivedDate: DateFormat('MMM dd, yyyy').format(DateTime.now()),
        size: '0 KB',
      );
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

  void submitForm() {
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
      final kop = selectedKopSurat.value;

      final htmlTemplate = '''
<div style="font-family: sans-serif; padding: 20px;">
  <div style="text-align: center; border-bottom: 2px solid black; padding-bottom: 10px; margin-bottom: 20px;">
    <h2>$kop</h2>
    <p>Surat Jalan / Tugas</p>
  </div>
  <p><strong>Nomor:</strong> $letterNo</p>
  <p><strong>Tanggal Terbit:</strong> ${DateFormat('dd MMMM yyyy').format(DateTime.now())}</p>
  <br>
  <p>Berdasarkan undangan referensi <strong>"${sourceDocument.title}"</strong>, maka dengan ini menugaskan nama-nama terlampir untuk hadir pada:</p>
  <ul>
    <li><strong>Tanggal:</strong> $dateStr</li>
    <li><strong>Waktu:</strong> $timeStr</li>
    <li><strong>Tempat:</strong> $location</li>
  </ul>
  <br>
  <p>Demikian surat tugas ini dibuat agar dapat dilaksanakan dengan penuh tanggung jawab.</p>
</div>
''';

      final newDoc = Document(
        id: 'st_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Surat Tugas: $location',
        summary: htmlTemplate,
        status: 'Draft',
        type: 'Surat Tugas',
        archivedDate: DateFormat('MMM dd, yyyy').format(DateTime.now()),
        size: '1.2 MB',
      );

      try {
        final archiveCtrl = Get.find<ArchiveController>();
        archiveCtrl.documents.insert(0, newDoc);
      } catch (e) {
        print("ArchiveController not found in memory");
      }

      Get.back(); // go back to details
      Get.back(); // go back to archive
      Get.snackbar(
        'Sukses', 
        'Surat tugas berhasil dibuat dan disimpan.', 
        backgroundColor: Colors.green.withOpacity(0.1), 
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM
      );
    }
  }
}
