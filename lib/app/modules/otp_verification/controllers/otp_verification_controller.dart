import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../routes/app_pages.dart';

class OtpVerificationController extends GetxController {
  final apiService = Get.find<ApiService>();

  final otpController = TextEditingController();
  final isLoading = false.obs;

  // Parameters received from previous screen
  final email = ''.obs;
  final registrationToken = ''.obs;
  final loginToken = ''.obs;
  final purpose = ''.obs; // 'verify_email' or 'verify_login'

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      email.value = Get.arguments['email'] ?? '';
      registrationToken.value = Get.arguments['registration_token'] ?? '';
      loginToken.value = Get.arguments['login_token'] ?? '';
      purpose.value = Get.arguments['purpose'] ?? 'verify_email';
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  Future<void> verify() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      Get.snackbar('Error', 'Please enter the 6-digit OTP code',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      if (purpose.value == 'verify_email') {
        final result = await apiService.verifyEmail(
          registrationToken: registrationToken.value,
          otp: otp,
        );
        if (result['success'] == true) {
          Get.snackbar('Success', 'Email verified successfully. You can now login.',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
              snackPosition: SnackPosition.BOTTOM);
          Get.offAllNamed(Routes.LOGIN);
        } else {
          Get.snackbar('Verification Failed',
              result['error'] ?? 'Failed to verify email',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else if (purpose.value == 'verify_login') {
        final result = await apiService.verifyLogin(
          loginToken: loginToken.value,
          otp: otp,
        );
        if (result['success'] == true) {
          Get.snackbar('Success', 'Device verified successfully.',
              backgroundColor: Colors.green.withOpacity(0.1),
              colorText: Colors.green,
              snackPosition: SnackPosition.BOTTOM);
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.snackbar('Verification Failed',
              result['error'] ?? 'Failed to verify device',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (email.value.isEmpty) return;

    isLoading.value = true;
    try {
      final result = await apiService.resendOtp(
        email: email.value,
        purpose: purpose.value,
      );
      if (result['success'] == true) {
        Get.snackbar('OTP Resent', 'A new OTP has been sent to your email.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Failed', result['error'] ?? 'Failed to resend OTP',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
