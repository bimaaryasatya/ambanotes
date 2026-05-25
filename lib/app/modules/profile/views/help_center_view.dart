import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  static const _phone = '+62 811-0000-1234';
  static const _email = 'work@bimazznxt.my.id';

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Pusat Bantuan AmbaNotes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: AppTheme.outlineVariant.withOpacity(0.35)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh bantuan?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tim developer AmbaNotes siap membantu jika Anda mengalami kendala saat mengelola dokumen, histori chat, atau fitur organisasi.',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ContactCard(
            icon: LucideIcons.phone,
            title: 'Telepon Developer',
            value: _phone,
            onTap: () => _openUri('tel:$_phone'),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: LucideIcons.mail,
            title: 'Email Developer',
            value: _email,
            onTap: () => _openUri('mailto:$_email'),
          ),
        ],
      ),
    );
  }

  static Future<void> _openUri(String uri) async {
    final parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed);
      return;
    }

    await Clipboard.setData(ClipboardData(text: uri.replaceFirst('mailto:', '')));
    Get.snackbar(
      'Disalin ke Clipboard',
      'Kontak developer disalin karena perangkat tidak dapat membuka tautan.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}
