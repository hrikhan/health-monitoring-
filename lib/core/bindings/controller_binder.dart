import 'package:get/get.dart';
import '../../features/heartbeat/controllers/heartbeat_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // Register HeartbeatController as a singleton
    Get.put<HeartbeatController>(HeartbeatController(), permanent: true);
  }
}
