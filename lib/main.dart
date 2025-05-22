import 'package:cattle_managementapp/auth/sign_in_page.dart';
import 'package:cattle_managementapp/controllers/animalRecords_controller.dart';
import 'package:cattle_managementapp/controllers/auth_controller.dart';
import 'package:cattle_managementapp/controllers/notification_controller.dart';
import 'package:cattle_managementapp/firebase_options.dart';
import 'package:cattle_managementapp/themes/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    Get.put(AnimalRecordsController());
    Get.put(NotificationsController());

    return GetMaterialApp(title: 'Cattle Management App', theme: lightTheme, darkTheme: darkTheme, home: SignInPage());
  }
}
