import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/profile_controller.dart';

class ManageEnterpriseView extends GetView<ProfileController> {
  const ManageEnterpriseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          "Manajemen Organisasi",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOwnerInviteCard(),
            const SizedBox(height: 24),
            _buildStaffRosterCard(context),
            const SizedBox(height: 24),
            _buildDelegationManagementCard(context),
            const SizedBox(height: 24),
            _buildAssetUploadCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Owner Invite & Staff Roster Cards ---

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
              Text("Undang Anggota Baru",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Masukkan alamat email staff untuk mengirimkan undangan resmi gabung organisasi. Data berkas delegasi mereka akan otomatis disinkronisasikan setelah pendaftaran.",
            style: TextStyle(
                fontSize: 13, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.inviteEmailController,
            decoration: InputDecoration(
              hintText: "staff@institusi.ac.id",
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.send, size: 16),
              label: const Text("Kirim Undangan",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () {
                final email = controller.inviteEmailController.text.trim();
                if (email.isNotEmpty) {
                  controller.inviteMember();
                }
              },
            ),
          ),
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
              const Icon(LucideIcons.users, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text("Daftar Anggota & Staff",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface)),
              ),
              TextButton.icon(
                onPressed: () => _showAllMembersDialog(context),
                icon: const Icon(LucideIcons.arrowRight,
                    size: 14, color: AppTheme.primary),
                label: const Text("Lihat Semua",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primary.withOpacity(0.07),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.members.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("Belum ada anggota.",
                      style: TextStyle(color: AppTheme.outline, fontSize: 13)),
                ),
              );
            }
            final preview = controller.members.take(4).toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: preview.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final m = preview[index];
                return _buildMemberRow(context, m);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, Map<String, dynamic> m) {
    final roleStr = (m['role'] ?? 'staff').toString().toLowerCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(
            (m['username'] ?? '?')[0].toUpperCase(),
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m['username'] ?? '',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface)),
              const SizedBox(height: 2),
              Text(m['email'] ?? '',
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.outline)),
              if (roleStr != 'owner') ...[
                const SizedBox(height: 4),
                Text("Divisi: ${m['delegation_name'] ?? 'Belum Ditentukan'}",
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: roleStr == 'owner'
                ? Colors.purple.withOpacity(0.1)
                : AppTheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            roleStr.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: roleStr == 'owner' ? Colors.purple : AppTheme.secondary),
          ),
        ),
        if (roleStr != 'owner') ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.gitPullRequest,
                size: 16, color: AppTheme.primary),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text("Pindahkan Divisi Anggota",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Pilih divisi/delegasi baru untuk ${m['username']}. Semua dokumen milik anggota ini akan ikut dimigrasi ke divisi baru tersebut.",
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (controller.delegations.isEmpty) {
                          return const Text(
                              "Belum ada divisi yang dibuat. Silakan buat divisi terlebih dahulu.",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.red));
                        }
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          hint: const Text("Pilih Divisi"),
                          value: controller.delegations
                                  .any((d) => d['_id'] == m['delegation_id'])
                              ? m['delegation_id']
                              : null,
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
            const Text("Semua Anggota & Staff",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

  // --- Delegation (Division) Management Cards ---

  Widget _buildDelegationManagementCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.gitBranch,
                      size: 22, color: Colors.blue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Struktur Delegasi / Divisi",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface)),
                      Obx(() => Text(
                            "${controller.delegations.length} divisi aktif",
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.outline),
                          )),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAllDivisionsDialog(context),
                  icon: const Icon(LucideIcons.arrowRight,
                      size: 14, color: AppTheme.primary),
                  label: const Text("Lihat",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Container(
              height: 1,
              color: AppTheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          // Form tambah divisi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.delegationNameController,
                    decoration: InputDecoration(
                      hintText: "Nama Divisi (misal: HRD, IT, Keuangan)",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = controller.delegationNameController.text;
                    if (name.isNotEmpty) {
                      controller.createDelegation(name);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text("Tambah",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Daftar divisi
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Obx(() {
              if (controller.delegations.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text("Belum ada divisi terdaftar.",
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ),
                );
              }
              final previewList = controller.delegations.take(3).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previewList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final d = previewList[index];
                  return _buildDelegationRow(context, d, false);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDelegationRow(
      BuildContext context, Map<String, dynamic> d, bool showMoveIcon) {
    final String id = d['_id'] ?? '';
    final String name = d['name'] ?? '';

    // Cari jumlah anggota pada divisi ini
    final memberCount = controller.members
        .where((m) => m['delegation_id'] == id && m['role'] != 'owner')
        .length;

    return Obx(() {
      final isSelected = controller.selectedDelegationIds.contains(id);
      return InkWell(
        onTap: () => _showDivisionMembersDialog(context, name, id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.05)
                : Colors.grey.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$memberCount anggota",
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.outline),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.edit2,
                        size: 16, color: AppTheme.outline),
                    onPressed: () {
                      final nameController = TextEditingController(text: name);
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text("Ubah Nama Divisi",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: "Nama Baru",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text("Batal",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                final newName = nameController.text.trim();
                                if (newName.isNotEmpty) {
                                  Get.back();
                                  controller.renameDelegation(id, newName);
                                }
                              },
                              child: const Text("Simpan",
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.trash2,
                        size: 16, color: Colors.red),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text("Hapus Divisi?",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          content: Text(
                              "Apakah Anda yakin ingin menghapus divisi '$name'? Semua berkas dan anggota di dalam divisi tersebut akan dialihkan."),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text("Batal",
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.deleteDelegation(id);
                              },
                              child: const Text("Hapus",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  // Panah lihat anggota
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.users,
                        size: 15, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showAllDivisionsDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(LucideIcons.gitMerge, color: Colors.blue),
            const SizedBox(width: 8),
            const Text("Semua Delegasi / Divisi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 450),
          child: Obx(() => ListView.separated(
                shrinkWrap: true,
                itemCount: controller.delegations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final d = controller.delegations[index];
                  return _buildDelegationRow(context, d, false);
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

  // --- Organization Assets Management View (Kop & TTD) ---

  Widget _buildAssetUploadCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.withOpacity(0.15),
                        Colors.deepPurple.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.stamp,
                      size: 22, color: Colors.deepPurple),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Aset Kop & TTD per Divisi",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface)),
                      Obx(() => Text(
                            "${controller.assets.length} aset tersimpan",
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.outline),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Container(
              height: 1,
              color: AppTheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          Obx(() => controller.isUploadingAsset.value
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text("Mengunggah aset...",
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.outline)),
                    ],
                  ),
                ))
              : const SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.12)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, size: 14, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hanya 1 kop dan 1 TTD yang dapat aktif per divisi. Mengaktifkan aset lain akan otomatis menonaktifkan yang sebelumnya.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.deepPurple,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.delegations.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.outlineVariant.withOpacity(0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(LucideIcons.gitBranch,
                          size: 32, color: AppTheme.outlineVariant),
                      SizedBox(height: 8),
                      Text("Belum ada divisi terdaftar",
                          style: TextStyle(
                              color: AppTheme.outline, fontSize: 13)),
                      SizedBox(height: 4),
                      Text(
                          "Buat divisi terlebih dahulu untuk mengelola aset kop & TTD",
                          style: TextStyle(
                              color: AppTheme.outlineVariant, fontSize: 11)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                ...controller.delegations.map((delegation) {
                  final delId = (delegation['_id'] as String?) ?? '';
                  final delName = (delegation['name'] as String?) ?? 'Divisi';

                  final kopAssets = controller.assets
                      .where((a) =>
                          (a['type'] == 'kop' || a['type'] == 'letterhead') &&
                          a['delegation_id'] == delId)
                      .toList();

                  final ttdAssets = controller.assets
                      .where((a) =>
                          (a['type'] == 'ttd' || a['type'] == 'signature') &&
                          a['delegation_id'] == delId)
                      .toList();

                  return _buildDelegationAssetSection(
                      delId, delName, kopAssets, ttdAssets);
                }).toList(),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDelegationAssetSection(
      String delegationId,
      String delegationName,
      List<Map<String, dynamic>> kopAssets,
      List<Map<String, dynamic>> ttdAssets) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.025),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.deepPurple.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.07),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.gitBranch,
                      size: 14, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delegationName,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildSmallUploadBtn(
                    label: '+ Kop',
                    color: Colors.blue,
                    onTap: () => controller.pickAndUploadAssetToDelegation(
                        'kop', delegationId, delegationName),
                  ),
                  const SizedBox(width: 6),
                  _buildSmallUploadBtn(
                    label: '+ TTD',
                    color: Colors.teal,
                    onTap: () => controller.pickAndUploadAssetToDelegation(
                        'ttd', delegationId, delegationName),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAssetSubsection(
                    label: 'Kop Surat',
                    icon: LucideIcons.fileImage,
                    color: Colors.blue,
                    assets: kopAssets,
                    emptyMsg: 'Belum ada kop surat — tekan + Kop untuk upload',
                  ),
                  const SizedBox(height: 10),
                  _buildAssetSubsection(
                    label: 'Tanda Tangan Digital',
                    icon: LucideIcons.penTool,
                    color: Colors.teal,
                    assets: ttdAssets,
                    emptyMsg: 'Belum ada TTD — tekan + TTD untuk upload',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSubsection({
    required String label,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> assets,
    required String emptyMsg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color.withOpacity(0.75)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8)),
            ),
            if (assets.any((a) => a['is_active'] == true)) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '1 aktif',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        if (assets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.12)),
            ),
            child: Text(
              emptyMsg,
              style:
                  TextStyle(fontSize: 11, color: color.withOpacity(0.5)),
            ),
          )
        else
          ...assets.map((asset) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildAssetItemTile(asset, false),
              )),
      ],
    );
  }

  Widget _buildSmallUploadBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _buildAssetItemTile(Map<String, dynamic> asset, bool inSelection) {
    final String id = asset['id'] ?? '';
    final String name = asset['name'] ?? 'Unnamed';
    final String type = asset['asset_type'] ?? asset['type'] ?? '';
    final bool isKop = type == 'kop' || type == 'letterhead';
    final Color color = isKop ? Colors.blue : Colors.teal;
    final IconData icon = isKop ? LucideIcons.fileImage : LucideIcons.penTool;
    final String label = isKop ? 'Kop Surat' : 'TTD Digital';
    final bool isActive = asset['is_active'] ?? true;

    return Obx(() {
      final isSelected = controller.selectedAssetIds.contains(id);
      return InkWell(
        onTap: inSelection
            ? () => controller.toggleAssetSelection(id)
            : () => _showAssetActionsDialog(asset),
        onLongPress:
            !inSelection ? () => controller.toggleSelectionMode() : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.06)
                : color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.4)
                  : color.withOpacity(0.15),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (inSelection)
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: isSelected,
                    activeColor: AppTheme.primary,
                    onChanged: (_) => controller.toggleAssetSelection(id),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withOpacity(0.13)
                                : Colors.grey.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.green[700] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!inSelection) ...[
                const SizedBox(width: 8),
                // Gunakan Wrap responsif agar kebal overflow horizontal
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildIconAction(
                      icon: isActive ? LucideIcons.toggleRight : LucideIcons.toggleLeft,
                      color: isActive ? Colors.green : Colors.grey,
                      tooltip: isActive ? "Nonaktifkan" : "Aktifkan",
                      onTap: () => controller.toggleAssetActivation(id, name, isActive),
                    ),
                    _buildIconAction(
                      icon: LucideIcons.edit2,
                      color: AppTheme.primary,
                      tooltip: "Ubah Nama",
                      onTap: () => controller.updateAssetName(id, name),
                    ),
                    _buildIconAction(
                      icon: LucideIcons.image,
                      color: Colors.teal,
                      tooltip: "Ganti Gambar",
                      onTap: () => controller.updateAssetImage(id, name),
                    ),
                    _buildIconAction(
                      icon: LucideIcons.trash2,
                      color: Colors.red,
                      tooltip: "Hapus",
                      onTap: () => _confirmDeleteAsset(id, name),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }

  void _confirmDeleteAsset(String id, String name) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Aset?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            "Aset '$name' akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAsset(id, name);
            },
            child: const Text("Hapus",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAssetActionsDialog(Map<String, dynamic> asset) {
    final String id = asset['id'] ?? '';
    final String name = asset['name'] ?? '';

    Widget imagePreview;
    try {
      final String? fileUrl =
          asset['file_url'] ?? asset['url'] ?? asset['image_url'];
      final String? b64 =
          asset['image_data'] ?? asset['file_data'] ?? asset['base64'];

      if (fileUrl != null && fileUrl.isNotEmpty) {
        imagePreview = Image.network(fileUrl, height: 200, fit: BoxFit.contain);
      } else if (b64 != null && b64.isNotEmpty) {
        String cleanB64 = b64;
        if (cleanB64.contains(',')) {
          cleanB64 = cleanB64.split(',').last;
        }
        imagePreview = Image.memory(base64Decode(cleanB64),
            height: 200, fit: BoxFit.contain);
      } else {
        imagePreview = const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.imageOff, size: 40, color: Colors.grey),
              SizedBox(height: 12),
              Text("Preview tidak tersedia",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        );
      }
    } catch (e) {
      imagePreview = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 40, color: Colors.red),
            SizedBox(height: 12),
            Text("Gagal memuat preview",
                style: TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ),
      );
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imagePreview,
                ),
              ),
              ListTile(
                leading: Icon(
                  (asset['is_active'] ?? true) ? LucideIcons.toggleRight : LucideIcons.toggleLeft,
                  color: (asset['is_active'] ?? true) ? Colors.green : Colors.grey,
                ),
                title: Text(
                  (asset['is_active'] ?? true) ? "Nonaktifkan Aset" : "Aktifkan Aset",
                  style: TextStyle(
                    color: (asset['is_active'] ?? true) ? Colors.green[700] : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.back();
                  controller.toggleAssetActivation(
                      id, name, asset['is_active'] ?? true);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.edit2, color: AppTheme.primary),
                title: const Text("Ubah Nama"),
                onTap: () {
                  Get.back();
                  controller.updateAssetName(id, name);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: Colors.teal),
                title: const Text("Ganti Gambar"),
                onTap: () {
                  Get.back();
                  controller.updateAssetImage(id, name);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: Colors.red),
                title: const Text("Hapus Aset",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  controller.deleteAsset(id, name);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dialogs: Divisions and Members Moving ---

  void _showDivisionMembersDialog(
      BuildContext context, String divisionName, String divisionId) {
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Obx(() {
            final divisionMembers = controller.members
                .where((m) =>
                    m['delegation_id'] == divisionId && m['role'] != 'owner')
                .toList();

            if (divisionMembers.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('Tidak ada anggota di divisi ini.',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih anggota untuk batch edit atau ketuk ikon untuk pindah:',
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
                          title: Text(m['username'] ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(m['email'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          onChanged: (checked) {
                            if (checked == true) {
                              selectedMemberIds.add(uid);
                            } else {
                              selectedMemberIds.remove(uid);
                            }
                          },
                          secondary: IconButton(
                            icon: const Icon(LucideIcons.gitPullRequest,
                                size: 18, color: AppTheme.primary),
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
                child:
                    const Text('Tutup', style: TextStyle(color: Colors.grey)),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedMemberIds.length} Terpilih',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final idsToMove = selectedMemberIds.toList();
                          Get.back();
                          controller.moveMultipleMembersDelegation(
                              idsToMove, 'general');
                        },
                        child: const Text('Keluarkan',
                            style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final idsToMove = selectedMemberIds.toList();
                          _showBatchMoveDialog(context, idsToMove, divisionId);
                        },
                        child: const Text('Pindahkan',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold)),
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

  void _showMoveSingleMemberDialog(
      BuildContext context, Map<String, dynamic> member) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Pindahkan ${member['username']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih divisi/delegasi tujuan:",
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            Obx(() {
              return DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    Get.back();
                    Get.back();
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

  void _showBatchMoveDialog(
      BuildContext context, List<String> memberIds, String currentDivisionId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Pindahkan ${memberIds.length} Anggota",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                "Pilih divisi/delegasi tujuan baru untuk semua anggota terpilih:",
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            Obx(() {
              return DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text("Pilih Divisi"),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'general',
                    child: Text('Keluar ke General (Tanpa Divisi)'),
                  ),
                  ...controller.delegations
                      .where((d) => d['_id'] != currentDivisionId)
                      .map((d) {
                    return DropdownMenuItem<String>(
                      value: d['_id'],
                      child: Text(d['name'] ?? ''),
                    );
                  }).toList(),
                ],
                onChanged: (val) {
                  if (val != null) {
                    Get.back();
                    Get.back();
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
