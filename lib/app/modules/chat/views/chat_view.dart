import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/chat_controller.dart';
import 'package:ambanotes/app/widgets/custom_bottom_navbar.dart';
import 'package:ambanotes/app/data/models/models.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      appBar: AppBar(
        title: const Text("Ask AmbaAI"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: "Buka Histori Chat",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: AppTheme.primary),
            onPressed: () => controller.createNewSession(),
            tooltip: "Mulai Chat Baru",
          ),
        ],
      ),
      drawer: _buildHistoryDrawer(context),
      body: Column(
        children: [
          Obx(() {
            final activeSession = controller.currentSession.value;
            if (activeSession != null && activeSession.documentTitle != null) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppTheme.aiSoft.withOpacity(0.5),
                child: Row(
                  children: [
                    const Icon(LucideIcons.fileText, size: 16, color: AppTheme.aiAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Konteks Dokumen: ${activeSession.documentTitle}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.aiAccent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.createNewSession(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.aiAccent.withOpacity(0.3)),
                        ),
                        child: const Text(
                          "Bersihkan",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.aiAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              final showTyping = controller.isTyping.value;
              final count = msgs.length + (showTyping ? 1 : 0);
              
              if (msgs.isEmpty && !showTyping) {
                return _buildEmptyState();
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                reverse: false,
                itemCount: count,
                itemBuilder: (context, index) {
                  if (index == msgs.length) {
                    return _buildTypingIndicator();
                  }
                  final msg = msgs[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),
          _buildChatInput(textController),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.aiSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.sparkles, size: 40, color: AppTheme.aiAccent),
          ),
          const SizedBox(height: 16),
          const Text(
            "Tanyakan apa saja kepada AmbaAI",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            "Mulai mengetik di bawah untuk memulai percakapan.",
            style: TextStyle(fontSize: 13, color: AppTheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                bottom: BorderSide(color: AppTheme.outlineVariant, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "AmbaAI Chat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Histori Percakapan Asisten AI",
                  style: TextStyle(fontSize: 12, color: AppTheme.outline),
                ),
              ],
            ),
          ),

          // New Chat Button inside Drawer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text(
                  "Percakapan Baru",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.back(); // close drawer
                  controller.createNewSession();
                },
              ),
            ),
          ),

          const Divider(height: 1),

          // Chat History List
          Expanded(
            child: Obx(() {
              final activeSession = controller.currentSession.value;
              final list = controller.sessions;
              
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada histori.",
                    style: TextStyle(fontSize: 13, color: AppTheme.outline),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final session = list[index];
                  final isSelected = activeSession?.id == session.id;
                  final isContextual = session.documentTitle != null;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Icon(
                        isContextual ? LucideIcons.sparkles : LucideIcons.messageSquare,
                        size: 18,
                        color: isSelected 
                            ? AppTheme.primary 
                            : (isContextual ? AppTheme.aiAccent : AppTheme.secondary),
                      ),
                      title: Text(
                        session.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primary : AppTheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: isContextual
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.fileText, size: 10, color: AppTheme.outline),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      session.documentTitle!,
                                      style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.grey),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text("Hapus Chat?", style: TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text("Apakah Anda yakin ingin menghapus percakapan ini dari histori?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.deleteSession(session);
                                  },
                                  child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        controller.selectSession(session);
                        Get.back(); // close drawer
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.aiSoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.aiAccent.withOpacity(0.1)),
              ),
              child: const Icon(LucideIcons.sparkles,
                  size: 16, color: AppTheme.aiAccent),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primary
                    : AppTheme.secondaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 24),
                ),
                boxShadow: isUser
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: msg.content,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isUser ? Colors.white : AppTheme.onSurface,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.white : AppTheme.onSurface,
                      ),
                      em: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: isUser ? Colors.white : AppTheme.onSurface,
                      ),
                      listBullet: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : AppTheme.onSurface,
                      ),
                      listBulletPadding: const EdgeInsets.only(right: 6, top: 3),
                      h1: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUser ? Colors.white : AppTheme.onSurface),
                      h2: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isUser ? Colors.white : AppTheme.onSurface),
                      h3: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isUser ? Colors.white : AppTheme.onSurface),
                    ),
                  ),
                  if (!isUser && msg.references != null && msg.references!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 12),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(LucideIcons.bookmark, size: 12, color: AppTheme.aiAccent),
                        SizedBox(width: 4),
                        Text('Referensi Dokumen:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.aiAccent)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: msg.references!.map<Widget>((ref) {
                        final filename = ref['filename'] ?? 'Dokumen';
                        return ActionChip(
                          avatar: const Icon(LucideIcons.fileText, size: 12, color: AppTheme.primary),
                          label: Text(
                            filename.toString().length > 25 
                                ? '${filename.toString().substring(0, 22)}...' 
                                : filename.toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          side: const BorderSide(color: AppTheme.outlineVariant),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onPressed: () {
                            // Construct shell document so detail screen can load it by ID
                            final doc = Document(
                              id: ref['doc_id'] ?? '',
                              title: filename,
                              summary: 'Loading details...',
                              status: 'processed',
                              type: 'Document',
                              archivedDate: 'Just now',
                              size: '1.2 MB',
                            );
                            Get.toNamed('/archive-detail', arguments: doc);
                          },
                        );
                      }).toList(),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.aiSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.aiAccent.withOpacity(0.1)),
            ),
            child: const Icon(LucideIcons.sparkles, size: 16, color: AppTheme.aiAccent),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const SizedBox(
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(radius: 2, backgroundColor: AppTheme.outline),
                  CircleAvatar(radius: 2, backgroundColor: AppTheme.outline),
                  CircleAvatar(radius: 2, backgroundColor: AppTheme.outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(TextEditingController textController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.surface.withOpacity(0.8),
            AppTheme.surface
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuggestionChips(textController),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border:
                  Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.paperclip,
                      color: AppTheme.secondary),
                  onPressed: () {},
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: "Tanyakan apa saja ke AmbaAI...",
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      maxLines: 5,
                      minLines: 1,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.send,
                        color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    controller.sendMessage(textController.text);
                    textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(TextEditingController textController) {
    final chips = [
      {'label': 'Cari undangan masuk', 'icon': LucideIcons.search},
      {'label': 'Apakah ada kontrak yang habis?', 'icon': LucideIcons.clock},
      {'label': 'Tolong ringkas dokumen terbaru', 'icon': LucideIcons.fileEdit},
    ];
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        itemBuilder: (context, index) {
          final chip = chips[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(chip['icon'] as IconData,
                  size: 14, color: AppTheme.primary),
              label: Text(
                chip['label'] as String,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary),
              ),
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppTheme.outlineVariant),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                textController.text = chip['label'] as String;
              },
            ),
          );
        },
      ),
    );
  }
}
