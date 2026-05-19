import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/data/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ApiService globally
  Get.put(ApiService(), permanent: true);

  // 1. Set system UI preferences
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // For light status bar
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness:
        Brightness.dark, // For dark nav bar icons
  ));

  runApp(
    GetMaterialApp(
      title: "AmbaNotes",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      defaultTransition: Transition.fade,
    ),
  );
}
