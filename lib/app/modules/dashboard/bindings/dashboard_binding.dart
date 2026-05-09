import 'package:get/get.dart';
import 'package:ambanotes/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:ambanotes/app/modules/home/controllers/home_controller.dart';
import 'package:ambanotes/app/modules/archive/controllers/archive_controller.dart';
import 'package:ambanotes/app/modules/chat/controllers/chat_controller.dart';
import 'package:ambanotes/app/modules/profile/controllers/profile_controller.dart';
import 'package:ambanotes/app/modules/add/controllers/add_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ArchiveController>(() => ArchiveController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<AddController>(() => AddController());
  }
}
