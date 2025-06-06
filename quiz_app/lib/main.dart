import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quiz_app/app.dart';
import 'package:quiz_app/config/app_manager.dart';

final appManager = AppManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await appManager.init();
  runApp(const MyApp());
}
