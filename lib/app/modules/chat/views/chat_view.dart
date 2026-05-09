import 'package:ambanotes/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text("AmbaAI"),
      ),
      body: Column(
        children: [
          _buildChatTabs(),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(20),
                  reverse: false,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    return _buildMessageBubble(msg);
                  },
                )),
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
              child: Text(
                msg.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isUser ? Colors.white : AppTheme.onSurface,
                ),
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
          _buildSuggestionChips(),
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

  Widget _buildSuggestionChips() {
    final chips = [
      {'label': 'Find invitation', 'icon': LucideIcons.search},
      {'label': 'Contracts expiring', 'icon': LucideIcons.clock},
      {'label': 'Create memo', 'icon': LucideIcons.fileEdit},
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
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
