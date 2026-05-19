import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class ForgotPasswordController extends GetxController {
  final apiService = Get.find<ApiService>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Input Error', 'Silakan masukkan email Anda.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      final success = await apiService.forgotPassword(email);
      if (success) {
        isOtpSent.value = true;
        Get.snackbar(
          'OTP Terkirim', 
          'Kode OTP pemulihan kata sandi telah dikirim ke email Anda!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM
        );
      }
    } catch (e) {
      print("Send OTP error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performReset() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (otp.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      Get.snackbar('Input Error', 'Silakan lengkapi semua kolom input.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar('Password Mismatch', 'Konfirmasi kata sandi tidak cocok.', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      final success = await apiService.resetPassword(
        emailInput: email,
        otpInput: otp,
        newPasswordInput: newPass,
      );
      if (success) {
        Get.snackbar(
          'Sukses', 
          'Kata sandi Anda berhasil diperbarui. Silakan login kembali!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM
        );
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print("Perform reset error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
