import 'package:face_recognition_web/app/controllers/session_controller.dart';
import 'package:get/get.dart';

class SessionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SessionController());
  }
}
