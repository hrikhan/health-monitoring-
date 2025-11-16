import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for persistent data storage
  await GetStorage.init();

  // Initialize StorageService
  await StorageService.init();

  runApp(const MyApp());
}
