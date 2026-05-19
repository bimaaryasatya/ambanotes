import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text("Pengaturan & Profil", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.red),
            onPressed: controller.logout,
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildGoogleDriveCard(),
              const SizedBox(height: 24),
              if (controller.apiService.isOwner) ...[
                _buildOwnerInviteCard(),
                const SizedBox(height: 24),
                _buildStaffRosterCard(),
                const SizedBox(height: 24),
              ],
              _buildGeneralSettingsCard(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 2),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDmU6mMwiX67PUwAXsSeel6gR6OcCaGid7ocK9MoDsDXFStorjDCsvKbQHT2Vm0fUGtCM1YVhoEhJMe5kNYPOIAbfhqNP28Wp6EGhevy3WIPRrObwRIAeRUnLZIJQ7rwkO133r4qEX6HRgzf5ZBocAlxCoHhPtJVLpMvUSQfGFQ95yNwh9RlBu37TYcaHmWzW74vVSV3crHQnydSGuM288kkNwQMBTzMthQBsYMEqFFe6pDYB6k0nnrHLmNZ1ygQmD4j0kggcdubE8z'
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.username.value.toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            controller.email.value,
            style: const TextStyle(fontSize: 13, color: AppTheme.outline),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.building2, size: 14, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  controller.orgName.value.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 0.5),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: controller.role.value == 'owner' ? Colors.purple : AppTheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.role.value.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleDriveCard() {
    final connected = controller.isDriveConnected.value;
    final migrating = controller.isMigrating.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.hardDrive, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text("Integrasi Cloud Storage", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: connected ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  connected ? "Connected" : "Disconnected",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: connected ? Colors.green : Colors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Hubungkan akun Google Drive institusi Anda untuk mengamankan penyimpanan dokumen digital secara otomatis serta mengaktifkan pemindaian berkas.",
            style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (!connected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(LucideIcons.lock, size: 16),
                label: const Text("Otorisasi Google Drive", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.connectDrive,
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: migrating 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(LucideIcons.refreshCw, size: 16),
                label: Text(migrating ? "Memindahkan Berkas..." : "Migrasikan Berkas Lokal ke Drive", style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: migrating ? null : controller.migrateFiles,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildOwnerInviteCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.mailPlus, color: Colors.purple),
              SizedBox(width: 8),
              Text("Undang Anggota Baru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Masukkan alamat email staff untuk mengirimkan undangan resmi gabung organisasi. Data berkas delegasi mereka akan otomatis disinkronisasikan setelah pendaftaran.",
            style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.inviteEmailController,
            decoration: InputDecoration(
              hintText: "staff@institusi.ac.id",
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.send, size: 16),
              label: const Text("Kirim Undangan Organisasi", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: controller.inviteMember,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStaffRosterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.users, color: AppTheme.secondary),
              const SizedBox(width: 8),
              const Text("Daftar Anggota & Staff", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  "${controller.members.length} Orang",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (controller.members.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Belum ada anggota terdaftar.", style: TextStyle(color: AppTheme.outline, fontSize: 13)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.members.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final m = controller.members[index];
                final roleStr = m['role'] ?? 'member';
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.surfaceVariant, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.user, size: 18, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['username'] ?? 'Staff Member', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                          const SizedBox(height: 2),
                          Text(m['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.outline)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleStr == 'owner' ? Colors.purple.withOpacity(0.1) : AppTheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleStr.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: roleStr == 'owner' ? Colors.purple : AppTheme.secondary),
                      ),
                    )
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingsRow(LucideIcons.bell, "Pengaturan Notifikasi"),
          const Divider(height: 24),
          _buildSettingsRow(LucideIcons.shieldAlert, "Keamanan & Sandi"),
          const Divider(height: 24),
          _buildSettingsRow(LucideIcons.helpCircle, "Pusat Bantuan AmbaNotes"),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        const Spacer(),
        const Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.outlineVariant),
      ],
    );
  }
}
