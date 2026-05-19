import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ambanotes/app/theme/app_theme.dart';
import '../controllers/scanner_controller.dart';

class ScannerView extends GetView<ScannerController> {
  const ScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: Obx(() {
              if (controller.isCameraInitialized.value &&
                  controller.cameraController != null) {
                return CameraPreview(controller.cameraController!);
              } else {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary));
              }
            }),
          ),

          // Header / Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
              onPressed: () => Get.back(),
            ),
          ),

          // Instruction Text
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Posisikan dokumen dalam bingkai",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => controller.captureAndProcess(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading Overlay
          Obx(() {
            if (controller.isProcessing.value) {
              return Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primary),
                        SizedBox(height: 16),
                        Text(
                          "Memproses Dokumen AI...",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
