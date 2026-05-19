import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';
import 'security_view.dart';
import 'notification_settings_view.dart';

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
          primary: true,
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
                _buildStaffRosterCard(context),
                const SizedBox(height: 24),
                _buildDelegationManagementCard(context),
                const SizedBox(height: 24),
                _buildAssetUploadCard(),
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
          if (controller.role.value == 'owner' && controller.inviteCode.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Clipboard.setData(ClipboardData(text: controller.inviteCode.value));
                Get.snackbar(
                  'Salin Berhasil',
                  'Kode undangan "${controller.inviteCode.value}" telah disalin ke clipboard.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.9),
                  colorText: Colors.white,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.copy, size: 14, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      "Kode Undang: ${controller.inviteCode.value}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.unlock, size: 16),
                label: const Text("Putuskan Koneksi Google Drive", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text("Putuskan Google Drive?", style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("Apakah Anda yakin ingin memutuskan integrasi Google Drive Anda? Akun akan dilepas dan sinkronisasi berkas otomatis akan dinonaktifkan."),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            controller.disconnectDrive();
                          },
                          child: const Text("Putuskan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
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

  Widget _buildStaffRosterCard(BuildContext context) {
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
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.members.length > 5 ? 5 : controller.members.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final m = controller.members[index];
                return _buildMemberRow(context, m);
              },
            ),
            if (controller.members.length > 5) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => _showAllMembersDialog(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Lihat Semua Member", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, Map<String, dynamic> m) {
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
              if (roleStr != 'owner') ...[
                const SizedBox(height: 4),
                Text("Divisi: ${m['delegation_name'] ?? 'Belum Ditentukan'}", style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ],
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
        ),
        if (roleStr != 'owner') ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.gitPullRequest, size: 16, color: AppTheme.primary),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Pindahkan Divisi Anggota", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pilih divisi/delegasi baru untuk ${m['username']}. Semua dokumen milik anggota ini akan ikut dimigrasi ke divisi baru tersebut.", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (controller.delegations.isEmpty) {
                          return const Text("Belum ada divisi yang dibuat. Silakan buat divisi terlebih dahulu di bawah.", style: TextStyle(fontSize: 13, color: Colors.red));
                        }
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          hint: const Text("Pilih Divisi"),
                          value: controller.delegations.any((d) => d['_id'] == m['delegation_id']) ? m['delegation_id'] : null,
                          items: controller.delegations.map((d) {
                            return DropdownMenuItem<String>(
                              value: d['_id'],
                              child: Text(d['name'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              Get.back();
                              controller.moveMemberDelegation(m['id'], val);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ]
      ],
    );
  }

  void _showAllMembersDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.users, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text("Semua Anggota & Staff", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 450),
          child: Obx(() => ListView.separated(
            shrinkWrap: true,
            itemCount: controller.members.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final m = controller.members[index];
              return _buildMemberRow(context, m);
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Tutup", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
  Widget _buildAssetUploadCard() {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.stamp, size: 20, color: Colors.deepPurple),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Aset Organisasi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                    Text("Upload kop surat & tanda tangan digital", style: TextStyle(fontSize: 11, color: AppTheme.outline)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text("Owner", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => controller.isUploadingAsset.value
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ))
            : Column(
                children: [
                  _buildAssetUploadTile(
                    icon: LucideIcons.fileImage,
                    title: "Kop Surat",
                    subtitle: "Gambar header surat resmi organisasi",
                    color: Colors.blue,
                    onTap: () => controller.pickAndUploadAsset('kop'),
                  ),
                  const SizedBox(height: 12),
                  _buildAssetUploadTile(
                    icon: LucideIcons.penTool,
                    title: "Tanda Tangan Digital",
                    subtitle: "Gambar TTD / QR Code pimpinan",
                    color: Colors.teal,
                    onTap: () => controller.pickAndUploadAsset('ttd'),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetUploadTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.outline)),
                ],
              ),
            ),
            Icon(LucideIcons.upload, size: 18, color: color.withOpacity(0.6)),
          ],
        ),
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
          _buildSettingsRow(
            LucideIcons.bell, 
            "Pengaturan Notifikasi",
            onTap: () => Get.to(() => const NotificationSettingsView()),
          ),
          const Divider(height: 24),
          _buildSettingsRow(
            LucideIcons.shieldAlert, 
            "Keamanan & Sandi", 
            onTap: () => Get.to(() => const SecurityView()),
          ),
          const Divider(height: 24),
          _buildSettingsRow(LucideIcons.helpCircle, "Pusat Bantuan AmbaNotes"),
        ],
      ),
    );
  }

  Widget _buildDelegationManagementCard(BuildContext context) {
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
              const Icon(LucideIcons.gitMerge, color: Colors.blue),
              const SizedBox(width: 8),
              const Text("Kelola Delegasi / Divisi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                child: Obx(() => Text(
                  "${controller.delegations.length} Divisi",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                )),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.delegationNameController,
                  decoration: InputDecoration(
                    hintText: "Nama Divisi Baru...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final name = controller.delegationNameController.text.trim();
                  if (name.isNotEmpty) {
                    controller.createDelegation(name);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Icon(LucideIcons.plus, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => controller.delegations.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("Belum ada divisi terdaftar.", style: TextStyle(color: AppTheme.outline, fontSize: 13)),
                ),
              )
            : Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.delegations.length > 5 ? 5 : controller.delegations.length,
                    separatorBuilder: (context, index) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final d = controller.delegations[index];
                      return _buildDelegationRow(context, d);
                    },
                  ),
                  if (controller.delegations.length > 5) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => _showAllDivisionsDialog(context),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Lihat Semua Divisi", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                            SizedBox(width: 4),
                            Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildDelegationRow(BuildContext context, Map<String, dynamic> d) {
    final String name = d['name'] ?? '';
    final String id = d['_id'] ?? '';
    return InkWell(
      onTap: () {
        _showDivisionMembersDialog(context, name, id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.surfaceVariant, shape: BoxShape.circle),
              child: const Icon(LucideIcons.gitBranch, size: 18, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                  const SizedBox(height: 2),
                  Obx(() {
                    final count = controller.members.where((m) => m['delegation_id'] == id && m['role'] != 'owner').length;
                    return Text("$count Anggota", style: const TextStyle(fontSize: 11, color: AppTheme.outline));
                  }),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.edit2, size: 18, color: AppTheme.outline),
              onPressed: () {
                final editController = TextEditingController(text: name);
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text("Ubah Nama Divisi", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: TextField(
                      controller: editController,
                      decoration: InputDecoration(
                        labelText: "Nama Divisi",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          final newName = editController.text.trim();
                          if (newName.isNotEmpty) {
                            Get.back();
                            controller.renameDelegation(id, newName);
                          }
                        },
                        child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text("Hapus Divisi?", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Text("Apakah Anda yakin ingin menghapus divisi '$name'? Semua anggota di dalam divisi ini akan dipindahkan ke General (tanpa divisi)."),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteDelegation(id);
                        },
                        child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllDivisionsDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.gitMerge, color: Colors.blue),
            const SizedBox(width: 8),
            const Text("Semua Delegasi / Divisi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 450),
          child: Obx(() => ListView.separated(
            shrinkWrap: true,
            itemCount: controller.delegations.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final d = controller.delegations[index];
              return _buildDelegationRow(context, d);
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Tutup", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          const Spacer(),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppTheme.outlineVariant),
        ],
      ),
    );
  }

  void _showDivisionMembersDialog(BuildContext context, String divisionName, String divisionId) {
    final selectedMemberIds = <String>[].obs;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.users, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Anggota: $divisionName', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Obx(() {
            // Get all members currently assigned to this division
            final divisionMembers = controller.members.where((m) => m['delegation_id'] == divisionId && m['role'] != 'owner').toList();
            
            if (divisionMembers.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Tidak ada anggota di divisi ini.', 
                    style: TextStyle(color: Colors.grey, fontSize: 14)
                  ),
                ),
              );
            }
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih anggota untuk melakukan batch edit atau klik tombol kanan untuk memindahkan secara individual:', 
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: divisionMembers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final m = divisionMembers[idx];
                      final uid = m['id'] ?? '';
                      
                      return Obx(() {
                        final isSelected = selectedMemberIds.contains(uid);
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppTheme.primary,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            m['username'] ?? '', 
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                          ),
                          subtitle: Text(
                            m['email'] ?? '', 
                            style: const TextStyle(fontSize: 12, color: Colors.grey)
                          ),
                          onChanged: (checked) {
                            if (checked == true) {
                              selectedMemberIds.add(uid);
                            } else {
                              selectedMemberIds.remove(uid);
                            }
                          },
                          secondary: IconButton(
                            icon: const Icon(LucideIcons.gitPullRequest, size: 18, color: AppTheme.primary),
                            tooltip: 'Pindahkan Anggota',
                            onPressed: () {
                              _showMoveSingleMemberDialog(context, m);
                            },
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          Obx(() {
            if (selectedMemberIds.isEmpty) {
              return TextButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedMemberIds.length} Terpilih',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final idsToMove = selectedMemberIds.toList();
                          Get.back();
                          controller.moveMultipleMembersDelegation(idsToMove, 'general');
                        },
                        child: const Text('Keluarkan', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final idsToMove = selectedMemberIds.toList();
                          _showBatchMoveDialog(context, idsToMove, divisionId);
                        },
                        child: const Text('Pindahkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showMoveSingleMemberDialog(BuildContext context, Map<String, dynamic> member) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Pindahkan ${member['username']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih divisi/delegasi tujuan:", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            Obx(() {
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text("Pilih Divisi"),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'general',
                    child: Text('Keluar ke General (Tanpa Divisi)'),
                  ),
                  ...controller.delegations.map((d) {
                    return DropdownMenuItem<String>(
                      value: d['_id'],
                      child: Text(d['name'] ?? ''),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  if (val != null) {
                    Get.back(); // close single move dialog
                    Get.back(); // close division details dialog
                    controller.moveMemberDelegation(member['id'], val);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showBatchMoveDialog(BuildContext context, List<String> memberIds, String currentDivisionId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Pindahkan ${memberIds.length} Anggota", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih divisi/delegasi tujuan baru untuk semua anggota terpilih:", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            Obx(() {
              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text("Pilih Divisi"),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'general',
                    child: Text('Keluar ke General (Tanpa Divisi)'),
                  ),
                  ...controller.delegations.where((d) => d['_id'] != currentDivisionId).map((d) {
                    return DropdownMenuItem<String>(
                      value: d['_id'],
                      child: Text(d['name'] ?? ''),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  if (val != null) {
                    Get.back(); // close batch dialog
                    Get.back(); // close division details dialog
                    controller.moveMultipleMembersDelegation(memberIds, val);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
