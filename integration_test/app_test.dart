import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:ambanotes/main.dart' as app;
import 'package:ambanotes/app/data/services/api_service.dart';
import 'package:ambanotes/app/data/services/notification_service.dart';
import 'package:ambanotes/app/routes/app_pages.dart';
import 'package:ambanotes/app/modules/login/views/login_view.dart';
import 'package:ambanotes/app/modules/register/views/register_view.dart';
import 'package:ambanotes/app/modules/forgot_password/views/forgot_password_view.dart';
import 'package:ambanotes/app/modules/insight/views/insight_view.dart';
import 'package:ambanotes/app/modules/assignment_form/views/assignment_form_view.dart';
import 'package:ambanotes/app/modules/dashboard/views/dashboard_view.dart';

// Highly-fidelity Mock implementation of ApiService for consistent UI testing and screenshotting
class MockApiService extends ApiService {
  @override
  void onInit() {
    // Skip real HTTP interceptors
  }

  @override
  Future<bool> login(String emailInput, String passwordInput) async {
    if (passwordInput == "salah123") {
      Get.snackbar(
        'Login Error',
        'Kredensial salah. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }

    token.value = "mock_token_xyz_123";
    userId.value = "user_bima_123";
    username.value = "Bima Sunu";
    email.value = emailInput;
    role.value = "owner";
    orgId.value = "org_antigravity_01";
    delegationId.value = "del_pu_01";
    delegationName.value = "Dinas Pekerjaan Umum";
    inviteCode.value = "987654";
    googleDriveConnected.value = false;
    return true;
  }

  @override
  Future<bool> register({
    required String usernameInput,
    required String emailInput,
    required String passwordInput,
    required String action,
    String? orgName,
    String? invitationCode,
  }) async {
    if (emailInput == "user@mail.com") {
      Get.snackbar(
        'Registration Error',
        'Email sudah terdaftar di sistem.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }
    return true;
  }

  @override
  Future<bool> forgotPassword(String emailInput) async {
    if (emailInput == "unknown@mail.com") {
      Get.snackbar(
        'Error',
        'Email tidak terdaftar.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return false;
    }
    return true;
  }

  @override
  Future<bool> resetPassword({
    required String emailInput,
    required String otpInput,
    required String newPasswordInput,
  }) async {
    if (otpInput == "000000") {
      Get.snackbar('Error', 'OTP tidak valid',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  @override
  Future<List<dynamic>> getAssets() async {
    return [
      {'id': 'asset_01', 'type': 'letterhead', 'name': 'Kop Dinas PU Tegal'},
      {'id': 'asset_02', 'type': 'signature', 'name': 'Tanda Tangan Kadin'},
    ];
  }

  @override
  Future<Map<String, dynamic>?> generateSuratTugas({
    required String referenceDocId,
    required String letterNumber,
    required String date,
    required String time,
    required String location,
    required String kop,
    String? ttd,
  }) async {
    return {
      'id': 'st_generated_99',
      'letter_number': letterNumber,
      'status': 'success',
      'hash': 'f4a2c918b87e2b17a1092e0388d011ff'
    };
  }

  @override
  Future<List<dynamic>> listDocuments() async {
    return [
      {
        'id': 'doc_01',
        'filename': 'surat_undangan_krenova.pdf',
        'category': 'Undangan',
        'created_at': '2026-05-18T10:00:00Z',
        'text':
            'Surat undangan rapat koordinasi Krenova Kabupaten Tegal di Kantor Bappeda.',
        'entities': {
          'names': ['Bima Sunu', 'Geraldi Novalino'],
          'locations': ['Bappeda Slawi'],
          'organizations': ['Bappeda Tegal'],
          'dates': ['20-05-2026']
        }
      },
      {
        'id': 'doc_02',
        'filename': 'laporan_anggaran_sekretariat.pdf',
        'category': 'Laporan',
        'created_at': '2026-05-19T14:30:00Z',
        'text':
            'Laporan rekapitulasi anggaran belanja secretariat triwulan I sebesar Rp5.000.000.',
        'entities': {
          'names': ['Ir. Budi'],
          'locations': ['Slawi'],
          'organizations': ['Dinas PU'],
          'dates': ['19-05-2026']
        }
      }
    ];
  }

  @override
  Future<List<dynamic>> listReminders() async {
    return [
      {
        'id': 'rem_01',
        'task': 'Rapat koordinasi Krenova',
        'date': '20-05-2026',
        'time': '09:00 WIB',
        'location': 'Ruang Bappeda Slawi',
        'doc_id': 'doc_01'
      },
      {
        'id': 'rem_02',
        'task': 'Laporan Anggaran Dinas PU',
        'date': '22-05-2026',
        'time': '14:00 WIB',
        'location': 'Kantor Dinas PU',
        'doc_id': 'doc_02'
      }
    ];
  }

  @override
  Future<Map<String, dynamic>?> getWeeklySummary() async {
    return {
      'summary':
          'Analisis Mingguan AmbaAI: Terjadi peningkatan volume dokumen administrasi sebesar 15% pada minggu ini. Fokus utama didominasi oleh Surat Undangan koordinasi Krenova Kabupaten Tegal 2026 dan Laporan Anggaran Dinas PU. Seluruh disposisi telah disalurkan dengan rata-rata waktu respons 12 menit.'
    };
  }

  @override
  Future<Map<String, dynamic>?> getPredictiveTrends() async {
    return {
      'average_weekly_load': 4.8,
      'forecast_trend':
          'Meningkat secara signifikan menjelang pelaksanaan Krenova 2026',
      'workload_index': 7.8,
      'stats': {'surat_masuk': 14, 'surat_keluar': 8, 'reminders': 5}
    };
  }

  @override
  Future<Map<String, dynamic>?> getEventInsights() async {
    return {
      'total_posts': 15,
      'top_accounts': {
        'gbikamboja': 10,
        'jpcc': 8,
        'ndc_worship': 7,
        'gms_tegal': 5
      },
      'likes_distribution': {'min': 100, 'max': 1200, 'avg': 642.5},
      'most_active_day': {'Sunday': 8, 'Friday': 4, 'Saturday': 3},
      'event_trends': {
        'Krenova 2026': 9,
        'Rapat Koordinasi': 4,
        'Sosialisasi': 2
      },
      'word_cloud': []
    };
  }
}

class MockNotificationService extends NotificationService {
  @override
  void onInit() {
    // Avoid real initialization of Android notifications
  }

  @override
  Future<void> showNotification(String title, String body,
      {String? payload}) async {
    print('MOCK NOTIFICATION: [$title] - $body');
  }
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Config screenshot capability
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('AmbaNotes End-To-End Integration & Operation Testing', () {
    setUp(() {
      // Injects high-fidelity mock services before app main is launched
      Get.put<ApiService>(MockApiService(), permanent: true);
      Get.put<NotificationService>(MockNotificationService(), permanent: true);
    });

    tearDown(() async {
      await Get.deleteAll(force: true);
    });

    testWidgets('Operational Test Suite - E2E Navigation & Screenshots',
        (WidgetTester tester) async {
      // Helper function to capture screenshot correctly on Android
      Future<void> takeScreenshot(String name) async {
        await binding.takeScreenshot(name);
      }

      // 1. Launch Flutter App main
      app.main();
      await tester.pumpAndSettle();

      if (!kIsWeb && Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
      }

      // ==========================================
      // OP-03: Verify Login Screen & Credentials
      // ==========================================
      expect(find.byType(LoginView), findsOneWidget);

      // Enter invalid credentials for OP-04 test simulation
      await tester.enterText(find.byType(TextField).at(0), 'user@mail.com');
      await tester.enterText(find.byType(TextField).at(1), 'salah123');
      await tester.pumpAndSettle();
      await takeScreenshot('OP_04_Login_Failed_Input');

      // Tap login to trigger OP-04 failed response
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot('OP_04_Login_Failed_Snackbar');

      // Now enter valid credentials for OP-03 Success
      await tester.enterText(find.byType(TextField).at(0), 'bima@mail.com');
      await tester.enterText(find.byType(TextField).at(1), 'Password123');
      await tester.pumpAndSettle();
      await takeScreenshot('OP_03_Login_Success_Input');

      // Trigger login success
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ==========================================
      // OP-53: Verify Dashboard & Today\'s Agenda
      // ==========================================
      expect(find.byType(DashboardView), findsOneWidget);
      await takeScreenshot('OP_53_Reminder_List_Dashboard');

      // ==========================================
      // OP-27: Verify Document Archive List View
      // ==========================================
      // Find files/archive tab on bottom navigation and tap it
      await tester.tap(find.byIcon(LucideIcons.fileText));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot('OP_27_Archive_List_View');

      // ==========================================
      // OP-67: Navigate & Verify Insight Dashboard
      // ==========================================
      // Direct routing navigation to Insight screen
      Get.toNamed(Routes.INSIGHT);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(InsightView), findsOneWidget);
      await takeScreenshot('OP_67_Insight_Dashboard_Success');

      // ==========================================
      // OP-63: Verify Generate Surat Tugas Form
      // ==========================================
      // Directly route to assignment form with mock parameters
      Get.toNamed(
        Routes.ASSIGNMENT_LETTER_FORM,
        arguments: {
          'doc_id': 'doc_01',
          'nomor_surat': '001/ST/2026',
          'organisasi': 'Bappeda Slawi',
          'title': 'Rapat Krenova 2026',
        },
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(AssignmentFormView), findsOneWidget);
      await takeScreenshot('OP_63_Generate_Surat_Tugas_Form');

      // Input time and date mock clicks (close pickers safely or mock direct fields if necessary)
      // Since it requires clicking pickers, let\'s tap generate to verify negative test OP-64
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot('OP_64_Generate_Failed_Empty_Fields');

      // Back out to Profile page to test Logout
      Get.offAllNamed(Routes.DASHBOARD);
      await tester.pumpAndSettle();

      // Tap Profile navigation tab
      await tester.tap(find.byIcon(LucideIcons.user));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot('OP_05_Logout_Page_Ready');

      // ==========================================
      // OP-09: Verify Forgot Password Navigation
      // ==========================================
      // Navigate back to Login and go to Forgot Password Page
      Get.offAllNamed(Routes.LOGIN);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap forgot password text button
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(ForgotPasswordView), findsOneWidget);
      await takeScreenshot('OP_09_Forgot_Password_View');

      // ==========================================
      // OP-01: Verify Register User Setup Steps
      // ==========================================
      // Go back to login and navigate to Register View
      Get.back();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(RegisterView), findsOneWidget);
      await takeScreenshot('OP_01_Register_Step1_UserInfo');

      // Fill in user registration information
      await tester.enterText(find.byType(TextField).at(0), 'Bima Sunu');
      await tester.enterText(find.byType(TextField).at(1), 'bima@mail.com');
      await tester.enterText(find.byType(TextField).at(2), 'Password123');
      await tester.pumpAndSettle();

      // Tap Continue to Step 2 (Organization Setup)
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await takeScreenshot('OP_01_Register_Step2_OrgSetup');

      print(
          'AmbaNotes Integration Test & Auto Screenshot executed successfully!');
    });
  });
}
