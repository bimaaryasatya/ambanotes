import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/api_service.dart';

class SplashController extends GetxController {
  final apiService = Get.find<ApiService>();

  @override
  void onReady() {
    super.onReady();
    _startNavigation();
  }

  void _startNavigation() async {
    // Elegant delay for branding presentation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (apiService.isAuthenticated) {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
