import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/data/services/api_service.dart';
import 'app/data/services/backup_registry_service.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Core Services globally
  Get.put(ApiService(), permanent: true);
  Get.put(BackupRegistryService(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  await Get.putAsync<ThemeService>(() async => ThemeService().init(),
      permanent: true);

  // 1. Set system UI preferences
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AmbaNotesApp());
}

class AmbaNotesApp extends GetView<ThemeService> {
  const AmbaNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: "AmbaNotes",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: controller.themeMode,
        defaultTransition: Transition.fade,
      ),
    );
  }
}
