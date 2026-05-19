import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'references': references,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    sender: json['sender'] ?? '',
    content: json['content'] ?? '',
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    references: json['references'],
  );
}

class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final String? documentTitle;
  final String? documentContextText;
  final DateTime timestamp;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    this.documentTitle,
    this.documentContextText,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'documentTitle': documentTitle,
    'documentContextText': documentContextText,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] ?? '',
    title: json['title'] ?? 'New Chat',
    messages: (json['messages'] as List<dynamic>?)
            ?.map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
            .toList() ?? [],
    documentTitle: json['documentTitle'],
    documentContextText: json['documentContextText'],
    timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
  );
}

class ChatController extends GetxController {
  final apiService = Get.find<ApiService>();
  final _storage = GetStorage();

  final sessions = <ChatSession>[].obs;
  final currentSession = Rxn<ChatSession>();
  final messages = <ChatMessage>[].obs;
  final isTyping = false.obs;
  final inputOffset = 0.0.obs;

  final FlutterTts flutterTts = FlutterTts();
  final speakingMsgId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessionsFromStorage();
    _checkArguments();
    _initTts();
  }

  void _initTts() {
    try {
      flutterTts.setLanguage("id-ID");
      flutterTts.setCompletionHandler(() {
        speakingMsgId.value = '';
      });
      flutterTts.setErrorHandler((msg) {
        speakingMsgId.value = '';
      });
    } catch (e) {
      print("TTS init error: $e");
    }
  }

  void speakMessage(String text, String msgId) async {
    print("speakMessage called for msgId: $msgId, text length: ${text.length}");
    try {
      if (speakingMsgId.value == msgId) {
        print("Stopping TTS speaking");
        await flutterTts.stop();
        speakingMsgId.value = '';
      } else {
        print("Stopping previous TTS speaking and starting new one");
        await flutterTts.stop();
        speakingMsgId.value = msgId;
        // Clean up markdown markers so the voice speaks clean sentences
        final cleanText = text.replaceAll(RegExp(r'\*|_|#|`|\[|\]|\(|\)'), '');
        print("Speaking clean text: $cleanText");
        var result = await flutterTts.speak(cleanText);
        print("TTS speak result: $result");
      }
    } catch (e, stack) {
      print("Error in speakMessage: $e");
      print(stack);
      speakingMsgId.value = '';
      Get.snackbar(
        "Kesalahan TTS",
        "Gagal memutar audio. Mohon stop dan run ulang aplikasi (rebuild native plugin) agar fitur Text to Speech dapat diakses.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }

  void loadSessionsFromStorage() {
    try {
      final List<dynamic>? stored = _storage.read<List<dynamic>>('chat_sessions');
      if (stored != null) {
        final loaded = stored.map((s) => ChatSession.fromJson(Map<String, dynamic>.from(s))).toList();
        sessions.assignAll(loaded);
      }
    } catch (e) {
      print("Error loading chat sessions: $e");
    }
  }

  void saveSessionsToStorage() {
    try {
      final List<Map<String, dynamic>> raw = sessions.map((s) => s.toJson()).toList();
      _storage.write('chat_sessions', raw);
    } catch (e) {
      print("Error saving chat sessions: $e");
    }
  }

  void _checkArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args['context'] == 'document') {
        final docTitle = args['documentTitle'];
        final docSummary = args['documentSummary'];
        
        // Cek jika sudah ada sesi aktif dengan konteks dokumen yang sama
        final existingSession = sessions.firstWhereOrNull(
          (s) => s.documentTitle == docTitle && s.documentContextText == docSummary
        );
        
        if (existingSession != null) {
          selectSession(existingSession);
        } else {
          // Buat sesi baru dengan konteks dokumen tersebut
          createNewSession(
            title: docTitle ?? 'Tanya Dokumen',
            docTitle: docTitle,
            docSummary: docSummary,
          );
        }
      }
    } else {
      // Alur standar: jika sesi kosong, buat sesi baru. Jika tidak, pilih sesi pertama
      if (sessions.isEmpty) {
        createNewSession();
      } else if (currentSession.value == null) {
        selectSession(sessions.first);
      }
    }
  }

  void createNewSession({
    String title = 'Percakapan Baru',
    String? docTitle,
    String? docSummary,
  }) {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      documentTitle: docTitle,
      documentContextText: docSummary,
      timestamp: DateTime.now(),
    );

    if (docTitle == null) {
      newSession.messages.add(ChatMessage(
        id: 'welcome_${newSession.id}',
        sender: 'ai',
        content: "Halo! Saya adalah AmbaAI, asisten sekretariat Anda. Anda bisa menanyakan apa saja mengenai arsip surat dan dokumen organisasi Anda. Coba tanyakan: 'Apakah ada kontrak yang hampir habis?' atau 'Tolong carikan surat tugas untuk dinas luar negeri.'",
        timestamp: DateTime.now(),
      ));
    } else {
      newSession.messages.add(ChatMessage(
        id: 'welcome_${newSession.id}',
        sender: 'ai',
        content: "Saya melihat Anda sedang membuka dokumen '$docTitle'. Tanyakan apa saja mengenai dokumen ini!",
        timestamp: DateTime.now(),
      ));
    }

    sessions.insert(0, newSession);
    saveSessionsToStorage();
    selectSession(newSession);
  }

  void selectSession(ChatSession session) {
    currentSession.value = session;
    messages.assignAll(session.messages);
  }

  void deleteSession(ChatSession session) {
    sessions.remove(session);
    saveSessionsToStorage();
    
    if (currentSession.value?.id == session.id) {
      if (sessions.isNotEmpty) {
        selectSession(sessions.first);
      } else {
        createNewSession();
      }
    }
  }

  void sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    final activeSession = currentSession.value;
    if (activeSession == null) return;
    
    // Ubah nama sesi jika ini adalah pesan pertama dari user
    final firstUserMsg = !activeSession.messages.any((m) => m.sender == 'user');
    if (firstUserMsg) {
      activeSession.title = content.length > 25 ? '${content.substring(0, 22)}...' : content;
      sessions.refresh();
    }

    // Ekstrak histori chat sebelum ditambahkan pesan baru dari user
    final historyPayload = activeSession.messages.map((m) => {
      'sender': m.sender,
      'content': m.content,
    }).toList();

    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      sender: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
    
    activeSession.messages.add(userMsg);
    messages.add(userMsg);
    saveSessionsToStorage();
    
    isTyping.value = true;
    try {
      if (activeSession.documentContextText != null) {
        final answer = await apiService.chat(content, activeSession.documentContextText!, history: historyPayload);
        isTyping.value = false;
        final aiMsg = ChatMessage(
          id: DateTime.now().toString(),
          sender: 'ai',
          content: answer ?? 'Maaf, saya tidak dapat menganalisis dokumen ini sekarang.',
          timestamp: DateTime.now(),
        );
        activeSession.messages.add(aiMsg);
        messages.add(aiMsg);
      } else {
        final response = await apiService.chatGlobal(content, history: historyPayload);
        isTyping.value = false;
        if (response != null) {
          final answer = response['answer'] ?? "No response.";
          final refs = response['references'] as List<dynamic>?;
          final aiMsg = ChatMessage(
            id: DateTime.now().toString(),
            sender: 'ai',
            content: answer,
            timestamp: DateTime.now(),
            references: refs,
          );
          activeSession.messages.add(aiMsg);
          messages.add(aiMsg);
        } else {
          final aiMsg = ChatMessage(
            id: DateTime.now().toString(),
            sender: 'ai',
            content: 'Error menghubungi server. Silakan coba lagi.',
            timestamp: DateTime.now(),
          );
          activeSession.messages.add(aiMsg);
          messages.add(aiMsg);
        }
      }
      saveSessionsToStorage();
      sessions.refresh();
    } catch (e) {
      isTyping.value = false;
      print("Chat error: $e");
    }
  }
}
