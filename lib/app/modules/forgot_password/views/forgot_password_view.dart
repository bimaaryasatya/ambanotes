import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Pemulihan Kata Sandi",
          style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Obx(() {
            final sent = controller.isOtpSent.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sent ? LucideIcons.shieldCheck : LucideIcons.keyRound,
                      size: 48,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  sent ? "Setel Ulang Kata Sandi" : "Lupa Kata Sandi?",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  sent
                      ? "Kode OTP verifikasi telah dikirimkan ke email Anda. Silakan masukkan kode tersebut dan atur sandi baru Anda."
                      : "Masukkan email yang terdaftar pada sistem AmbaNotes. Kami akan mengirimkan kode OTP verifikasi untuk mengubah kata sandi Anda.",
                  style: const TextStyle(color: AppTheme.outline, height: 1.5, fontSize: 14),
                ),
                const SizedBox(height: 32),
                if (!sent) ...[
                  _buildTextField(
                    label: "Alamat Email",
                    hint: "sandi@institusi.ac.id",
                    icon: LucideIcons.mail,
                    controller: controller.emailController,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(LucideIcons.send, size: 18),
                      label: const Text("Kirim Kode OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: controller.isLoading.value ? null : controller.sendOtp,
                    ),
                  ),
                ] else ...[
                  _buildTextField(
                    label: "Kode OTP Verifikasi",
                    hint: "Masukkan OTP",
                    icon: LucideIcons.shieldAlert,
                    controller: controller.otpController,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Kata Sandi Baru",
                    hint: "Minimal 6 karakter",
                    icon: LucideIcons.lock,
                    controller: controller.newPasswordController,
                    isPassword: true,
                    obscureText: !controller.isPasswordVisible.value,
                    onToggleVisibility: controller.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: "Konfirmasi Kata Sandi Baru",
                    hint: "Ketik ulang sandi baru",
                    icon: LucideIcons.lock,
                    controller: controller.confirmPasswordController,
                    isPassword: true,
                    obscureText: !controller.isPasswordVisible.value,
                    onToggleVisibility: controller.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(LucideIcons.checkCircle, size: 18),
                      label: const Text("Perbarui Kata Sandi", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: controller.isLoading.value ? null : controller.performReset,
                    ),
                  ),
                ],
              ],
            );
          }),
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
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
