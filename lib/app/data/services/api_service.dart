import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiService extends GetxService {
  // Using local computer IP address so both Android Emulator AND physical phones can access it
  final baseUrl = 'https://notes.bimazznxt.my.id'.obs;

  final token = RxnString();
  final userId = RxnString();
  final username = RxnString();
  final email = RxnString();
  final role = RxnString();
  final orgId = RxnString();
  final delegationId = RxnString();
  final delegationName = RxnString();
  final googleDriveConnected = false.obs;

  bool get isAuthenticated => token.value != null;
  bool get isOwner => role.value == 'owner';

  final GetConnect _connect = GetConnect();

  @override
  void onInit() {
    super.onInit();
    // Configure GetConnect
    _connect.timeout = const Duration(seconds: 30);

    // Add request interceptor to inject JWT token automatically
    _connect.httpClient.addRequestModifier<dynamic>((request) {
      if (token.value != null) {
        request.headers['Authorization'] = 'Bearer ${token.value}';
      }
      return request;
    });
  }

  // --- Core API Helper Methods ---

  Future<Response> _get(String path) async {
    final url = '${baseUrl.value}$path';
    return await _connect.get(url);
  }

  Future<Response> _post(String path, dynamic body) async {
    final url = '${baseUrl.value}$path';
    return await _connect.post(url, body);
  }

  Future<Response> _delete(String path) async {
    final url = '${baseUrl.value}$path';
    return await _connect.delete(url);
  }

  // --- Auth Service Endpoints ---

  Future<bool> login(String emailInput, String passwordInput) async {
    try {
      final response = await _post('/auth/login', {
        'email': emailInput,
        'password': passwordInput,
      });

      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        token.value = body['token'];

        final user = body['user'];
        userId.value = user['id'];
        username.value = user['username'];
        email.value = user['email'];
        role.value = user['role'];
        orgId.value = user['org_id'];
        delegationId.value = user['delegation_id'];

        await getProfile(); // Load detailed profile
        return true;
      } else {
        String errMsg = response.body?['error'] ?? 'Login failed';
        Get.snackbar('Login Error', errMsg,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Cannot connect to backend server: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> register({
    required String usernameInput,
    required String emailInput,
    required String passwordInput,
    required String action,
    String? orgName,
  }) async {
    try {
      final payload = {
        'username': usernameInput,
        'email': emailInput,
        'password': passwordInput,
        'action': action,
      };
      if (orgName != null && orgName.isNotEmpty) {
        payload['org_name'] = orgName;
      }

      final response = await _post('/auth/register', payload);

      if (response.statusCode == 201) {
        Get.snackbar('Registration Success',
            'User registered successfully. Please login.',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        String errMsg = response.body?['error'] ?? 'Registration failed';
        Get.snackbar('Registration Error', errMsg,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Cannot connect to backend server: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> getProfile() async {
    if (token.value == null) return;
    try {
      final response = await _get('/auth/profile');
      if (response.statusCode == 200 && response.body != null) {
        final body = response.body;
        username.value = body['username'];
        email.value = body['email'];
        role.value = body['role'];
        orgId.value = body['org_id'];
        delegationId.value = body['delegation_id'];
        delegationName.value = body['delegation_name'] ?? 'General';
        googleDriveConnected.value = body['google_drive_connected'] == true;
      }
    } catch (e) {
      print("Get profile error: $e");
    }
  }

  Future<List<dynamic>> getDelegations() async {
    try {
      final response = await _get('/auth/delegations');
      if (response.statusCode == 200) {
        return response.body as List<dynamic>;
      }
    } catch (e) {
      print("Get delegations error: $e");
    }
    return [];
  }

  Future<bool> createDelegation(String name) async {
    try {
      final response = await _post('/auth/delegations', {'name': name});
      return response.statusCode == 201;
    } catch (e) {
      print("Create delegation error: $e");
      return false;
    }
  }

  Future<bool> changeDelegation(
      String targetUserId, String newDelegationId) async {
    try {
      final response = await _post('/auth/change-delegation', {
        'target_user_id': targetUserId,
        'new_delegation_id': newDelegationId,
      });
      return response.statusCode == 200;
    } catch (e) {
      print("Change delegation error: $e");
      return false;
    }
  }

  Future<bool> inviteMember(String emailInput, String roleInput) async {
    try {
      final response = await _post('/auth/invite', {
        'email': emailInput,
        'role': roleInput,
      });
      if (response.statusCode == 201) {
        return true;
      } else {
        String errMsg = response.body?['error'] ?? 'Gagal mengirim undangan.';
        Get.snackbar(
          'Gagal Mengirim',
          errMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Kesalahan Jaringan',
        'Gagal menghubungi server: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String emailInput) async {
    try {
      final response = await _post('/auth/forgot-password', {
        'email': emailInput,
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        String errMsg = response.body?['error'] ?? 'Gagal meminta OTP';
        Get.snackbar('Error', errMsg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Gagal terhubung ke server: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String emailInput,
    required String otpInput,
    required String newPasswordInput,
  }) async {
    try {
      final response = await _post('/auth/reset-password', {
        'email': emailInput,
        'otp': otpInput,
        'new_password': newPasswordInput,
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        String errMsg = response.body?['error'] ?? 'Gagal mereset kata sandi';
        Get.snackbar('Error', errMsg, snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Gagal terhubung ke server: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<List<dynamic>> getOrganizationMembers() async {
    try {
      final response = await _get('/auth/members');
      if (response.statusCode == 200) {
        return response.body as List<dynamic>;
      }
    } catch (e) {
      print("Get organization members error: $e");
    }
    return [];
  }

  Future<bool> uploadAsset(
      String assetType, String targetDelegationId, String base64Image) async {
    try {
      final response = await _post('/auth/assets', {
        'type': assetType,
        'delegation_id': targetDelegationId,
        'image_data': base64Image,
      });
      return response.statusCode == 201;
    } catch (e) {
      print("Upload asset error: $e");
      return false;
    }
  }

  Future<String?> getGoogleConnectUrl() async {
    try {
      final response = await _get('/auth/google/connect');
      if (response.statusCode == 200 && response.body != null) {
        return response.body['auth_url'];
      }
    } catch (e) {
      print("Google connect error: $e");
    }
    return null;
  }

  Future<bool> disconnectGoogleDrive() async {
    try {
      final response = await _post('/auth/google/disconnect', {});
      if (response.statusCode == 200) {
        googleDriveConnected.value = false;
        return true;
      }
    } catch (e) {
      print("Google disconnect error: $e");
    }
    return false;
  }

  // --- Document Service Endpoints ---

  Future<Map<String, dynamic>?> uploadDocument(
      List<int> bytes, String filename) async {
    try {
      String contentType = 'image/jpeg'; // default for camera scans
      final lower = filename.toLowerCase();
      if (lower.endsWith('.png')) {
        contentType = 'image/png';
      } else if (lower.endsWith('.webp')) {
        contentType = 'image/webp';
      } else if (lower.endsWith('.pdf')) {
        contentType = 'application/pdf';
      }

      final form = FormData({
        'file': MultipartFile(bytes, filename: filename, contentType: contentType),
      });

      final response = await _post('/document/upload', form);

      if (response.statusCode == 201 && response.body != null) {
        return response.body as Map<String, dynamic>;
      } else {
        String errMsg = response.body?['error'] ?? 'Upload failed';
        Get.snackbar('Upload Error', errMsg,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Network Error', 'Cannot upload file: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
    return null;
  }

  Future<List<dynamic>> listDocuments() async {
    try {
      final response = await _get('/document/list');
      if (response.statusCode == 200) {
        return response.body as List<dynamic>;
      }
    } catch (e) {
      print("List documents error: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getDocumentDetail(String docId) async {
    try {
      final response = await _get('/document/$docId');
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Get document detail error: $e");
    }
    return null;
  }

  Future<bool> deleteDocument(String docId) async {
    try {
      final response = await _delete('/document/$docId');
      return response.statusCode == 200;
    } catch (e) {
      print("Delete document error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> replaceDocument(String docId,
      {List<int>? bytes, String? filename, String? text}) async {
    try {
      dynamic payload;
      if (bytes != null && filename != null) {
        String contentType = 'image/jpeg';
        final lower = filename.toLowerCase();
        if (lower.endsWith('.png')) {
          contentType = 'image/png';
        } else if (lower.endsWith('.webp')) {
          contentType = 'image/webp';
        } else if (lower.endsWith('.pdf')) {
          contentType = 'application/pdf';
        }

        payload = FormData({
          'file': MultipartFile(bytes, filename: filename, contentType: contentType),
        });
      } else if (text != null) {
        payload = {'text': text};
      } else {
        return null;
      }

      final response = await _post('/document/replace/$docId', payload);
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Replace document error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> migrateToDrive() async {
    try {
      final response = await _post('/document/migrate-to-drive', {
        'user_id': userId.value,
      });
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Migrate error: $e");
    }
    return null;
  }

  // --- Reminder Service Endpoints ---

  Future<List<dynamic>> listReminders() async {
    try {
      final response = await _get('/reminder/');
      if (response.statusCode == 200) {
        return response.body as List<dynamic>;
      }
    } catch (e) {
      print("List reminders error: $e");
    }
    return [];
  }

  Future<bool> createReminder({
    required String task,
    required String date,
    String? time,
    String? location,
    String? docId,
  }) async {
    try {
      final response = await _post('/reminder/', {
        'task': task,
        'date': date,
        'time': time ?? '',
        'location': location ?? '',
        'doc_id': docId ?? '',
      });
      return response.statusCode == 201;
    } catch (e) {
      print("Create reminder error: $e");
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      final response = await _delete('/reminder/$id');
      return response.statusCode == 200;
    } catch (e) {
      print("Delete reminder error: $e");
      return false;
    }
  }

  // --- AI Service Endpoints ---

  Future<String?> summarizeDocument(String text) async {
    try {
      final response = await _post('/ai/summarize', {'text': text});
      if (response.statusCode == 200) {
        return response.body['summary'];
      }
    } catch (e) {
      print("Summarize error: $e");
    }
    return null;
  }

  Future<String?> chat(String message, String context, {List<Map<String, dynamic>>? history}) async {
    try {
      final response = await _post('/ai/chat', {
        'message': message,
        'context': context,
        'history': history ?? [],
      });
      if (response.statusCode == 200) {
        return response.body['answer'];
      }
    } catch (e) {
      print("Chat error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> chatGlobal(String message, {List<Map<String, dynamic>>? history}) async {
    try {
      final response = await _post('/ai/chat-global', {
        'message': message,
        'history': history ?? [],
      });
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Chat global error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> generateReply(String text) async {
    try {
      final response = await _post('/ai/generate-reply', {'text': text});
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Generate reply error: $e");
    }
    return null;
  }

  Future<List<dynamic>> extractTasks(String text) async {
    try {
      final response = await _post('/ai/extract-tasks', {'text': text});
      if (response.statusCode == 200) {
        return response.body as List<dynamic>;
      }
    } catch (e) {
      print("Extract tasks error: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> suggestDisposition(
      String text, List<String> delegations) async {
    try {
      final response = await _post('/ai/suggest-disposition', {
        'text': text,
        'delegations': delegations,
      });
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Suggest disposition error: $e");
    }
    return null;
  }

  Future<List<dynamic>> semanticSearch(String query) async {
    try {
      final response = await _post('/ai/semantic-search', {'query': query});
      if (response.statusCode == 200) {
        return response.body as List<dynamic>;
      }
    } catch (e) {
      print("Semantic search error: $e");
    }
    return [];
  }

  // --- Insight Service Endpoints ---

  Future<Map<String, dynamic>?> getWeeklySummary() async {
    try {
      final response = await _get('/insight/weekly-summary');
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Get weekly summary error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPredictiveTrends() async {
    try {
      final response = await _get('/insight/predictive-trends');
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Get predictive trends error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getEventInsights() async {
    try {
      final response = await _get('/insight/api/insights');
      if (response.statusCode == 200) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Get event insights error: $e");
    }
    return null;
  }

  // --- Generator Service Endpoints ---

  Future<Map<String, dynamic>?> generateSuratTugas({
    required String referenceDocId,
    required String letterNumber,
    required String date,
    required String time,
    required String location,
    required String kop,
    String? ttd,
  }) async {
    try {
      final response = await _post('/generator/surat-tugas', {
        'reference_doc_id': referenceDocId,
        'letter_number': letterNumber,
        'date': date,
        'time': time,
        'location': location,
        'kop': kop,
        'ttd': ttd ?? '',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body as Map<String, dynamic>;
      }
    } catch (e) {
      print("Generate surat tugas error: $e");
    }
    return null;
  }

  void logout() {
    token.value = null;
    userId.value = null;
    username.value = null;
    email.value = null;
    role.value = null;
    orgId.value = null;
    delegationId.value = null;
    delegationName.value = null;
    googleDriveConnected.value = false;
  }
}
