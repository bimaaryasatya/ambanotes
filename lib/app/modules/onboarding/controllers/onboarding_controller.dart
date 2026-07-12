import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/models.dart';
import '../../archive/controllers/archive_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  static const String _completedKey = 'onboarding_completed';

  final RxInt currentStep = 0.obs;
  final RxBool isActive = false.obs;
  final Rx<Rect?> cutoutRect = Rx<Rect?>(null);
  final Rx<Offset?> tooltipAnchor = Rx<Offset?>(null);
  final RxString currentRoute = ''.obs;
  final RxBool isConfirmingSkip = false.obs;

  final GlobalKey quickActionsGridKey = GlobalKey();
  final GlobalKey processingSectionKey = GlobalKey();
  final GlobalKey archiveTabKey = GlobalKey();
  final GlobalKey firstDocumentKey = GlobalKey();
  final GlobalKey aiSummaryKey = GlobalKey();
  final GlobalKey disposisiKey = GlobalKey();
  final GlobalKey metadataKey = GlobalKey();

  static const int maxStep = 8;

  bool get hasCompleted => _storage.read(_completedKey) ?? false;
  bool get isOwner => apiService.isOwner;

  bool get shouldShowCurrentStep {
    if (!isActive.value) return false;
    if (currentStep.value == 6 && !isOwner) return false;
    return true;
  }

  GlobalKey? get currentTargetKey {
    switch (currentStep.value) {
      case 1:
        return quickActionsGridKey;
      case 2:
        return processingSectionKey;
      case 3:
        return archiveTabKey;
      case 4:
        return firstDocumentKey;
      case 5:
        return aiSummaryKey;
      case 6:
        return isOwner ? disposisiKey : null;
      case 7:
        return metadataKey;
      default:
        return null;
    }
  }

  bool get isArchiveDetailStep =>
      currentStep.value >= 5 && currentStep.value <= maxStep;

  @override
  void onInit() {
    super.onInit();
    if (!hasCompleted) {
      Future.delayed(const Duration(milliseconds: 600), startOnboarding);
    }
  }

  void updateRoute(String? route) {
    if (route != null) {
      currentRoute.value = route;
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
    if (currentStep.value == 6 && !isOwner) {
      currentStep.value++;
    }

    // Automatically skip Step 2 ("Waiting for Document Processing") if there are no processing documents
    if (currentStep.value == 2) {
      final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
      final processingDocs = homeController?.processingDocuments ?? [];
      if (processingDocs.isEmpty) {
        currentStep.value++; // Skip to Step 3 ("View in Files")
      }
    }

    _scheduleMeasure();

    // Automatically navigate when user clicks "Skip" on tooltips to prevent onboarding from closing
    if (currentStep.value == 4) {
      Get.offAllNamed(Routes.ARCHIVE);
    } else if (currentStep.value == 5) {
      _openFirstDocument();
    }
  }

  void _openFirstDocument() {
    if (Get.isRegistered<ArchiveController>()) {
      final archiveCtrl = Get.find<ArchiveController>();
      if (archiveCtrl.documents.isNotEmpty) {
        final doc = archiveCtrl.documents.first;
        Get.toNamed(Routes.ARCHIVE_DETAIL, arguments: doc);
        return;
      }
    }

    final dummyDoc = Document(
      id: 'dummy_invitation_001',
      title: 'Undangan Rapat Koordinasi Wilayah',
      filename: 'Undangan Rapat Koordinasi Wilayah.pdf',
      summary:
          'Kami mengundang Bapak/Ibu untuk menghadiri rapat koordinasi wilayah pada hari Senin, 20 Oktober 2026 pukul 09:00 WIB bertempat di Ruang Rapat Utama Balai Kota Jakarta.',
      status: 'processed',
      type: 'Undangan',
      archivedDate: 'Just now',
      size: '450 KB',
      delegationId: 'general',
      delegationName: 'General',
    );
    Get.toNamed(Routes.ARCHIVE_DETAIL, arguments: dummyDoc);
  }

  void completeOnboarding() {
    isActive.value = false;
    _storage.write(_completedKey, true);
  }

  void resetOnboarding() {
    _storage.remove(_completedKey);
  }

  void skipOnboarding() {
    isConfirmingSkip.value = true;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Skip Tour?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'You can restart the tour anytime from the Profile page.'),
        actions: [
          TextButton(
            onPressed: () {
              isConfirmingSkip.value = false;
              Get.back();
            },
            child: const Text('Continue Tour',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              isConfirmingSkip.value = false;
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
    ).then((_) {
      isConfirmingSkip.value = false;
    });
  }

  void onUploadProcessing(String docId) {
    if (currentStep.value == 1) {
      currentStep.value = 2;
      _scheduleMeasure();
    }
  }

  void onProcessingDone() {
    if (currentStep.value == 2) {
      currentStep.value++;
      _scheduleMeasure();
    }
  }

  void onTabChanged(int index) {
    if (currentStep.value == 3 && index == 1) {
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
      if (hasDoc && currentStep.value == 3) {
        currentStep.value++;
        _scheduleMeasure();
        return false;
      }
      if (attempts > 30) {
        if (currentStep.value == 3) {
          currentStep.value++;
          _scheduleMeasure();
        }
        return false;
      }
      return currentStep.value == 3;
    });
  }

  void onDocumentTapped() {
    if (currentStep.value == 4) {
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