import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';
import '../controllers/otp_verification_controller.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => controller.goBack(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.mailCheck,
                    color: AppTheme.primary,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Obx(() => Text(
                    controller.purpose.value == 'verify_email'
                        ? 'Verify Your Email'
                        : 'Verify New Device',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 12),
              Obx(() => Text(
                    controller.purpose.value == 'verify_email'
                        ? 'We have sent a 6-digit verification code to'
                        : 'For security, we have sent a 6-digit code to',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 4),
              Obx(() => Text(
                    controller.email.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(height: 40),
              _buildOtpField(context),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.verify(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Verify',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    )),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(color: AppTheme.outline),
                  ),
                  TextButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.resendOtp(),
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTP Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          child: TextField(
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              counterText: '',
              hintText: '------',
              hintStyle: TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                color: AppTheme.outline,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
