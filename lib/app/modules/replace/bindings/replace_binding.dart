import 'package:get/get.dart';
import '../controllers/replace_controller.dart';

class ReplaceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReplaceController>(() => ReplaceController());
  }
}
