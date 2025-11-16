import 'package:get/get.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/heartbeat/screens/main_screen.dart';

class AppRoute {
  static String loginScreen = "/loginScreen";
  static String mainScreen = "/mainScreen";

  static String getLoginScreen() => loginScreen;
  static String getMainScreen() => mainScreen;

  static List<GetPage> routes = [
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: mainScreen, page: () => const MainScreen()),
  ];
}
