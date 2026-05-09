import 'package:get/get.dart';
import 'package:ambanotes/app/modules/archive_detail/controllers/archive_detail_controller.dart';

class ArchiveDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArchiveDetailController>(
      () => ArchiveDetailController(),
    );
  }
}
