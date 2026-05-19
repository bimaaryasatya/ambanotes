import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ScannerController extends GetxController {
  CameraController? cameraController;
  final isCameraInitialized = false.obs;
  final isProcessing = false.obs;

  Interpreter? _interpreter;

  // Final cropped output image path
  final croppedImagePath = Rxn<String>();

  @override
  void onReady() {
    super.onReady();
    _initCamera();
    _loadModel();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _interpreter?.close();
    super.onClose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar("Error", "Tidak ada kamera yang terdeteksi");
        return;
      }
      
      cameraController = CameraController(
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first),
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      print("Camera init error: $e");
      Get.snackbar("Error Kamera", e.toString(), duration: const Duration(seconds: 5));
    }
  }

  Future<void> _loadModel() async {
    try {
      // FairScan model usually expects 256x256 input
      _interpreter = await Interpreter.fromAsset(
          'assets/ml/fairscan-segmentation-model.tflite');
      print('TFLite Model loaded successfully');

      if (_interpreter != null) {
        print("Input shape: ${_interpreter!.getInputTensor(0).shape}");
        print("Output shape: ${_interpreter!.getOutputTensor(0).shape}");
      }
    } catch (e) {
      print("Failed to load TFLite model: $e");
      Get.snackbar("Error", "Gagal memuat AI pemindai");
    }
  }

  Future<void> captureAndProcess() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;
    if (_interpreter == null) {
      Get.snackbar("Menunggu", "Model AI sedang dimuat...");
      return;
    }

    isProcessing.value = true;
    try {
      // 1. Take picture
      final XFile photo = await cameraController!.takePicture();
      final File imageFile = File(photo.path);

      // 2. Decode image
      final img.Image? originalImage =
          img.decodeImage(await imageFile.readAsBytes());
      if (originalImage == null) throw Exception("Failed to decode image");

      // 3. Process TFLite Inference & Cropping (Phase 3 & 4)
      await _runSegmentationAndCrop(originalImage);
    } catch (e) {
      print("Capture error: $e");
      Get.snackbar("Error", "Gagal memproses gambar");
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _runSegmentationAndCrop(img.Image originalImage) async {
    // TODO: Implement Phase 3 and Phase 4
    // 1. Resize to 256x256
    // 2. Convert to Float32List
    // 3. Inference
    // 4. Contour detection & warp

    // For now, simulate processing and just return original
    await Future.delayed(const Duration(seconds: 1));
    Get.snackbar(
        "Info", "Segmentasi dipanggil (belum diimplementasikan penuh)");
  }
}
