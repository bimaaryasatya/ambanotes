import 'package:get/get.dart';

class ChatMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWelcomeMessages();
    _checkArguments();
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args['context'] == 'document') {
        final title = args['documentTitle'];
        // Provide an intro message from AI about the document
        Future.delayed(const Duration(milliseconds: 500), () {
          messages.add(ChatMessage(
            id: DateTime.now().toString(),
            sender: 'ai',
            content: "I see you are viewing the document '$title'. What would you like to know about it?",
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  void loadWelcomeMessages() {
    messages.assignAll([
      ChatMessage(
        id: '1',
        sender: 'user',
        content: 'Can you summarize the Q3 Secretariat Report and highlight any expiring contracts?',
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        id: '2',
        sender: 'ai',
        content: "I've reviewed the Q3 Secretariat Report. Budget utilization is at 82%, and you have a vendor agreement with AlphaCorp expiring in 12 days.",
        timestamp: DateTime.now(),
      ),
    ]);
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty) return;
    
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      sender: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
    messages.add(userMsg);
    
    // AI Response simulation
    isTyping.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      final aiMsg = ChatMessage(
        id: DateTime.now().toString(),
        sender: 'ai',
        content: "I've analyzed your request. I found two documents matching your query in the Q3 reports. Would you like me to summarize them?",
        timestamp: DateTime.now(),
      );
      messages.add(aiMsg);
      isTyping.value = false;
    });
  }
}
