import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
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
        title: const Text("AmbaAI"),
      ),
      body: Column(
        children: [
          _buildChatTabs(),
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              final showTyping = controller.isTyping.value;
              final count = msgs.length + (showTyping ? 1 : 0);
              
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

  Widget _buildChatTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom:
                BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("Chat",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.outline)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppTheme.primary, width: 2)),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.sparkles,
                          size: 16, color: AppTheme.aiAccent),
                      SizedBox(width: 8),
                      Text("Ask AmbaAI",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary)),
                    ],
                  ),
                ),
              ),
            ),
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
                  Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isUser ? Colors.white : AppTheme.onSurface,
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
                        hintText: "Ask AmbaAI anything...",
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
