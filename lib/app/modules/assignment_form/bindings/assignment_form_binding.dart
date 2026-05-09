import 'package:get/get.dart';
import 'package:ambanotes/app/modules/assignment_form/controllers/assignment_form_controller.dart';

class AssignmentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AssignmentFormController>(AssignmentFormController());
  }
}
