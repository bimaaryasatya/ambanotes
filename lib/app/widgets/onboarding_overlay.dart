import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../modules/onboarding/controllers/onboarding_controller.dart';
import '../theme/app_theme.dart';

class OnboardingOverlay extends StatelessWidget {
  final int minStep;
  final int maxStep;
  final Widget child;

  const OnboardingOverlay({
    super.key,
    required this.child,
    this.minStep = 0,
    this.maxStep = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<OnboardingController>();
      final step = controller.currentStep.value;
      final active =
          controller.isActive.value && step >= minStep && step <= maxStep;

      if (!active) return child;

      final showCutout = step >= 1 && step <= 6;

      return Stack(
        children: [
          child,
          if (showCutout && controller.cutoutRect.value != null)
            Positioned.fill(
              child: ClipPath(
                clipper: _CutoutClipper(
                    cutoutRect: controller.cutoutRect.value!),
                child: Container(color: Colors.black.withOpacity(0.55)),
              ),
            ),
          if (!showCutout)
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.55)),
            ),
          if (showCutout) _buildTooltip(context),
          if (step == 0) _buildWelcomeCard(),
          if (step == 7) _buildCompletionCard(),
        ],
      );
    });
  }

  Widget _buildTooltip(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final rect = controller.cutoutRect.value;
    if (rect == null) return const SizedBox.shrink();

    final screen = MediaQuery.of(context).size;
    const cardWidth = 300.0;
    // Estimating a safer maximum height for dynamic card contents to prevent overflow
    const cardHeight = 240.0;
    
    final step = controller.currentStep.value;
    final spaceAbove = rect.top;
    final spaceBelow = screen.height - rect.bottom;
    
    // Check if step uses a bottom navbar (steps 1, 2, 3)
    final hasNavbar = step >= 1 && step <= 3;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomThreshold = hasNavbar ? (80.0 + bottomInset) : (16.0 + bottomInset);
    
    // Decide to place above if there isn't enough space below, or if the highlighted element is deep
    final placeAbove = (spaceBelow - bottomThreshold) < (cardHeight + 20) && spaceAbove > (cardHeight + 20);

    double top = placeAbove
        ? rect.top - cardHeight - 16
        : rect.bottom + 16;
        
    // Clamp the top position so the card stays within safe screen bounds, 
    // ensuring it never covers the bottom navbar or safe area.
    // We check min/max values to prevent clamp throwing assertions if constraints are negative/0.
    final double minTop = MediaQuery.of(context).padding.top + 8.0;
    double maxTop = screen.height - cardHeight - bottomThreshold;
    if (maxTop < minTop) {
      maxTop = minTop;
    }
    top = top.clamp(minTop, maxTop);

    final double minLeft = 8.0;
    double maxLeft = screen.width - cardWidth - 8.0;
    if (maxLeft < minLeft) {
      maxLeft = minLeft;
    }
    final left = ((screen.width - cardWidth) / 2).clamp(minLeft, maxLeft);

    return Positioned(
      top: top,
      left: left,
      child: _TooltipCard(step: step),
    );
  }

  Widget _buildWelcomeCard() {
    return Center(
      child: _buildCenteredCard(
        icon: LucideIcons.sparkles,
        title: 'Welcome to AmbaNotes!',
        description:
            'Let\'s take a quick tour to get you started with managing your documents efficiently.',
        buttonLabel: 'Start Tour',
        onButtonTap: () =>
            Get.find<OnboardingController>().nextStep(),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Center(
      child: _buildCenteredCard(
        icon: LucideIcons.checkCircle2,
        iconColor: Colors.green,
        title: 'Tour Complete!',
        description:
            'You\'ve learned the basics. Explore all features at your own pace.',
        buttonLabel: 'Finish',
        onButtonTap: () =>
            Get.find<OnboardingController>().completeOnboarding(),
      ),
    );
  }

  Widget _buildCenteredCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onButtonTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor ?? AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onButtonTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TooltipCard extends StatelessWidget {
  final int step;

  const _TooltipCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final data = _stepData[step];
    final controller = Get.find<OnboardingController>();

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black.withOpacity(0.15),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Step $step of 7',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: controller.skipOnboarding,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppTheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  data.buttonLabel,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CutoutClipper extends CustomClipper<Path> {
  final Rect cutoutRect;

  _CutoutClipper({required this.cutoutRect});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutout = Path()
      ..addRRect(
          RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)));

    return Path.combine(PathOperation.difference, path, cutout);
  }

  @override
  bool shouldReclip(_CutoutClipper oldClipper) =>
      oldClipper.cutoutRect != cutoutRect;
}

class _StepData {
  final String title;
  final String description;
  final String buttonLabel;

  const _StepData({
    required this.title,
    required this.description,
    required this.buttonLabel,
  });
}

const _stepData = <_StepData>[
  _StepData(title: '', description: '', buttonLabel: ''),
  _StepData(
    title: 'Upload or Scan a Document',
    description:
        'Tap Scan to capture with your camera, or Upload to pick a file from your device. Your document will be analyzed by AI.',
    buttonLabel: 'Skip \u2192',
  ),
  _StepData(
    title: 'View in Files',
    description:
        'Once processed, go to the Files tab to see your uploaded document and its AI analysis.',
    buttonLabel: 'Skip \u2192',
  ),
  _StepData(
    title: 'Open a Document',
    description:
        'Tap on a document in the list to see its full details and extracted information.',
    buttonLabel: 'Skip \u2192',
  ),
  _StepData(
    title: 'AI Summary',
    description:
        'This is the AI-generated summary of your document. AmbaAI analyzes content, extracts entities, and classifies each document automatically.',
    buttonLabel: 'Next',
  ),
  _StepData(
    title: 'Disposisi Surat',
    description:
        'Assign this document to a division. First, set up your organization\'s divisions in Profile > Manajemen Organisasi.',
    buttonLabel: 'Next',
  ),
  _StepData(
    title: 'Extracted Entities',
    description:
        'These are key pieces of information extracted by AI \u2014 letter number, subject, sender organization, and more.',
    buttonLabel: 'Next',
  ),
  _StepData(title: '', description: '', buttonLabel: ''),
];