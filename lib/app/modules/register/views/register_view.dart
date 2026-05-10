import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (controller.currentStep.value == RegisterStep.organizationSetup) {
              controller.previousStep();
            } else {
              Get.back();
            }
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStepIndicator(),
                  const SizedBox(height: 32),
                  if (controller.currentStep.value == RegisterStep.userInfo)
                    _buildUserInfoStep(context)
                  else
                    _buildOrgSetupStep(context),
                  const SizedBox(height: 40),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _indicatorCircle(1, controller.currentStep.value == RegisterStep.userInfo),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: controller.currentStep.value == RegisterStep.organizationSetup
                ? AppTheme.primary
                : AppTheme.outlineVariant,
          ),
        ),
        _indicatorCircle(2, controller.currentStep.value == RegisterStep.organizationSetup),
      ],
    );
  }

  Widget _indicatorCircle(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.primary : AppTheme.outlineVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create Account",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "Start your journey with AmbaNotes.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.outline,
              ),
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: "Full Name",
          hint: "Enter your full name",
          icon: LucideIcons.user,
          controller: controller.usernameController,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: "Email Address",
          hint: "example@email.com",
          icon: LucideIcons.mail,
          controller: controller.emailController,
        ),
        const SizedBox(height: 20),
        Obx(() => _buildTextField(
              label: "Password",
              hint: "Minimum 8 characters",
              icon: LucideIcons.lock,
              controller: controller.passwordController,
              isPassword: true,
              obscureText: !controller.isPasswordVisible.value,
              onToggleVisibility: controller.togglePasswordVisibility,
            )),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => controller.nextStep(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Continue",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrgSetupStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Organization Setup",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join an existing organization or create a new one.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.outline,
              ),
        ),
        const SizedBox(height: 32),
        _buildSetupOption(
          id: 'organization',
          title: "Create Organization",
          subtitle: "Setup a new secretariat workspace",
          icon: LucideIcons.building,
        ),
        const SizedBox(height: 16),
        _buildSetupOption(
          id: 'invitation',
          title: "Use Invitation Code",
          subtitle: "Join an existing organization",
          icon: LucideIcons.ticket,
        ),
        const SizedBox(height: 32),
        if (controller.setupOption.value == 'organization')
          _buildTextField(
            label: "Organization Name",
            hint: "Enter organization name",
            icon: LucideIcons.briefcase,
            controller: controller.organizationNameController,
          )
        else if (controller.setupOption.value == 'invitation')
          _buildTextField(
            label: "Invitation Code",
            hint: "Enter 6-digit code",
            icon: LucideIcons.hash,
            controller: controller.invitationCodeController,
          ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.register(),
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
                    "Finish Registration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetupOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = controller.setupOption.value == id;
    return InkWell(
      onTap: () => controller.selectSetupOption(id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.outlineVariant.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.outline,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.checkCircle2, color: AppTheme.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: AppTheme.outline),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
                        size: 20,
                        color: AppTheme.outline,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: AppTheme.outline),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
