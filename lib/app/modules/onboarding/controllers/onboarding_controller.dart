import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class OnboardingController extends GetxController {
  final apiService = Get.find<ApiService>();

  final RxInt currentStep = 0.obs;
  final RxBool isActive = false.obs;
  final Rx<Rect?> cutoutRect = Rx<Rect?>(null);
  final Rx<Offset?> tooltipAnchor = Rx<Offset?>(null);

  final GlobalKey quickActionsGridKey = GlobalKey();
  final GlobalKey archiveTabKey = GlobalKey();
  final GlobalKey firstDocumentKey = GlobalKey();
  final GlobalKey aiSummaryKey = GlobalKey();
  final GlobalKey disposisiKey = GlobalKey();
  final GlobalKey metadataKey = GlobalKey();

  static const int maxStep = 7;

  bool get hasCompleted => false;
  bool get isOwner => apiService.isOwner;

  bool get shouldShowCurrentStep {
    if (!isActive.value) return false;
    if (currentStep.value == 5 && !isOwner) return false;
    return true;
  }

  GlobalKey? get currentTargetKey {
    switch (currentStep.value) {
      case 1:
        return quickActionsGridKey;
      case 2:
        return archiveTabKey;
      case 3:
        return firstDocumentKey;
      case 4:
        return aiSummaryKey;
      case 5:
        return isOwner ? disposisiKey : null;
      case 6:
        return metadataKey;
      default:
        return null;
    }
  }

  bool get isArchiveDetailStep =>
      currentStep.value >= 4 && currentStep.value <= maxStep;

  @override
  void onInit() {
    super.onInit();
    if (!hasCompleted) {
      Future.delayed(const Duration(milliseconds: 600), startOnboarding);
    }
  }

  void startOnboarding() {
    currentStep.value = 0;
    isActive.value = true;
  }

  void nextStep() {
    if (currentStep.value >= maxStep) {
      completeOnboarding();
      return;
    }
    currentStep.value++;
    if (currentStep.value == 5 && !isOwner) {
      currentStep.value++;
    }
    _scheduleMeasure();
  }

  void completeOnboarding() {
    isActive.value = false;
  }

  void skipOnboarding() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Skip Tour?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'You can restart the tour anytime from the Profile page.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Continue Tour',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              completeOnboarding();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Skip Tour', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void onUploadProcessing(String docId) {
    if (currentStep.value == 1) {
      _waitForUploadComplete(docId);
    }
  }

  void _waitForUploadComplete(String docId) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (currentStep.value != 1) return false;
      final key = archiveTabKey;
      final hasTab = key.currentContext?.findRenderObject() != null;
      if (hasTab) {
        currentStep.value++;
        _scheduleMeasure();
        return false;
      }
      return true;
    });
  }

  void onTabChanged(int index) {
    if (currentStep.value == 2 && index == 1) {
      _waitForDocumentList();
    }
  }

  void _waitForDocumentList() {
    int attempts = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
      final key = firstDocumentKey;
      final hasDoc = key.currentContext?.findRenderObject() != null;
      if (hasDoc && currentStep.value == 2) {
        currentStep.value++;
        _scheduleMeasure();
        return false;
      }
      if (attempts > 30) {
        if (currentStep.value == 2) {
          currentStep.value++;
          _scheduleMeasure();
        }
        return false;
      }
      return currentStep.value == 2;
    });
  }

  void onDocumentTapped() {
    if (currentStep.value == 3) {
      _scheduleStepAdvance();
    }
  }

  void _scheduleStepAdvance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentStep.value < maxStep) {
        currentStep.value++;
        _scheduleMeasure();
      }
    });
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTarget());
  }

  void _measureTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = currentTargetKey;
      if (key == null) {
        cutoutRect.value = null;
        tooltipAnchor.value = null;
        return;
      }
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        cutoutRect.value =
            Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
        tooltipAnchor.value = Offset(
          position.dx + size.width / 2,
          position.dy + size.height / 2,
        );
      } else {
        cutoutRect.value = null;
        tooltipAnchor.value = null;
      }
    });
  }

  void remeasure() {
    _scheduleMeasure();
  }
}