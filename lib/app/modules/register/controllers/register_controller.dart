import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/api_service.dart';

enum RegisterStep { userInfo, organizationSetup }

class RegisterController extends GetxController {
  final apiService = Get.find<ApiService>();

  // Step 1 controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Step 2 controllers
  final organizationNameController = TextEditingController();
  final invitationCodeController = TextEditingController();

  final currentStep = RegisterStep.userInfo.obs;
  final setupOption = RxnString(); // 'organization' or 'invitation'

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void nextStep() {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }
    currentStep.value = RegisterStep.organizationSetup;
  }

  void previousStep() {
    currentStep.value = RegisterStep.userInfo;
  }

  void selectSetupOption(String option) {
    setupOption.value = option;
  }

  void register() async {
    if (setupOption.value == null) {
      Get.snackbar(
        "Error",
        "Please choose an organization setup option",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (setupOption.value == 'organization' &&
        organizationNameController.text.isEmpty) {
      Get.snackbar("Error", "Please enter organization name",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (setupOption.value == 'invitation' &&
        invitationCodeController.text.isEmpty) {
      Get.snackbar("Error", "Please enter invitation code",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    final action = setupOption.value == 'organization' ? 'create_org' : 'join_org';
    final orgName = setupOption.value == 'organization' ? organizationNameController.text : null;

    final result = await apiService.register(
      usernameInput: usernameController.text.trim(),
      emailInput: emailController.text.trim().toLowerCase(),
      passwordInput: passwordController.text,
      action: action,
      orgName: orgName,
      invitationCode: setupOption.value == 'invitation' ? invitationCodeController.text.trim() : null,
    );
    isLoading.value = false;

    if (result['success'] == true) {
      if (result['requires_verification'] == true) {
        Get.offNamed(Routes.OTP_VERIFICATION, arguments: {
          'email': result['email'],
          'registration_token': result['registration_token'],
          'purpose': 'verify_email',
        });
      } else {
        Get.snackbar('Registration Success',
            'User registered successfully. Please login.',
            snackPosition: SnackPosition.BOTTOM);
        Get.offAllNamed(Routes.LOGIN);
      }
    }
  }

  void goToLogin() {
    Get.back();
  }
}
