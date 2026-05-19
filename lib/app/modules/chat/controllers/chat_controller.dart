import 'package:get/get.dart';
import '../../../data/services/api_service.dart';

class ChatMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final List<dynamic>? references; // List of {'doc_id': ..., 'filename': ...}

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.references,
  });
}

class ChatController extends GetxController {
  final apiService = Get.find<ApiService>();
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;

  String? documentContextText;
  String? documentTitle;

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
        documentTitle = args['documentTitle'];
        documentContextText = args['documentSummary'];
        
        // Provide an intro message from AI about the document
        Future.delayed(const Duration(milliseconds: 500), () {
          messages.add(ChatMessage(
            id: DateTime.now().toString(),
            sender: 'ai',
            content: "I see you are viewing the document '$documentTitle'. Ask me anything about it!",
            timestamp: DateTime.now(),
          ));
        });
      }
    }
  }

  void loadWelcomeMessages() {
    if (Get.arguments != null) return; // Don't show generic welcome on contextual document chat
    messages.assignAll([
      ChatMessage(
        id: 'welcome_ai',
        sender: 'ai',
        content: "Halo! Saya adalah AmbaAI, asisten sekretariat Anda. Anda bisa menanyakan apa saja mengenai arsip surat dan dokumen organisasi Anda. Coba tanyakan: 'Apakah ada kontrak yang hampir habis?' atau 'Tolong carikan surat tugas untuk dinas luar negeri.'",
        timestamp: DateTime.now(),
      ),
    ]);
  }

  void sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      sender: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
    messages.add(userMsg);
    
    isTyping.value = true;
    try {
      if (documentContextText != null) {
        final answer = await apiService.chat(content, documentContextText!);
        isTyping.value = false;
        messages.add(ChatMessage(
          id: DateTime.now().toString(),
          sender: 'ai',
          content: answer ?? 'Maaf, saya tidak dapat menganalisis dokumen ini sekarang.',
          timestamp: DateTime.now(),
        ));
      } else {
        final response = await apiService.chatGlobal(content);
        isTyping.value = false;
        if (response != null) {
          final answer = response['answer'] ?? "No response.";
          final refs = response['references'] as List<dynamic>?;
          messages.add(ChatMessage(
            id: DateTime.now().toString(),
            sender: 'ai',
            content: answer,
            timestamp: DateTime.now(),
            references: refs,
          ));
        } else {
          messages.add(ChatMessage(
            id: DateTime.now().toString(),
            sender: 'ai',
            content: 'Error menghubungi server. Silakan coba lagi.',
            timestamp: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      isTyping.value = false;
      print("Chat error: $e");
    }
  }
}
