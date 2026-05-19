import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/api_service.dart';

class LoginController extends GetxController {
  final apiService = Get.find<ApiService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    isLoading.value = true;
    final success = await apiService.login(emailController.text, passwordController.text);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }
}
